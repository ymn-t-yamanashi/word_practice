defmodule WordPractice.Practice.WordStat do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:word_id, :id, autogenerate: false}

  schema "word_stats" do
    field :attempts, :integer
    field :wrong_count, :integer
    field :timeout_count, :integer
    field :hint_reached_count, :integer
    field :srs_level, :integer
    field :review_due_at, :utc_datetime
    field :last_answered_at, :utc_datetime
    field :updated_at, :utc_datetime
  end

  def changeset(stat, attrs) do
    stat
    |> cast(attrs, [
      :word_id,
      :attempts,
      :wrong_count,
      :timeout_count,
      :hint_reached_count,
      :srs_level,
      :review_due_at,
      :last_answered_at,
      :updated_at
    ])
    |> validate_required([
      :word_id,
      :attempts,
      :wrong_count,
      :timeout_count,
      :hint_reached_count,
      :srs_level,
      :updated_at
    ])
  end
end
