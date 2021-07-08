defmodule Connections.Http.Authenticator do
  use Guardian, otp_app: :app  

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    resource = try do
      App.Managers.UserManager.get_user!(id)  
    rescue
      _ -> nil
    end    
    {:ok, resource}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end
end

defmodule Connections.Http.Authenticator.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :app,
    error_handler: Connections.Http.AuthenticatorErrorHandler,
    module: Connections.Http.Authenticator

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}  
  plug Guardian.Plug.LoadResource, allow_blank: true
end

defmodule Connections.Http.Authenticator.StrictPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :app,
    error_handler: Connections.Http.AuthenticatorErrorHandler,
    module: Connections.Http.Authenticator

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, allow_blank: false
end

defmodule Connections.Http.AuthenticatorErrorHandler do
  import Plug.Conn
  import Connections.Http.Base, only: [ret: 2]
  alias Connections.Http.Response

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    ret(Response.redirect("/auth/login"), conn)
  end
end