defmodule WordPracticeWeb.PracticeLive do
  use WordPracticeWeb, :live_view

  alias WordPractice.Practice

  @timer_seconds 30

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(1_000, :tick)

    state = Practice.new_session()

    {:ok,
     socket
     |> assign(:page_title, "練習")
     |> assign(:state, state)
     |> assign_snapshot()}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-950 text-slate-50" phx-window-keydown="keydown">
      <div class="mx-auto flex min-h-screen max-w-7xl flex-col px-4 py-6 lg:px-8">
        <header class="mb-6 flex items-center justify-between border-b border-white/10 pb-4">
          <div>
            <p class="text-xs uppercase tracking-[0.4em] text-cyan-300">word_practice</p>
            <h1 class="mt-2 text-3xl font-semibold">練習セッション</h1>
          </div>
          <nav class="flex items-center gap-3 text-sm">
            <span class="rounded-full bg-cyan-400/15 px-3 py-1 text-cyan-200">/</span>
            <.link
              navigate={~p"/settings"}
              class="rounded-full border border-white/15 px-3 py-1 hover:border-cyan-300 hover:text-cyan-200"
            >
              設定
            </.link>
          </nav>
        </header>

        <div class="grid flex-1 gap-6 lg:grid-cols-[minmax(0,2fr)_20rem]">
          <section class="space-y-5">
            <article class="overflow-hidden rounded-3xl border border-white/10 bg-white/5 shadow-2xl shadow-cyan-950/30">
              <div class="flex items-center justify-between border-b border-white/10 px-6 py-4 text-sm text-slate-300">
                <span>Q {@snapshot.current_question} / {@snapshot.session_size}</span>
                <span>{@snapshot.timer_seconds}s</span>
              </div>
              <div class="h-1 w-full bg-white/10">
                <div
                  class="h-full bg-gradient-to-r from-cyan-400 to-emerald-400"
                  style={"width: #{@snapshot.progress_percent}%"}
                >
                </div>
              </div>
              <div class="space-y-6 px-6 py-8">
                <div>
                  <p class="text-sm text-slate-400">表示（漢字）</p>
                  <div class="mt-3 grid min-h-52 place-items-center rounded-3xl border border-dashed border-white/15 bg-slate-900/70 p-6 text-center">
                    <button
                      :if={!@snapshot.started? and !@snapshot.completed?}
                      type="button"
                      phx-click="start"
                      class="rounded-full bg-cyan-400 px-8 py-3 text-base font-semibold text-slate-950 transition hover:bg-cyan-300"
                    >
                      スタート
                    </button>
                    <p
                      :if={!@snapshot.started? and !@snapshot.completed?}
                      class="mt-4 text-sm text-slate-400"
                    >
                      開始までは問題を非表示にする仕様を反映済みです。
                    </p>
                    <p
                      :if={@snapshot.started? and @snapshot.current_word}
                      class="mt-6 text-4xl font-semibold tracking-[0.12em] text-white"
                    >
                      {@snapshot.current_word.lemma_kanji}
                    </p>
                    <div :if={@snapshot.completed?} class="space-y-2">
                      <p class="text-3xl font-semibold text-emerald-200">セッション完了</p>
                      <p class="text-sm text-slate-300">10問分の結果を同一画面に表示しています。</p>
                    </div>
                  </div>
                </div>

                <div>
                  <p class="text-sm text-slate-400">入力（ローマ字）</p>
                  <div class="mt-3 rounded-2xl border border-white/10 bg-slate-950/80 px-4 py-5 text-2xl tracking-[0.3em] text-cyan-200">
                    {@snapshot.answer_preview}
                  </div>
                  <p class="mt-2 text-sm text-slate-500">{@snapshot.feedback}</p>
                  <p :if={@snapshot.hint_text} class="mt-2 text-sm text-amber-200">
                    ヒント: {@snapshot.hint_text}
                  </p>
                </div>
              </div>
            </article>

            <section class="grid gap-4 md:grid-cols-3">
              <article class="rounded-3xl border border-white/10 bg-white/5 p-5">
                <p class="text-sm text-slate-400">正答率</p>
                <p class="mt-3 text-4xl font-semibold text-cyan-200">{@snapshot.accuracy_rate}%</p>
              </article>
              <article class="rounded-3xl border border-white/10 bg-white/5 p-5">
                <p class="text-sm text-slate-400">平均回答時間</p>
                <p class="mt-3 text-4xl font-semibold text-emerald-200">
                  {@snapshot.average_response_seconds}s
                </p>
              </article>
              <article class="rounded-3xl border border-white/10 bg-white/5 p-5">
                <p class="text-sm text-slate-400">連続正解</p>
                <p class="mt-3 text-4xl font-semibold text-amber-200">{@snapshot.streak}</p>
              </article>
            </section>
          </section>

          <aside>
            <article class="rounded-3xl border border-white/10 bg-white/5 p-5">
              <p class="text-sm uppercase tracking-[0.35em] text-rose-200/80">Weak Trends</p>
              <h2 class="mt-3 text-2xl font-semibold">苦手傾向</h2>
              <ul class="mt-5 space-y-3">
                <li
                  :for={trend <- @snapshot.weak_trends}
                  class="rounded-2xl border border-white/10 bg-slate-950/60 p-4"
                >
                  <p class="font-medium">{trend.lemma_kanji}</p>
                  <p class="mt-1 text-sm text-slate-400">
                    {trend_message(trend)}
                  </p>
                </li>
              </ul>
            </article>
          </aside>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("start", _params, socket) do
    state = socket.assigns.state

    case Practice.start_session(state.words) do
      {:ok, session} ->
        {:noreply,
         socket
         |> assign(:state, %{
           state
           | started?: true,
             session_id: session.id,
             time_left: @timer_seconds
         })
         |> assign_snapshot()}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "セッションを開始できませんでした。")}
    end
  end

  @impl true
  def handle_event("keydown", %{"key" => key}, socket) do
    state = socket.assigns.state

    cond do
      !state.started? or state.completed? ->
        {:noreply, socket}

      key == "Backspace" ->
        next_state = %{
          state
          | current_input:
              String.slice(state.current_input, 0, max(String.length(state.current_input) - 1, 0))
        }

        {:noreply, socket |> assign(:state, next_state) |> assign_snapshot()}

      String.length(key) == 1 ->
        next_state = %{state | current_input: state.current_input <> key}
        {:noreply, evaluate_answer(socket, next_state)}

      true ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(:tick, socket) do
    state = socket.assigns.state

    cond do
      !state.started? or state.completed? ->
        {:noreply, socket}

      state.time_left <= 1 ->
        {:noreply, finalize_answer(socket, state, :timeout)}

      true ->
        next_state = %{state | time_left: state.time_left - 1}
        {:noreply, socket |> assign(:state, next_state) |> assign_snapshot()}
    end
  end

  defp trend_message(%{timeout_count: timeout_count}) when timeout_count > 0,
    do: "タイムアウト #{timeout_count}回"

  defp trend_message(%{wrong_count: wrong_count}) when wrong_count > 0,
    do: "ローマ字ミス #{wrong_count}回"

  defp trend_message(%{hint_reached_count: hint_reached_count}),
    do: "ヒント到達 #{hint_reached_count}回"

  defp evaluate_answer(socket, state) do
    current_word = Practice.current_word(state)
    normalized_input = Practice.normalize_input(state.current_input)

    if current_word && Practice.romaji_match?(normalized_input, current_word) do
      finalize_answer(socket, state, :correct)
    else
      socket
      |> assign(:state, %{state | feedback: "入力中..."})
      |> assign_snapshot()
    end
  end

  defp finalize_answer(socket, state, result) do
    current_word = Practice.current_word(state)
    question_index = state.current_index + 1
    elapsed_seconds = @timer_seconds - state.time_left
    hint_stage = Practice.hint_stage(elapsed_seconds)

    {:ok, answer} =
      Practice.complete_answer(state.session_id, current_word, %{
        question_index: question_index,
        input_text: state.current_input,
        result: result,
        hint_stage: hint_stage,
        response_ms: elapsed_seconds * 1000
      })

    answers = state.answers ++ [answer]
    metrics = Practice.session_metrics(answers)

    if question_index >= length(state.words) do
      final = Practice.finish_session(state.session_id, answers)

      socket
      |> assign(:state, %{
        state
        | answers: answers,
          metrics: metrics,
          started?: false,
          completed?: true,
          feedback: result_message(result),
          weak_trends: final.weak_trends
      })
      |> assign_snapshot()
    else
      socket
      |> assign(:state, %{
        state
        | current_index: state.current_index + 1,
          current_input: "",
          time_left: @timer_seconds,
          answers: answers,
          metrics: metrics,
          feedback: result_message(result)
      })
      |> assign_snapshot()
    end
  end

  defp assign_snapshot(socket) do
    state = socket.assigns.state
    current_word = Practice.current_word(state)
    current_question = min(state.current_index + 1, max(length(state.words), 1))
    elapsed_seconds = @timer_seconds - state.time_left
    hint_stage = Practice.hint_stage(elapsed_seconds)

    assign(socket, :snapshot, %{
      session_size: length(state.words),
      current_question: current_question,
      timer_seconds: state.time_left,
      current_word: current_word,
      answer_preview: state.current_input,
      accuracy_rate: state.metrics.accuracy_rate,
      average_response_seconds: state.metrics.average_response_seconds,
      streak: state.metrics.max_streak,
      weak_trends: state.weak_trends,
      started?: state.started?,
      completed?: state.completed?,
      feedback: state.feedback || "直接入力を受け付けます。",
      hint_text:
        if(state.started? && current_word, do: Practice.hint_text(current_word, hint_stage)),
      progress_percent: progress_percent(state)
    })
  end

  defp progress_percent(state) do
    total = max(length(state.words), 1)
    Float.round(state.current_index / total * 100, 1)
  end

  defp result_message(:correct), do: "正解です。次の問題へ進みます。"
  defp result_message(:timeout), do: "タイムアウトです。次の問題へ進みます。"
end
