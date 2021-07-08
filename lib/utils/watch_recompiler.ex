defmodule Utils.WatchRecompiler do
  use Supervisor
  require Logger

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do    
    children = [
      Utils.WatchRecompilerTask
    ]

    Logger.info("Starting recompile_watcher")
    Supervisor.init(children, strategy: :one_for_all)
  end
end 

defmodule Utils.WatchRecompilerTask do
  use Task, restart: :permanent

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def run(_arg) do
    :fs.start_link(:my_watcher, Path.absname("lib"))
    # Subscribing `self` to receive events.
    :fs.subscribe(:my_watcher)

    receive do
      {_watcher_process, {:fs, :file_event}, {changedFile, _type}} ->
       IO.puts("#{changedFile} was updated")
       IEx.Helpers.recompile()
    end
  end
end