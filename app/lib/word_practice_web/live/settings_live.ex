defmodule WordPracticeWeb.SettingsLive do
  use WordPracticeWeb, :live_view

  alias WordPractice.Practice
  alias WordPractice.Practice.AppSetting

  @occupations ["事務", "営業", "エンジニア", "看護", "介護"]

  @impl true
  def mount(_params, _session, socket) do
    setting =
      Practice.get_app_setting() ||
        %AppSetting{
          id: 1,
          occupation: "事務",
          auto_register_enabled: true,
          auto_register_count: 10,
          llm_model_name: "Llama-3.1-Swallow-8B-Instruct",
          generation_prompt: "職業ごとの実務単語を10件生成してください。"
        }

    {:ok,
     socket
     |> assign(:page_title, "設定")
     |> assign(:occupations, @occupations)
     |> assign_form(setting)}
  end

  @impl true
  def handle_event("validate", %{"app_setting" => params}, socket) do
    changeset =
      socket.assigns.setting
      |> Practice.change_app_setting(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"app_setting" => params}, socket) do
    case Practice.create_or_update_app_setting(params) do
      {:ok, setting} ->
        {:noreply,
         socket
         |> put_flash(:info, "設定を保存しました。")
         |> assign_form(setting)}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-stone-950 text-stone-100">
      <div class="mx-auto max-w-4xl px-4 py-6 lg:px-8">
        <header class="mb-6 flex items-center justify-between border-b border-white/10 pb-4">
          <div>
            <p class="text-xs uppercase tracking-[0.4em] text-amber-300">word_practice</p>
            <h1 class="mt-2 text-3xl font-semibold">設定</h1>
          </div>
          <.link
            navigate={~p"/"}
            class="rounded-full border border-white/15 px-3 py-1 text-sm hover:border-amber-300 hover:text-amber-200"
          >
            練習へ戻る
          </.link>
        </header>

        <Layouts.flash_group flash={@flash} />

        <.form for={@form} phx-change="validate" phx-submit="save" class="space-y-6">
          <section class="rounded-3xl border border-white/10 bg-white/5 p-6">
            <p class="text-sm text-stone-400">職業選択</p>
            <div class="mt-4 grid gap-3 sm:grid-cols-2">
              <label
                :for={occupation <- @occupations}
                class="flex cursor-pointer items-center gap-3 rounded-2xl border border-white/10 px-4 py-3 hover:border-amber-300/50"
              >
                <input
                  type="radio"
                  name={@form[:occupation].name}
                  value={occupation}
                  checked={@form[:occupation].value == occupation}
                  class="text-amber-300 focus:ring-amber-300"
                />
                <span>{occupation}</span>
              </label>
            </div>
          </section>

          <section class="rounded-3xl border border-white/10 bg-white/5 p-6">
            <div class="grid gap-5 md:grid-cols-2">
              <label class="block">
                <span class="text-sm text-stone-400">自動登録件数</span>
                <.input field={@form[:auto_register_count]} type="number" min="1" max="50" />
              </label>
              <label class="block">
                <span class="text-sm text-stone-400">LLMモデル</span>
                <.input field={@form[:llm_model_name]} type="text" />
              </label>
            </div>

            <label class="mt-5 flex items-center gap-3">
              <.input field={@form[:auto_register_enabled]} type="checkbox" />
              <span>職業選択時に問題を自動登録する</span>
            </label>

            <label class="mt-5 block">
              <span class="text-sm text-stone-400">生成プロンプト</span>
              <.input field={@form[:generation_prompt]} type="textarea" rows="5" />
            </label>
          </section>

          <div class="flex justify-end">
            <button
              type="submit"
              class="rounded-full bg-amber-300 px-6 py-3 font-semibold text-stone-950 hover:bg-amber-200"
            >
              保存
            </button>
          </div>
        </.form>
      </div>
    </div>
    """
  end

  defp assign_form(socket, setting) do
    changeset = Practice.change_app_setting(setting)

    socket
    |> assign(:setting, setting)
    |> assign(:form, to_form(changeset))
  end
end
