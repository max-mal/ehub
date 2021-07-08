defmodule Connections.Http.AuthRouter do  
  
  import Connections.Http.Base, only: [run: 2, ret: 2]

  alias Connections.Http.Response

  use Plug.Router

  plug :match
  plug :dispatch

  get "/logout" do
    conn = conn |> Connections.Http.Authenticator.Plug.sign_out()
    ret(Response.redirect("/"), conn)
  end

  get "/login" do
    if conn.assigns[:user] do
      ret(Response.redirect("/"), conn)
    else
      ret(Response.template("login.", [], [title: "Вход в систему"]), conn)
    end
  end

  post "/login" do
    case conn.assigns[:user] do
      nil -> do_login(conn)
      _ -> ret(Response.redirect("/"), conn)
    end
  end

  def do_login(conn) do
    {:ok, login} = Map.fetch(conn.params, "login")
    {:ok, password} = Map.fetch(conn.params, "password")
    
    case App.Processes.User.signIn({login, password}, Storage.Repos.App) do
      {true, user} -> conn = Connections.Http.Authenticator.Plug.sign_in(conn, user)
        ret(Response.redirect("/"), conn)
      _ -> ret(Response.redirect("/auth/login"), conn)
    end
  end

  get "/signup" do    
    if conn.assigns[:user] do
      ret(Response.redirect("/"), conn)
    else
      ret(Response.template("signup.", [], [title: "Регистрация"]), conn)
    end
  end

  post "/signup" do    
    case conn.assigns[:user] do
      nil -> do_signup(conn)
      _ -> ret(Response.redirect("/"), conn)
    end
  end
  
  def do_signup(conn) do
    {:ok, email} = Map.fetch(conn.params, "email")
    {:ok, password} = Map.fetch(conn.params, "password")
    username = email |> String.split("@") |> List.first

    case App.Processes.User.register({email, username, password}, Storage.Repos.App) do
      {:ok, user} -> conn = Connections.Http.Authenticator.Plug.sign_in(conn, user)
        ret(Response.redirect("/"), conn)
      {:error, error} -> ret(Response.text(Kernel.inspect(error)), conn)
    end
  end
end
