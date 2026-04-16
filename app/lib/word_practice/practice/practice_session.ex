defmodule WordPractice.Practice.PracticeSession do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(running completed aborted failed)

  schema "practice_sessions" do
    field :mode, :string
    field :status, :string
    field :started_at, :utc_datetime
    field :ended_at, :utc_datetime
    field :total_questions, :integer
    field :correct_count, :integer
  end

  def changeset(session, attrs) do
    session
    |> cast(attrs, [:mode, :status, :started_at, :ended_at, :total_questions, :correct_count])
    |> validate_required([:mode, :status, :started_at, :total_questions, :correct_count])
    |> validate_inclusion(:status, @statuses)
  end
end
