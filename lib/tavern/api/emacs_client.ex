defmodule Tavern.Api.EmacsClient do
  @moduledoc """
  Documentation for `Tavern`.
  """
  require Logger

  def emacs_eval(source), do: emacs_eval(source, :wait_output)
  def emacs_eval(source, :spawn) do
    cmd = ~s[emacsclient -e #{inspect source}]
    Logger.debug("Sending #{cmd} to emacsclient")
    port = Port.open({:spawn, cmd}, [])
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
