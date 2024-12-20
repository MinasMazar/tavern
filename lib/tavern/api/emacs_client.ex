defmodule Tavern.Api.EmacsClient do
  require Logger
  use GenServer

  def emacs_eval(source, timeout) do
    with {:ok, pid} <- GenServer.start(__MODULE__, source) do
      wait_output(pid, timeout)
    end
  end

  defp wait_output(pid, timeout) do
    GenServer.call(pid, :result, timeout)
    receive do
      {:tavern, :output, [result]} -> result
      {:tavern, :output, [result | rest]} -> {:multi, result, rest}
    after
      timeout -> :timeout
    end
  end

  def init(source) do
    cmd = ~s[emacsclient -e #{inspect source}]
    Logger.debug("Sending #{cmd} to emacsclient")
    port = Port.open({:spawn, cmd}, [])
    Port.monitor(port)
    {:ok, {[], nil}}
  end

  def handle_call(:result, from, {[], nil}) do
    Logger.debug("#{__MODULE__} result with no result and no pid.. waiting")
    {:reply, :waiting, {[], from}}
  end

  def handle_call(:result, _, state = {result, nil}) do
    Logger.debug("#{__MODULE__} result with result #{inspect result} no pid")
    {:reply, result, state}
  end

  def handle_call(:result, _, state = {result, from}) do
    Logger.debug("#{__MODULE__} result with result #{inspect result} and pid #{inspect from}")
    # GenServer.reply(from, result)
    with {pid, _} <- from, do: send(pid, {:tavern, :output, result})
    {:reply, result, state}
  end

  def handle_info({_port, {:data, output}}, {results, nil}) do
    Logger.debug("#{__MODULE__} message from port received #{inspect output} and no pid")
    with result <- sanitize_output(output) do
      {:noreply, {[result | results], nil}}
    end
  end

  def handle_info({_port, {:data, output}}, {results, from}) do
    Logger.debug("#{__MODULE__} message from port received #{inspect output} with pid #{inspect from}")
    with result <- sanitize_output(output),
	 state = {[result | results], from} do
      {:reply, _reply, state} = handle_call(:result, from, state)
      {:noreply, state}
    end
  end

  def handle_info({:DOWN, _, :port, _, :normal}, state = {result, from}) do
    Logger.debug("#{__MODULE__} down")
    # with {pid, _} <- from, do: send(pid, {:tavern, :down})
    {:stop, {:shutdown, :normal}, nil}
  end

  def handle_info({:DOWN, _, :port, _, :normal}, _) do
    Logger.debug("#{__MODULE__} message from port received DOWN")
    {:stop, {:shutdown, :normal}, nil}
  end

  defp sanitize_output(result) when is_list(result) do
    result
    |> List.to_string()
    |> String.replace(~r{(^"|"$)}, "")
    |> String.replace(~r[\\], "")
    |> String.trim()
  end
end
