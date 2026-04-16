defmodule WordPracticeWeb.PracticeLiveTest do
  use WordPracticeWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  setup do
    WordPractice.DataCase.practice_word_fixture()

    WordPractice.DataCase.practice_word_fixture(%{
      lemma_kanji: "仕様確認",
      reading_kana: "しようかくにん",
      reading_katakana: "シヨウカクニン",
      lemma_en: "spec review",
      lemma_romaji: "shiyoukakunin"
    })

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

  test "accepts romaji variants like si for shi", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("button", "スタート")
    |> render_click()

    Enum.each(String.graphemes("gijiroku"), fn char ->
      render_keydown(view, "keydown", %{"key" => char})
    end)

    html =
      Enum.reduce(String.graphemes("siyoukakunin"), "", fn char, _acc ->
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
