defmodule WordPractice.Practice do
  @moduledoc false

  import Ecto.Query, warn: false

  alias WordPractice.Practice.AppSetting
  alias WordPractice.Practice.CharStat
  alias WordPractice.Practice.PracticeAnswer
  alias WordPractice.Practice.PracticeSession
  alias WordPractice.Practice.Word
  alias WordPractice.Practice.WordStat
  alias WordPractice.Repo

  @session_size 10
  @single_mode "single"
  @srs_intervals [0, 1, 3, 7, 14, 30]

  def session_size, do: @session_size

  def list_words do
    Repo.all(from word in Word, order_by: [asc: word.id])
  end

  def list_session_words(limit \\ @session_size) do
    list_words()
    |> Enum.take(limit)
  end

  def list_weak_trends(limit \\ 7) do
    Repo.all(
      from word in Word,
        join: stat in WordStat,
        on: stat.word_id == word.id,
        order_by: [desc: stat.timeout_count, desc: stat.wrong_count, asc: word.id],
        limit: ^limit,
        select: %{
          word_id: word.id,
          lemma_kanji: word.lemma_kanji,
          wrong_count: stat.wrong_count,
          timeout_count: stat.timeout_count,
          hint_reached_count: stat.hint_reached_count
        }
    )
  end

  def get_app_setting do
    Repo.get(AppSetting, 1)
  end

  def change_app_setting(setting, attrs \\ %{}) do
    AppSetting.changeset(setting, attrs)
  end

  def create_or_update_app_setting(attrs) do
    setting = Repo.get(AppSetting, 1) || %AppSetting{id: 1}

    setting
    |> AppSetting.changeset(attrs)
    |> Repo.insert_or_update()
  end

  def new_session do
    words = list_session_words()

    %{
      session_id: nil,
      words: words,
      current_index: 0,
      current_input: "",
      time_left: 30,
      started?: false,
      completed?: false,
      feedback: nil,
      answers: [],
      metrics: %{
        correct_count: 0,
        streak: 0,
        max_streak: 0,
        average_response_seconds: 0.0,
        accuracy_rate: 0
      },
      weak_trends: list_weak_trends()
    }
  end

  def start_session(words) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    %PracticeSession{}
    |> PracticeSession.changeset(%{
      mode: @single_mode,
      status: "running",
      started_at: now,
      total_questions: length(words),
      correct_count: 0
    })
    |> Repo.insert()
  end

  def complete_answer(session_id, word, attrs) do
    answered_at = DateTime.utc_now() |> DateTime.truncate(:second)
    input_text = String.trim(attrs.input_text || "")
    is_timeout = attrs.result == :timeout
    is_correct = attrs.result == :correct
    hint_stage = attrs.hint_stage || 0
    response_ms = attrs.response_ms || 0

    Repo.transaction(fn ->
      answer =
        %PracticeAnswer{}
        |> PracticeAnswer.changeset(%{
          session_id: session_id,
          word_id: word.id,
          question_index: attrs.question_index,
          input_text: input_text,
          is_correct: is_correct,
          hint_stage: hint_stage,
          response_ms: response_ms,
          answered_at: answered_at
        })
        |> Repo.insert!()

      update_word_stats!(word.id, answered_at, is_correct, is_timeout, hint_stage > 0)
      update_char_stats!(word.lemma_romaji, input_text, is_correct, answered_at)
      answer
    end)
  end

  def finish_session(session_id, answers) do
    ended_at = DateTime.utc_now() |> DateTime.truncate(:second)
    correct_count = Enum.count(answers, & &1.is_correct)

    session =
      Repo.get!(PracticeSession, session_id)
      |> PracticeSession.changeset(%{
        status: "completed",
        ended_at: ended_at,
        correct_count: correct_count
      })
      |> Repo.update!()

    %{session: session, weak_trends: list_weak_trends()}
  end

  def dashboard_snapshot do
    state = new_session()
    current_word = Enum.at(state.words, state.current_index)

    %{
      session_size: @session_size,
      current_question: state.current_index + 1,
      timer_seconds: state.time_left,
      current_word: current_word,
      answer_preview: state.current_input,
      accuracy_rate: state.metrics.accuracy_rate,
      average_response_seconds: state.metrics.average_response_seconds,
      streak: state.metrics.max_streak,
      weak_trends: state.weak_trends
    }
  end

  def normalize_input(input), do: String.trim(input || "")

  def hint_stage(elapsed_seconds) when elapsed_seconds >= 20, do: 2
  def hint_stage(elapsed_seconds) when elapsed_seconds >= 10, do: 1
  def hint_stage(_elapsed_seconds), do: 0

  def hint_text(_word, 0), do: nil
  def hint_text(word, stage), do: String.slice(word.lemma_romaji, 0, stage)

  def current_word(state), do: Enum.at(state.words, state.current_index)

  def session_metrics(answers) do
    total = max(length(answers), 1)
    correct_count = Enum.count(answers, & &1.is_correct)

    average_response_seconds =
      answers
      |> Enum.map(fn answer -> answer.response_ms / 1000 end)
      |> average()

    streak =
      answers
      |> Enum.reduce({0, 0}, fn answer, {current, best} ->
        if answer.is_correct do
          next = current + 1
          {next, max(best, next)}
        else
          {0, best}
        end
      end)
      |> elem(1)

    %{
      correct_count: correct_count,
      accuracy_rate: round(correct_count / total * 100),
      average_response_seconds: Float.round(average_response_seconds, 1),
      streak: streak,
      max_streak: streak
    }
  end

  defp update_word_stats!(word_id, answered_at, is_correct, is_timeout, hint_reached?) do
    stat =
      Repo.get(WordStat, word_id) ||
        %WordStat{
          word_id: word_id,
          attempts: 0,
          wrong_count: 0,
          timeout_count: 0,
          hint_reached_count: 0,
          srs_level: 0,
          updated_at: answered_at
        }

    next_level =
      if is_correct do
        min(stat.srs_level + 1, 5)
      else
        max(stat.srs_level - 1, 0)
      end

    review_due_at =
      DateTime.add(answered_at, Enum.at(@srs_intervals, next_level) * 86_400, :second)

    stat
    |> WordStat.changeset(%{
      word_id: word_id,
      attempts: stat.attempts + 1,
      wrong_count: stat.wrong_count + if(is_correct, do: 0, else: 1),
      timeout_count: stat.timeout_count + if(is_timeout, do: 1, else: 0),
      hint_reached_count: stat.hint_reached_count + if(hint_reached?, do: 1, else: 0),
      srs_level: next_level,
      review_due_at: review_due_at,
      last_answered_at: answered_at,
      updated_at: answered_at
    })
    |> Repo.insert_or_update!()
  end

  defp update_char_stats!(expected, input_text, is_correct, answered_at) do
    chars =
      (expected <> input_text)
      |> String.graphemes()
      |> Enum.uniq()

    Enum.each(chars, fn char ->
      stat =
        Repo.get(CharStat, char) ||
          %CharStat{
            char: char,
            related_attempts: 0,
            related_wrong_count: 0,
            updated_at: answered_at
          }

      stat
      |> CharStat.changeset(%{
        char: char,
        related_attempts: stat.related_attempts + 1,
        related_wrong_count: stat.related_wrong_count + if(is_correct, do: 0, else: 1),
        updated_at: answered_at
      })
      |> Repo.insert_or_update!()
    end)
  end

  defp average([]), do: 0.0
  defp average(values), do: Enum.sum(values) / length(values)
end
