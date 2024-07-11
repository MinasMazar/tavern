defmodule Tavern do
  alias Tavern.{Api, Elisp, Helpers}

  @moduledoc """
  Documentation for `Tavern`.
  """
  defdelegate subscribe(), to: Tavern.Api

  def emacs_eval(source), do: emacs_eval(source, :emacsclient)
  def emacs_eval(source, mode) when is_binary(source) do
    source
    |> evaluate(mode)
  end

  def emacs_eval(source, mode) do
    source
    |> to_elisp!
    |> emacs_eval(mode)
  end

  defp to_elisp!(source), do: Elisp.sexp(source)
  defp evaluate(source), do: Api.send_message(source)
  defp evaluate(source, mode), do: Api.send_message(source, mode)
end
