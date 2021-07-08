defmodule App.Managers.ProjectManager do
  require Ecto.Query

  def get!(id, repo \\ Storage.Repos.App), do: repo.get!(App.Schemas.User, id)
  
  def create(data, repo \\ Storage.Repos.App) do
    {:ok, name} = Map.fetch(data, "name")
    {:ok, namespace} = Map.fetch(data, "namespace")

    res = case findByNameNamespace(name, namespace, repo) do
      nil -> store(App.Schemas.Project.changeset(%App.Schemas.Project{}, data), repo)
      _ -> {:error, :exists}
    end 
    Utils.GitUtil.init(name, namespace)
    res
  end

  def findByNameNamespace(name, namespace, repo \\ Storage.Repos.App) do
    App.Schemas.Project |> Ecto.Query.where(name: ^name) |> Ecto.Query.where(namespace: ^namespace) |> repo.one
  end

  def delete(_project) do
    ## TODO
  end

  def store(data, repo) do
    case repo.insert(data) do
      {:ok, user} -> {:ok, user}
      _ -> {:error, :store_error}
    end
  end

  def all(repo \\ Storage.Repos.App) do
    App.Schemas.Project |> repo.all
  end

  def userProjects() do
    ## TODO
  end

  def commit_file(project, branch, filename, params, user) do
    Utils.GitUtil.commit_file(
      project.name, 
      project.namespace, 
      branch,
      filename, 
      Map.fetch!(params, "content"), 
      Map.fetch!(params, "message"), 
      "#{user.first_name} #{user.last_name}",
      "#{user.email}"
    )
  end
end