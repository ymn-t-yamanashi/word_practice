defmodule WordPractice.Practice.AnalysisRun do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(running completed failed)

  schema "analysis_runs" do
    field :model_name, :string
    field :status, :string
    field :summary, :string
    field :executed_at, :utc_datetime

    belongs_to :session, WordPractice.Practice.PracticeSession
  end

  def changeset(run, attrs) do
    run
    |> cast(attrs, [:session_id, :model_name, :status, :summary, :executed_at])
    |> validate_required([:session_id, :model_name, :status, :executed_at])
    |> validate_inclusion(:status, @statuses)
  end
end
