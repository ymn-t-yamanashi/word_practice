defmodule WordPractice.Practice.Word do
  use Ecto.Schema
  import Ecto.Changeset

  @source_types ~w(user seed internet llm)

  schema "words" do
    field :lemma_kanji, :string
    field :reading_kana, :string
    field :reading_katakana, :string
    field :lemma_en, :string
    field :lemma_romaji, :string
    field :variants, :string
    field :note, :string
    field :source_type, :string
    field :source_ref, :string
    field :fetched_at, :utc_datetime
    field :difficulty_tag, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(word, attrs) do
    word
    |> cast(attrs, [
      :lemma_kanji,
      :reading_kana,
      :reading_katakana,
      :lemma_en,
      :lemma_romaji,
      :variants,
      :note,
      :source_type,
      :source_ref,
      :fetched_at,
      :difficulty_tag
    ])
    |> validate_required([
      :lemma_kanji,
      :reading_kana,
      :reading_katakana,
      :lemma_en,
      :lemma_romaji,
      :source_type
    ])
    |> validate_inclusion(:source_type, @source_types)
    |> unique_constraint(:lemma_kanji)
  end
end
