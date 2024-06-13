defmodule Tavern.Api do
  require Logger
  alias Tavern.Api.EmacsClient

  def subscribe do
    if websocket_enabled?(), do: Registry.register(Tavern.Registry, "consumer", :consumer)
  end

  def get_message do
    receive do
      {:message, message} -> message
    end
  end

  def send_message(message) do
    if websocket_enabled?() do
      send_message(message, :ws)
    else
      send_message(message, :emacsclient)
    end
  end

  def send_message(message, :emacsclient) do
    EmacsClient.emacs_eval(message)
  end

  def send_message(message, :ws) do
    Registry.dispatch(Tavern.Registry, "socket_handler", fn entries ->
      for {pid, mode} <- entries do
        Logger.debug("a subscribed is #{inspect mode}")
        Logger.debug("Sending message to emacs #{message}")
        send(pid, {:send_to_emacs, message})
      end
    end)
  end

  def response_handler do
    Application.get_env(:tavern, :response_handler, Tavern.ResponseHandler)
  end

  def websocket_enabled? do
    System.get_env("TAVERN_WEBSOCKET_DISABLED") != "true"
  end
end
