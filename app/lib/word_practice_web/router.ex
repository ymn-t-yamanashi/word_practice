defmodule WordPracticeWeb.Router do
  use WordPracticeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {WordPracticeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WordPracticeWeb do
    pipe_through :browser

    live "/", PracticeLive
    live "/settings", SettingsLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", WordPracticeWeb do
  #   pipe_through :api
  # end
end
