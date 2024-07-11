defmodule Tavern.Examples.TavernMode do
  require Logger
  use GenServer
  import Tavern.Elisp.Macros

  @name :tavern_mode
  @resume_timeout nil # 50_000
  @start_node "entrypoint"
  @setup [:defun, :"tavern-resume", [], [:interactive], [:"tavern-send", @start_node]]
  @root %{
    "entrypoint" => [:quit, "second"],
    "second" => {__MODULE__, :do_something, ["something"]}
  }

  def setup do
    Tavern.emacs_eval(@setup)
  end

  def navigate(:quit, state), do: state
  def navigate(path, state) when is_atom(path) and not is_nil(path) do
    navigate(Atom.to_string(path), state)
  end

  def navigate(path, state) when is_binary(path) do
    new_path = set_path(state, path)
    navigate(new_path, state)
  end

  def navigate(items, state) when is_list(items) do
    [:"tavern-send", select("choose: ", {:quote, items})]
    |> Tavern.emacs_eval()
    :quit
  end

  def navigate({mod, fun, args}, state) do
    apply(mod, fun, args)
  end

  def navigate(path, state) do
    IO.puts("unknown path: #{inspect path}")
    nil
  end

  def set_path(state = %{root: root, node: node}, "." <> path) when is_binary(node) do
    with nodes <- String.split(path, ".") do
      root
      |> get_in(nodes)
    end
  end

  def set_path(state = %{node: node}, path) when is_binary(node) do
    set_path(state, "." <> path)
  end

  def set_path(state = %{node: node}, path) when is_map(node) do
    with nodes <- String.split(path, ".") do
      node
      |> get_in(nodes)
    end
  end

  def async_exec(mod, fun, args) do
    IO.puts("todo: async exec")
  end

  # server
  #
  def start_link do
    GenServer.start_link(__MODULE__, %{root: @root, node: @start_node}, name: @name)
  end

  def init(state) do
    {:ok, ref} = if @resume_timeout do
      :timer.send_interval(@resume_timeout, self(), :resume)
    else
      {:ok, nil}
    end
    Tavern.subscribe()
    setup()
    {:ok, Map.put(state, :ref, ref)}
  end

  def resume(pid \\ @name), do: GenServer.call(@name, :resume)

  def handle_call(:resume, _, state) do
    with result <- navigate(state.node, state) do
      {:reply, result, state}
    end
  end

  def handle_info(:resume, state) do
    navigate(state.node, state)
    {:noreply, state}
  end

  def handle_info({:message, path}, state) do
    IO.puts("Message from Emacs #{inspect path}")
    navigate(path, state)
    {:noreply, state}
  end

  def do_something(message) do
    IO.puts("Doing #{inspect message}")
    :quit
  end
end

Tavern.Examples.TavernMode.start_link()
# Tavern.Examples.TavernMode.resume()
