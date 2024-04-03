defmodule Tavern.Api.SocketHandler do
  @behaviour :cowboy_websocket
  require Logger
  
  def init(req, state) do
    {:cowboy_websocket, req, state}
  end

  def websocket_init(state) do
    result = Registry.register(Tavern.Registry, "socket_handler", :socket_handler)
    Logger.debug("Subscribing socket handler (#{inspect result}")
    schedule_ping(state)
    {:ok, state}
  end

  def websocket_handle({:text, "tavern-pong"}, state) do
    Logger.debug("Received pong!")
    schedule_ping(state)
    {:reply, {:text, "nil"}, state}
  end

  def websocket_handle({:text, message}, state) do
    Logger.debug("Received message #{inspect message}")
    dispatch_message(message)
    case Tavern.Api.response_handler().call(message) do
      response when is_binary(response) -> {:reply, {:text, response}, state}
      nil -> {:reply, {:text, "nil"}, state}
    end
  end

  def websocket_info(:ping, state) do
    Logger.debug("Sending ping..")
    {:reply, {:text, "(tavern--pong)"}, state}
  end

  def websocket_info({:send_to_emacs, message}, state) do
    Logger.debug("[tavern] sending message to emacs \"#{message}\"")
    {:reply, {:text, message}, state}
  end

  def terminate(reason, _req, _state) do
    Logger.debug("Terminating websocket handler because of #{inspect reason}")
  end

  defp dispatch_message(message) do
    Registry.dispatch(Tavern.Registry, "consumer", fn entries ->
      for {pid, mode} <- entries do
        send(pid, {:message, message})
      end
    end)
  end

  @ping_interval 6_000
  defp schedule_ping(_) do
    Process.send_after(self(), :ping, @ping_interval)
  end
end
