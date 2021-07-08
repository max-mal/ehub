defmodule Connections.Http.Router do  
  import Connections.Http.Base, only: [ret: 2]

  alias Connections.Http.Response
  use Plug.Router

  if Mix.env == :dev do
    use Plug.Debugger
  end
  use Plug.ErrorHandler

  plug :put_secret_key_base
  def put_secret_key_base(conn, _) do
    put_in conn.secret_key_base, Application.fetch_env!(:app, :secret_key_base)
  end

  plug Plug.Session, store: :cookie,
                   key: "_app_session",                   
                   signing_salt: Application.fetch_env!(:app, :session_signing_salt)
  
  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug Plug.Parsers, parsers: [:json],
                     pass:  ["application/json"],
                     json_decoder: Jason

  plug :fetch_session
  plug Connections.Http.Authenticator.Pipeline
  plug :fetch_user
  def fetch_user(conn, _) do
    assign(conn, :user, Connections.Http.Authenticator.Plug.current_resource(conn))
  end

  plug :match
  plug :dispatch  

  forward "/", to: Connections.Http.AppRouter

  defp handle_errors(conn, error) do    
    ret(Response.template("500.", [error: error], [title: "500", status: 500]), conn)    
  end

end

defmodule Connections.Http.Root do
  use Plug.Builder

  plug Plug.Logger, log: :debug

  plug Plug.Static,
    at: "/static",
    from: Path.absname("resources/static")
    # only: ~w(images robots.txt)

  plug Connections.Http.Router  
end