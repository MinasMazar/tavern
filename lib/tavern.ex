defmodule Tavern do
  alias Tavern.{Elisp, Api.EmacsClient}

  @moduledoc """
  Documentation for `Tavern`.
  """

  def emacs_eval(source) when is_binary(source) do
    source
    |> Api.EmacsClient.emacs_eval()
  end

  def emacs_eval(source) do
    source
    |> Elisp.sexp()
    |> EmacsClient.emacs_eval()
  end
end
