defmodule Tavern.Elisp do
  @doc """
  Cast a string to a string.

  iex> Tavern.Elisp.sexp(nil)
  ""

  iex> Tavern.Elisp.sexp({:str, nil})
  ""

  iex> Tavern.Elisp.sexp({:str, "message"})
  ~s("message")

  iex> Tavern.Elisp.sexp("message")
  ~s("message")

  iex> Tavern.Elisp.sexp(:"a-function")
  :"a-function"

  Cast a tuple to en elisp function evaluation.

  iex> Tavern.Elisp.sexp({"message", ["hello here!"]})
  ~s[(message "hello here!")]

  Cast a list to a list.

  iex> Tavern.Elisp.sexp(%{a: 1, b: 2})
  ":a 1 :b 2"

  iex> Tavern.Elisp.sexp([])
  "()"

  iex> Tavern.Elisp.sexp(nil)
  ""

  Cast a map to a property list.

  iex> Tavern.Elisp.sexp(%{a: 1, b: 2})
  ":a 1 :b 2"
  """
  def sexp(nil), do: ""
  def sexp({:str, nil}), do: ""
  def sexp({:str, body}) when is_binary(body), do: "\"#{body}\""
  def sexp(body) when is_binary(body), do: "\"#{body}\""
  def sexp(body) when is_atom(body), do: body
  def sexp({fun, rest = {_, _}}) do
    "(#{fun} #{sexp(rest)})"
  end
  def sexp({fun, rest}) when is_binary(rest) do
    "(#{fun} #{sexp(rest)})"
  end
  def sexp({fun, rest}) when is_list(rest) do
    rest = rest
    |> Enum.map(& "#{sexp(&1)}")
    |> Enum.join(" ")
    "(#{fun} #{rest})"
  end
  def sexp({fun, nil}) do
    "(#{fun} nil)"
  end
  def sexp([first | rest]), do: "(#{sexp(first)} #{sexp(rest)})"
  def sexp([]), do: "()"
  def sexp(map) when is_map(map) do
    for {k,v} <- map, into: [] do
      ":#{k} #{v}"
    end |> Enum.join(" ")
  end
end
