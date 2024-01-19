defmodule Tavern.Api.EmacsClient do
  @moduledoc """
  Documentation for `Tavern`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Tavern.hello()
      :world

  """
  require Logger

  def emacs_eval(source), do: emacs_eval(source, :wait_output)
  def emacs_eval(source, :spawn) do
    Logger.debug("Sending #{inspect source} to emacsclient")
    port = Port.open({:spawn, "emacsclient -e '#{source}'"}, [])
    Port.monitor(port)
  end

  def emacs_eval(source, :wait_output) do
    emacs_eval(source, :spawn)
    receive do
      {_port, {:data, output}} ->
	output
	|> sanitize_output()
	|> to_elixir()
    after
      2000 ->
	IO.puts(:stderr, "No message in 2 secs")
	{:error, :timeout}
    end
  end

  defp sanitize_output(str) when is_list(str) do
    str
    |> List.to_string()
    |> String.trim()
  end

  defp to_elixir(str) when is_binary(str) do
    with {code, []} <- Code.eval_string(str), do: code
  end
end
