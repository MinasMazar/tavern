defmodule Tavern.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = if Tavern.Api.websocket_enabled?() do
      websocket_children()
    else
      []
    end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tavern.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp websocket_children do
    [registry_spec(), cowboy_spec()]
  end

  defp cowboy_spec do
    Plug.Cowboy.child_spec(
      scheme: :http,
      plug: Tavern.Router,
      options: [port: port(), dispatch: dispatch()])
  end

  defp registry_spec do
    Registry.child_spec(keys: :unique, name: Tavern.Registry)
  end

  defp dispatch, do: PlugSocket.plug_cowboy_dispatch(Tavern.Api.Router)
  defp port, do: Application.get_env(:tavern, :port, 9069)
end
