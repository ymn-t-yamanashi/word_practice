defmodule WordPractice.Practice.WordRecommendation do
  use Ecto.Schema
  import Ecto.Changeset

  @sources ~w(rule llm hybrid)

  schema "word_recommendations" do
    field :score, :float
    field :reason, :string
    field :source, :string
    field :created_at, :utc_datetime

    belongs_to :session, WordPractice.Practice.PracticeSession
    belongs_to :analysis_run, WordPractice.Practice.AnalysisRun
    belongs_to :word, WordPractice.Practice.Word
  end

  def changeset(recommendation, attrs) do
    recommendation
    |> cast(attrs, [
      :session_id,
      :analysis_run_id,
      :word_id,
      :score,
      :reason,
      :source,
      :created_at
    ])
    |> validate_required([:session_id, :word_id, :score, :reason, :source, :created_at])
    |> validate_inclusion(:source, @sources)
  end
end
