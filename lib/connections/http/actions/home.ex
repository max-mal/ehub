defmodule Connections.Http.Actions.Home do
  alias Connections.Http.Response
  
  def run(connection) do    
    Response.template("home.", [hello: "world", user: connection.assigns[:user]], [
      title: "Home page::App"
    ])
  end  
end
