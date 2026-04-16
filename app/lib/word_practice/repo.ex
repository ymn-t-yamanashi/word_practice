defmodule WordPractice.Repo do
  use Ecto.Repo,
    otp_app: :word_practice,
    adapter: Ecto.Adapters.SQLite3
end
