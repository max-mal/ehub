defmodule App.Schemas.User do
  use Ecto.Schema

  import Ecto.Changeset

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :username, :string
    field :email, :string
    field :about, :string
    field :password, :string
    field :is_active, :boolean, default: false
    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user    
    |> cast(params, [:first_name, :last_name, :username, :email, :about, :password, :is_active])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  def update_profile_changeset(user, params \\ %{}) do
    user |> cast(params, [:first_name, :last_name, :about])
  end
end