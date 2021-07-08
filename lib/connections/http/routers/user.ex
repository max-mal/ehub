defmodule Connections.Http.UserRouter do  
  
  import Connections.Http.Base, only: [ret: 2]

  alias Connections.Http.Response

  use Plug.Router

  plug Connections.Http.Authenticator.StrictPipeline
  plug :match
  plug :dispatch

  get "/me" do
    user = Connections.Http.Authenticator.Plug.current_resource(conn)
    ret(Response.json(%{
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      about: user.about,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }), conn)
  end

  get "/profile" do
    ret(Response.template("profile.", [user: conn.assigns[:user]], [title: "Профиль"]), conn)
  end

  post "/profile" do
    App.Processes.User.updateProfile(conn.assigns[:user], conn.params, Storage.Repos.App)    

    with {:ok, password} <- Map.fetch(conn.params, "password"),
        {:ok, confirmation} <- Map.fetch(conn.params, "password_confirm"),
        true <- password == confirmation,
        do: App.Processes.User.changePassword(conn.assigns[:user], password, Storage.Repos.App)

    ret(Response.redirect("/user/profile"), conn)
  end

end