defmodule WordPractice.Repo.Migrations.CreateMvpTables do
  use Ecto.Migration

  def change do
    create table(:words) do
      add :lemma_kanji, :text, null: false
      add :reading_kana, :text, null: false
      add :reading_katakana, :text, null: false
      add :lemma_en, :text, null: false
      add :lemma_romaji, :text, null: false
      add :variants, :text
      add :note, :text
      add :source_type, :text, null: false
      add :source_ref, :text
      add :fetched_at, :utc_datetime
      add :difficulty_tag, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:words, [:lemma_kanji])

    create table(:app_settings, primary_key: false) do
      add :id, :integer, primary_key: true
      add :occupation, :text, null: false
      add :auto_register_enabled, :boolean, null: false, default: true
      add :auto_register_count, :integer, null: false, default: 10
      add :llm_model_name, :text, null: false
      add :generation_prompt, :text, null: false
      add :updated_at, :utc_datetime, null: false
    end

    create table(:practice_sessions) do
      add :mode, :text, null: false
      add :status, :text, null: false
      add :started_at, :utc_datetime, null: false
      add :ended_at, :utc_datetime
      add :total_questions, :integer, null: false
      add :correct_count, :integer, null: false
    end

    create table(:practice_answers) do
      add :session_id, references(:practice_sessions, on_delete: :delete_all), null: false
      add :word_id, references(:words, on_delete: :restrict), null: false
      add :question_index, :integer, null: false
      add :input_text, :text, null: false
      add :is_correct, :boolean, null: false
      add :hint_stage, :integer, null: false
      add :response_ms, :integer, null: false
      add :answered_at, :utc_datetime, null: false
    end

    create index(:practice_answers, [:session_id])
    create index(:practice_answers, [:word_id])

    create table(:word_stats, primary_key: false) do
      add :word_id, references(:words, on_delete: :delete_all), primary_key: true
      add :attempts, :integer, null: false, default: 0
      add :wrong_count, :integer, null: false, default: 0
      add :timeout_count, :integer, null: false, default: 0
      add :hint_reached_count, :integer, null: false, default: 0
      add :srs_level, :integer, null: false, default: 0
      add :review_due_at, :utc_datetime
      add :last_answered_at, :utc_datetime
      add :updated_at, :utc_datetime, null: false
    end

    create table(:char_stats, primary_key: false) do
      add :char, :text, primary_key: true
      add :related_attempts, :integer, null: false, default: 0
      add :related_wrong_count, :integer, null: false, default: 0
      add :updated_at, :utc_datetime, null: false
    end

    create table(:vocabulary_fetch_logs) do
      add :setting_id, references(:app_settings, on_delete: :restrict), null: false
      add :source_type, :text, null: false
      add :status, :text, null: false
      add :fetched_count, :integer, null: false, default: 0
      add :error_message, :text
      add :executed_at, :utc_datetime, null: false
    end

    create table(:analysis_runs) do
      add :session_id, references(:practice_sessions, on_delete: :delete_all), null: false
      add :model_name, :text, null: false
      add :status, :text, null: false
      add :summary, :text
      add :executed_at, :utc_datetime, null: false
    end

    create table(:word_recommendations) do
      add :session_id, references(:practice_sessions, on_delete: :delete_all), null: false
      add :analysis_run_id, references(:analysis_runs, on_delete: :nilify_all)
      add :word_id, references(:words, on_delete: :delete_all), null: false
      add :score, :float, null: false
      add :reason, :text, null: false
      add :source, :text, null: false
      add :created_at, :utc_datetime, null: false
    end
  end
end
