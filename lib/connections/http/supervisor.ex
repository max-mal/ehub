defmodule Connections.Http.Supervisor do
  use Supervisor
  require Logger

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do

    port = String.to_integer(System.get_env("PORT") || "8080")
    children = [
      {Plug.Cowboy, scheme: :http, plug: Connections.Http.Root, options: [port: port]}
    ]

    Logger.info("Starting cowboy_plug on port #{port}")
    Supervisor.init(children, strategy: :one_for_one)    
  end
end