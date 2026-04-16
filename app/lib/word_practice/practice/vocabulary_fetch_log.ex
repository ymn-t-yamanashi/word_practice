defmodule WordPractice.Practice.VocabularyFetchLog do
  use Ecto.Schema
  import Ecto.Changeset

  @source_types ~w(internet llm)
  @statuses ~w(running completed failed)

  schema "vocabulary_fetch_logs" do
    field :source_type, :string
    field :status, :string
    field :fetched_count, :integer
    field :error_message, :string
    field :executed_at, :utc_datetime

    belongs_to :setting, WordPractice.Practice.AppSetting
  end

  def changeset(log, attrs) do
    log
    |> cast(attrs, [
      :setting_id,
      :source_type,
      :status,
      :fetched_count,
      :error_message,
      :executed_at
    ])
    |> validate_required([:setting_id, :source_type, :status, :fetched_count, :executed_at])
    |> validate_inclusion(:source_type, @source_types)
    |> validate_inclusion(:status, @statuses)
  end
end
