# ER図（word_practice / MVP）

```mermaid
erDiagram
    WORDS {
        %% 単語ID
        integer id PK
        %% 主表示用の漢字表記
        text lemma_kanji
        %% 判定用のローマ字表記
        text lemma_romaji
        %% 表記ゆれ（かな/カナ/英字）
        text variants
        %% 管理メモ
        text note
        %% 取得元種別（manual/local_seed/internet/llm）
        text source_type
        %% 取得元の参照情報（URLやモデル名など）
        text source_ref
        %% 取得日時
        datetime fetched_at
        %% 難易度タグ
        text difficulty_tag
        %% 作成日時
        datetime inserted_at
        %% 更新日時
        datetime updated_at
    }

    PRACTICE_SESSIONS {
        %% セッションID
        integer id PK
        %% セッション種別（practice/review）
        text mode
        %% 開始時刻
        datetime started_at
        %% 終了時刻
        datetime ended_at
        %% 出題数
        integer total_questions
        %% 正答数
        integer correct_count
    }

    PRACTICE_ANSWERS {
        %% 回答ID
        integer id PK
        %% セッションID
        integer session_id FK
        %% 出題単語ID
        integer word_id FK
        %% ユーザー入力（ローマ字）
        text input_text
        %% 正誤
        boolean is_correct
        %% 到達ヒント段階
        integer hint_stage
        %% 回答時間(ms)
        integer response_ms
    }

    WORD_STATS {
        %% 単語ID（WORDSと1対1）
        integer word_id PK,FK
        %% 試行回数
        integer attempts
        %% 誤答回数
        integer wrong_count
        %% タイムアウト回数
        integer timeout_count
        %% ヒント到達回数
        integer hint_reached_count
        %% 更新日時
        datetime updated_at
    }

    CHAR_STATS {
        %% 文字（キー）
        text char PK
        %% 関連試行回数
        integer related_attempts
        %% 関連誤答回数
        integer related_wrong_count
        %% 更新日時
        datetime updated_at
    }

    VOCABULARY_FETCH_LOGS {
        %% 取得ログID
        integer id PK
        %% 取得元種別
        text source_type
        %% 実行結果ステータス
        text status
        %% 取得件数
        integer fetched_count
        %% エラーメッセージ
        text error_message
        %% 実行日時
        datetime executed_at
    }

    ANALYSIS_RUNS {
        %% 分析実行ID
        integer id PK
        %% 対象セッションID
        integer session_id FK
        %% 利用モデル名
        text model_name
        %% 実行結果ステータス
        text status
        %% 分析要約
        text summary
        %% 実行日時
        datetime executed_at
    }

    WORD_RECOMMENDATIONS {
        %% 提案ID
        integer id PK
        %% 対象セッションID
        integer session_id FK
        %% 提案単語ID
        integer word_id FK
        %% 提案スコア
        real score
        %% 提案理由
        text reason
        %% 生成元（rule/llm/hybrid）
        text source
        %% 作成日時
        datetime created_at
    }

    PRACTICE_SESSIONS ||--o{ PRACTICE_ANSWERS : has
    WORDS ||--o{ PRACTICE_ANSWERS : answered_as
    WORDS ||--|| WORD_STATS : aggregated_to
    PRACTICE_SESSIONS ||--o{ ANALYSIS_RUNS : analyzed_by
    PRACTICE_SESSIONS ||--o{ WORD_RECOMMENDATIONS : outputs
    WORDS ||--o{ WORD_RECOMMENDATIONS : recommends
```

## 補足
- `CHAR_STATS` は全回答テキストからの集計テーブルで、単語テーブルへの直接FKは持たない。
- `WORD_STATS` は `WORDS` と1対1で集計を保持する。

## この設計にした理由
- タイピング主軸に合わせるため:
  - `WORDS` に `lemma_kanji`（表示）と `lemma_romaji`（判定）を分け、要件の「表示は漢字・入力はローマ字」をそのままデータで表現できるようにした。
- セッション再現性を確保するため:
  - `PRACTICE_SESSIONS` と `PRACTICE_ANSWERS` を分離し、1回の練習で「いつ・何問・何をどう回答したか」を追跡できるようにした。
- 苦手分析を高速化するため:
  - 生ログ（`PRACTICE_ANSWERS`）とは別に集計テーブル（`WORD_STATS`, `CHAR_STATS`）を持たせ、毎回の重い集計を避けてUI表示を軽くした。
- LLM提案の検証可能性を担保するため:
  - `ANALYSIS_RUNS` と `WORD_RECOMMENDATIONS` を分け、分析実行履歴と提案結果を独立して保存し、後から妥当性を検証できるようにした。
- 外部語彙取り込みの運用性を上げるため:
  - `WORDS` に `source_type/source_ref/fetched_at`、別途 `VOCABULARY_FETCH_LOGS` を持たせ、取得元・失敗原因・再実行履歴を管理できるようにした。
- SQLite3前提で実装を単純化するため:
  - 単一ユーザー運用を前提に、必要十分な正規化に留めつつテーブル数を抑え、実装初期の複雑性と運用負荷を下げた。
