defmodule Connections.Http.ProjectRouter do

  import Connections.Http.Base, only: [ret: 2]

  alias Connections.Http.Response

  use Plug.Router

  plug Connections.Http.Authenticator.StrictPipeline
  plug :match
  plug :dispatch

  get "/" do
    projects = App.Managers.ProjectManager.all()
    ret(Response.template("projects/index.", [projects: projects]), conn)
  end

  get "/new" do
    ret(Response.template("projects/new.", [user: conn.assigns[:user]]), conn)
  end

  post "/new" do
    App.Managers.ProjectManager.create(%{"namespace" => conn.assigns[:user].username, "name" => Map.fetch!(conn.params, "name")})
    ret(Response.redirect("/project/"), conn)
  end

  get "/:namespace/:name" do
    case App.Managers.ProjectManager.findByNameNamespace(name, namespace) do
      nil -> ret(Response.redirect("/404"), conn)
      project -> ret(Response.template("/projects/project.", [project: project]), conn)
    end
  end

  get "/:namespace/:name/branch/all" do
    case App.Managers.ProjectManager.findByNameNamespace(name, namespace) do
      nil -> ret(Response.redirect("/404"), conn)
      _ -> ret(Response.json(Utils.GitUtil.branch_list(name, namespace)), conn)
    end
  end

  get "/:namespace/:name/branch/:branch/files" do
    case App.Managers.ProjectManager.findByNameNamespace(name, namespace) do
      nil -> ret(Response.redirect("/404"), conn)
      _ -> ret(Response.json(Utils.GitUtil.get_files(name, namespace, branch)), conn)
    end
  end

  get "/:namespace/:name/branch/:branch/files/*dir" do
    case App.Managers.ProjectManager.findByNameNamespace(name, namespace) do
      nil -> ret(Response.redirect("/404"), conn)
      _ -> ret(Response.json(Utils.GitUtil.get_files(name, namespace, branch, Enum.join(dir, "/") <> "/")), conn)
    end
  end

  get "/:namespace/:name/branch/:branch/file/log/*path" do
    case App.Managers.ProjectManager.findByNameNamespace(name, namespace) do
      nil -> ret(Response.redirect("/404"), conn)
      _ -> ret(Response.json(Utils.GitUtil.file_log(name, namespace, branch, Enum.join(path, "/"))), conn)
    end
  end

  get "/:namespace/:name/branch/:branch/file/contents/*path" do
    case App.Managers.ProjectManager.findByNameNamespace(name, namespace) do
      nil -> ret(Response.redirect("/404"), conn)
      _ -> ret(Response.json(Utils.GitUtil.get_file_contents(name, namespace, branch, Enum.join(path, "/"))), conn)
    end
  end

  get "/:namespace/:name/browse/*path" do
    case App.Managers.ProjectManager.findByNameNamespace(name, namespace) do
      nil -> ret(Response.redirect("/404"), conn)
      project -> ret(Response.template("/projects/project.", [project: project]), conn)
    end
  end

  get "/:namespace/:name/edit/*path" do
    case App.Managers.ProjectManager.findByNameNamespace(name, namespace) do
      nil -> ret(Response.redirect("/404"), conn)
      project -> ret(Response.template("/projects/project.", [project: project]), conn)
    end
  end

  post "/:namespace/:name/edit/:branch/*path" do
    case App.Managers.ProjectManager.findByNameNamespace(name, namespace) do
      nil -> ret(Response.redirect("/404"), conn)
      project -> ret(Response.json(App.Managers.ProjectManager.commit_file(project, branch, Enum.join(path, "/"), conn.params, conn.assigns[:user])), conn)
    end
  end

  get "/:namespace/:name/commit/:hash/json" do
    case App.Managers.ProjectManager.findByNameNamespace(name, namespace) do
      nil -> ret(Response.redirect("/404"), conn)
      project -> ret(Response.json(Utils.GitUtil.commit_changes(project.name, project.namespace, hash)), conn)
    end
  end

  get "/:namespace/:name/commit/:hash" do
    case App.Managers.ProjectManager.findByNameNamespace(name, namespace) do
      nil -> ret(Response.redirect("/404"), conn)
      project -> ret(Response.template("projects/commit.", [project: project, hash: hash]), conn)
    end
  end

end
