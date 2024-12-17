defmodule Tavern do
  @default_timeout :infinity
  alias Tavern.{Elisp, Api.EmacsClient}

  @moduledoc """
  Documentation for `Tavern`.
  """
  def emacs_eval(source) do
    emacs_eval(source, @default_timeout)
  end

  def emacs_eval(source, timeout) when is_binary(source) do
    source
    |> EmacsClient.emacs_eval(timeout)
  end

  def emacs_eval(source, timeout) do
    source
    |> Elisp.sexp()
    |> EmacsClient.emacs_eval(timeout)
  end

  def greet! do
    emacs_eval([:message, "hello from Elixir!"])
  end
end
