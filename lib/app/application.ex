defmodule App.Application do

  use Application

  @impl true
  def start(_type, _args) do    

    children = [
      Storage.Supervisor
    ]

    ## TODO Перетащить в connections/supervisor
    children = if Application.fetch_env!(:app, :web) do
      children ++ [
        Connections.Http.Supervisor
      ]
    end

    children = if Application.fetch_env!(:app, :watch_recompiler) do
      children ++ [
        Utils.WatchRecompiler
      ]
    end

    
    opts = [strategy: :one_for_one, name: App.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
