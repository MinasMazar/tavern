defmodule TavernTest do
  use ExUnit.Case
  doctest Tavern
  doctest Tavern.Elisp

  describe "Tavern.Elisp" do
    test "cast a composed sexp" do
      sexp = [:message, [:format, "message to display is %s", "hello!"]]

      assert Tavern.Elisp.sexp(sexp) == "(message (format \"message to display is %s\" \"hello!\"))"
    end

    test "cast a composed sexp with a quoted list" do
      sexp = [:mapcar, [:lambda, [:n], [:"+", :n, 3]], {:quote, [1, 2, 3]}]

      assert Tavern.Elisp.sexp(sexp) == "(mapcar (lambda (n) (+ n 3)) '(1 2 3))"
    end
  end

  describe "Tavern.Connection" do
    test "eval a simple sexp" do
      sexp = [:message, [:format, "this is %s!", "Tavern"]]

      assert Tavern.emacs_eval(sexp) == "\"this is Tavern!\""
    end

    test "eval a simple sexp with a quoted list" do
      sexp = [:mapcar, [:lambda, [:n], [:"+", :n, 3]], [:quote, [1, 2, 3]]]

      assert Tavern.emacs_eval(sexp) == "(4 5 6)"
    end
  end
end
