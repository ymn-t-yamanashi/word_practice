defmodule WordPractice.Practice.AppSetting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "app_settings" do
    field :occupation, :string
    field :auto_register_enabled, :boolean, default: true
    field :auto_register_count, :integer, default: 10
    field :llm_model_name, :string
    field :generation_prompt, :string
    field :updated_at, :utc_datetime
  end

  def changeset(setting, attrs) do
    setting
    |> cast(attrs, [
      :id,
      :occupation,
      :auto_register_enabled,
      :auto_register_count,
      :llm_model_name,
      :generation_prompt,
      :updated_at
    ])
    |> validate_required([
      :occupation,
      :auto_register_enabled,
      :auto_register_count,
      :llm_model_name,
      :generation_prompt
    ])
    |> validate_number(:auto_register_count, greater_than: 0)
    |> put_change(:updated_at, DateTime.utc_now() |> DateTime.truncate(:second))
  end
end
