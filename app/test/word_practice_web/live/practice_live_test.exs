defmodule WordPracticeWeb.PracticeLiveTest do
  use WordPracticeWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  setup do
    WordPractice.DataCase.practice_word_fixture()
    :ok
  end

  test "renders practice dashboard", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")

    assert html =~ "練習セッション"
    assert html =~ "苦手傾向"
    assert html =~ "スタート"
  end

  test "starts a session and completes a correct answer", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    html =
      view
      |> element("button", "スタート")
      |> render_click()

    assert html =~ "議事録"

    html =
      Enum.reduce(String.graphemes("gijiroku"), html, fn char, _acc ->
        render_keydown(view, "keydown", %{"key" => char})
      end)

    assert html =~ "正解です"
  end

  test "renders settings screen", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/settings")

    assert html =~ "設定"
    assert html =~ "職業選択"
    assert html =~ "LLMモデル"
  end
end
