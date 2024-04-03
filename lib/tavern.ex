defmodule Tavern do
  alias Tavern.{Api, Elisp, Helpers}

  @moduledoc """
  Documentation for `Tavern`.
  """

  def emacs_eval(source) when is_binary(source), do: emacs_eval(:el, source)
  def emacs_eval(source), do: emacs_eval(:ex, source)

  def emacs_eval(:el, {:template, name}) do
    emacs_eval(:el, {:template, name, []})
  end

  def emacs_eval(:el, {:template, name, params}) do
    with source <- Helpers.render_template(name, params) do
      emacs_eval(:el, source)
    end
  end

  def emacs_eval(:el, source) when is_binary(source) do
    source
    |> evaluate()
  end

  def emacs_eval(:el, {:error, message}) do
    {:error, message}
  end

  def emacs_eval(:ex, source) do
    emacs_eval(:el, source |> to_elisp!())
  end

  defp to_elisp!(source), do: Elisp.sexp(source)
  defp evaluate(source), do: Api.send_message(source)
end
