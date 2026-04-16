defmodule WordPractice.Practice.CharStat do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:char, :string, autogenerate: false}

  schema "char_stats" do
    field :related_attempts, :integer
    field :related_wrong_count, :integer
    field :updated_at, :utc_datetime
  end

  def changeset(stat, attrs) do
    stat
    |> cast(attrs, [:char, :related_attempts, :related_wrong_count, :updated_at])
    |> validate_required([:char, :related_attempts, :related_wrong_count, :updated_at])
  end
end
