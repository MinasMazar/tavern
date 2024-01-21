defmodule Tavern.Elisp do
  @doc """
  Cast a string to a string.

  iex> Tavern.Elisp.sexp(nil)
  nil
  
  iex> Tavern.Elisp.sexp([])
  "()"

  iex> Tavern.Elisp.sexp("message")
  ~s("message")

  iex> Tavern.Elisp.sexp(:variable)
  :variable

  iex> Tavern.Elisp.sexp(:"a-variable")
  :"a-variable"

  iex> Tavern.Elisp.sexp({:quote, :"a-variable"})
  ~s('a-variable)

  iex> Tavern.Elisp.sexp(42)
  42

  Cast a list to a list

  iex> Tavern.Elisp.sexp([:function, :b, 3, "d", 5])
  ~s[(function b 3 "d" 5)]

  iex> Tavern.Elisp.sexp([:lambda, [:x], [:"+", :x, 3]])
  ~s[(lambda (x) (+ x 3))]

  iex> Tavern.Elisp.sexp([:"+", 2, 4])
  "(+ 2 4)"

  Cast a tuple to an association list

  iex> Tavern.Elisp.sexp({:a, "b"})
  ~s[(a . "b")]

  Cast a map to a property list.

  iex> Tavern.Elisp.sexp(%{a: 1, b: 2})
  ":a 1 :b 2"
  """
  def sexp(nil), do: nil
  def sexp([]), do: "()"
  def sexp(exp) when is_binary(exp), do: "\"#{exp}\""
  def sexp(exp) when is_atom(exp), do: exp
  def sexp(exp) when is_integer(exp) or is_float(exp), do: exp

  def sexp({:quote, exp}), do: "'#{sexp(exp)}"
  def sexp({car, cdr}), do: "(#{sexp(car)} . #{sexp(cdr)})"
  def sexp([exp]), do: "(#{sexp(exp)})"

  def sexp(exp) when is_list(exp) do
    exp = exp
    |> Enum.map(& sexp(&1))
    |> Enum.join(" ")
    "(#{exp})"
  end

  def sexp(exp) when is_map(exp) do
    for {k,v} <- exp, into: [] do
      ":#{k} #{sexp(v)}"
    end |> Enum.join(" ")
  end

  def sexp(_), do: raise ArgumentError, "#{__MODULE__} received invalid sexp"
end
