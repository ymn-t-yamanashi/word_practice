defmodule WordPractice.Practice.PracticeAnswer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "practice_answers" do
    field :question_index, :integer
    field :input_text, :string
    field :is_correct, :boolean
    field :hint_stage, :integer
    field :response_ms, :integer
    field :answered_at, :utc_datetime

    belongs_to :session, WordPractice.Practice.PracticeSession
    belongs_to :word, WordPractice.Practice.Word
  end

  def changeset(answer, attrs) do
    answer
    |> cast(attrs, [
      :session_id,
      :word_id,
      :question_index,
      :input_text,
      :is_correct,
      :hint_stage,
      :response_ms,
      :answered_at
    ])
    |> validate_required([
      :session_id,
      :word_id,
      :question_index,
      :input_text,
      :is_correct,
      :hint_stage,
      :response_ms,
      :answered_at
    ])
  end
end
