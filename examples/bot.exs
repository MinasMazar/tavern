defmodule Tavern.Examples.Bot do
  require Logger
  import Tavern.Elisp.Macros
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(state) do
    :timer.send_interval(10_000, :tick)
    {:ok, state}
  end

  def handle_info(:tick, state) do
    Tavern.emacs_client([:"elfeed-update"])
    {:noreply, state}
  end
end

{:ok, pid} = Tavern.Examples.Bot.start_link()
Process.sleep(10 * 1000)
GenServer.stop(pid)
