defmodule WordPractice.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use WordPractice.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias WordPractice.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import WordPractice.DataCase
    end
  end

  setup tags do
    WordPractice.DataCase.setup_sandbox(tags)
    :ok
  end

  @doc """
  Sets up the sandbox based on the test tags.
  """
  def setup_sandbox(tags) do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(WordPractice.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  def practice_word_fixture(attrs \\ %{}) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    word_attrs =
      Map.merge(
        %{
          lemma_kanji: "議事録",
          reading_kana: "ぎじろく",
          reading_katakana: "ギジロク",
          lemma_en: "minutes",
          lemma_romaji: "gijiroku",
          source_type: "seed",
          source_ref: "test",
          fetched_at: now,
          difficulty_tag: "business"
        },
        attrs
      )

    word =
      %WordPractice.Practice.Word{}
      |> WordPractice.Practice.Word.changeset(word_attrs)
      |> WordPractice.Repo.insert!()

    %WordPractice.Practice.WordStat{}
    |> WordPractice.Practice.WordStat.changeset(%{
      word_id: word.id,
      attempts: 0,
      wrong_count: 0,
      timeout_count: 0,
      hint_reached_count: 0,
      srs_level: 0,
      updated_at: now
    })
    |> WordPractice.Repo.insert!()

    word
  end
end
