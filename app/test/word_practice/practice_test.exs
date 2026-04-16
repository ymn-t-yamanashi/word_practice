defmodule WordPractice.PracticeTest do
  use WordPractice.DataCase, async: true

  alias WordPractice.Practice
  alias WordPractice.Practice.CharStat
  alias WordPractice.Practice.WordStat
  alias WordPractice.Repo

  setup do
    word = practice_word_fixture()
    words = [word]
    {:ok, words: words}
  end

  test "complete_answer updates word and char stats", %{words: [word | _]} do
    {:ok, session} = Practice.start_session([word])

    {:ok, _answer} =
      Practice.complete_answer(session.id, word, %{
        question_index: 1,
        input_text: word.lemma_romaji,
        result: :correct,
        hint_stage: 1,
        response_ms: 4_000
      })

    stat = Repo.get!(WordStat, word.id)
    char_stat = Repo.get!(CharStat, "g")

    assert stat.attempts >= 1
    assert stat.hint_reached_count >= 1
    assert stat.srs_level >= 1
    assert char_stat.related_attempts >= 1
  end
end
