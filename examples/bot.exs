defmodule Tavern.Examples.Bot do
  require Logger
  import Tavern.Helpers
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    :timer.send_interval(1_000, :tick)
    {:ok, %{buffer_name: "<*tavern*>"}}
  end

  def handle_info(:tick, state) do
    replace_buffer_content(state.buffer_name, get_line(state))
    |> Tavern.emacs_eval()

    {:noreply, state}
  end

  def get_line(_) do
    inspect(DateTime.utc_now())
  end
end

{:ok, pid} = Tavern.Examples.Bot.start_link()
Process.sleep(2 * 60 * 1000)
GenServer.stop(pid)
