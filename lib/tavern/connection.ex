defmodule Tavern.Connection do
  require Logger
  use GenServer
  import Tavern.Api.EmacsClient, only: [emacs_eval: 2]

  def emacs_eval(source) do
    with {:ok, pid} <- GenServer.start(__MODULE__, source) do
      get_output(pid)
    end
  end

  def get_output(pid) do
    GenServer.call(pid, :result)
    receive do
      [result] -> result
      [result | rest] -> {:multi, result, rest}
    after
      2000 -> :timeout
    end
  end

  def init(source) do
    emacs_eval(source, :spawn)
    {:ok, {[], nil}}
  end

  def handle_call(:result, from, {[], nil}) do
    Logger.debug("result with no result and no pid.. waiting")
    {:reply, :waiting, {[], from}}
  end

  def handle_call(:result, _, state = {result, nil}) do
    Logger.debug("result with result #{inspect result} no pid")
    {:reply, result, state}
  end

  def handle_call(:result, _, state = {result, from}) do
    Logger.debug("result with result #{inspect result} and pid #{inspect from}")
    # GenServer.reply(from, result)
    with {pid, _} <- from, do: send(pid, result)
    {:reply, result, state}
  end

  def handle_info({_port, {:data, output}}, {results, nil}) do
    Logger.debug("message from port received #{inspect output} and no pid")
    with result <- sanitize_output(output) do
      {:noreply, {[result | results], nil}}
    end
  end

  def handle_info({_port, {:data, output}}, {results, from}) do
    Logger.debug("message from port received #{inspect output} with pid #{inspect from}")
    with result <- sanitize_output(output),
	 state = {[result | results], from} do
      {:reply, _reply, state} = handle_call(:result, from, state)
      {:noreply, state}
    end
  end

  def handle_info({:DOWN, _, :port, _, :normal}, _) do
    Logger.debug("message from port received DOWN")
    {:stop, {:shutdown, :normal}, nil}
  end

  defp sanitize_output(result) when is_list(result) do
    result
    |> List.to_string()
    |> String.trim()
  end
end
