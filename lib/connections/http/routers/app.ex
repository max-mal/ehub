defmodule Connections.Http.AppRouter do  
  
  import Connections.Http.Base, only: [run: 2, ret: 2]
  alias Connections.Http.Response
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do        
    run(Connections.Http.Actions.Home, conn)
  end

  get "/conn" do
    ret(Response.text(Kernel.inspect(conn)), conn)
  end

  forward "/auth", to: Connections.Http.AuthRouter
  forward "/user", to: Connections.Http.UserRouter
  forward "/project", to: Connections.Http.ProjectRouter

  match _ do
    ret(Response.template("404.", [], [title: "404", status: 404]), conn)
  end

end
