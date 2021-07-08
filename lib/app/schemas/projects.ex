defmodule App.Schemas.Project do
  use Ecto.Schema

  import Ecto.Changeset

  schema "projects" do    
    field :name, :string
    field :namespace, :string
    field :description, :string
    field :prog_language, :string
    field :creator_id, :integer
    timestamps()
  end

  def changeset(project \\ %App.Schemas.Project{}, params \\ %{}) do
    project    
    |> cast(params, [:name, :namespace, :description, :prog_language, :creator_id])
    |> validate_required([:name, :namespace])    
  end
end