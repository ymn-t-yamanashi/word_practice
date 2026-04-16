# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     WordPractice.Repo.insert!(%WordPractice.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias WordPractice.Practice.AppSetting
alias WordPractice.Practice.Word
alias WordPractice.Practice.WordStat
alias WordPractice.Repo

timestamp = DateTime.utc_now() |> DateTime.truncate(:second)

Repo.insert!(
  %AppSetting{
    id: 1,
    occupation: "事務",
    auto_register_enabled: true,
    auto_register_count: 10,
    llm_model_name: "Llama-3.1-Swallow-8B-Instruct",
    generation_prompt: "職業ごとの実務単語を10件生成してください。",
    updated_at: timestamp
  },
  on_conflict: {:replace_all_except, [:id]},
  conflict_target: :id
)

seed_words = [
  {"議事録", "ぎじろく", "ギジロク", "minutes", "gijiroku", "business"},
  {"要件定義", "ようけんていぎ", "ヨウケンテイギ", "requirements", "youkenteigi", "business"},
  {"進捗管理", "しんちょくかんり", "シンチョクカンリ", "progress", "shinchokukanri", "business"},
  {"仕様確認", "しようかくにん", "シヨウカクニン", "spec review", "shiyoukakunin", "business"},
  {"顧客対応", "こきゃくたいおう", "コキャクタイオウ", "customer support", "kokyakutaiou", "business"},
  {"品質保証", "ひんしつほしょう", "ヒンシツホショウ", "quality assurance", "hinshitsuhoshou", "business"},
  {"障害対応", "しょうがいたいおう", "ショウガイタイオウ", "incident response", "shougaitaiou", "business"}
]

Enum.each(seed_words, fn {kanji, kana, katakana, en, romaji, tag} ->
  word =
    Repo.insert!(
      %Word{
        lemma_kanji: kanji,
        reading_kana: kana,
        reading_katakana: katakana,
        lemma_en: en,
        lemma_romaji: romaji,
        source_type: "seed",
        source_ref: "priv/repo/seeds.exs",
        fetched_at: timestamp,
        difficulty_tag: tag
      },
      on_conflict: {:replace_all_except, [:id]},
      conflict_target: :lemma_kanji
    )

  Repo.insert!(
    %WordStat{
      word_id: word.id,
      attempts: 3,
      wrong_count: if(kanji in ["要件定義", "仕様確認", "障害対応"], do: 1, else: 0),
      timeout_count: if(kanji in ["議事録", "品質保証"], do: 1, else: 0),
      hint_reached_count: if(kanji in ["顧客対応", "進捗管理"], do: 1, else: 0),
      srs_level: 1,
      review_due_at: timestamp,
      last_answered_at: timestamp,
      updated_at: timestamp
    },
    on_conflict: {:replace_all_except, [:word_id]},
    conflict_target: :word_id
  )
end)
