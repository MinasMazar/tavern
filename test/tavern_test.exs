defmodule TavernTest do
  use ExUnit.Case
  doctest Tavern
  doctest Tavern.Elisp

  describe "Tavern.Elisp" do
    test "cast a composed sexp" do
      sexp = {:message, {:format, [{:str, "message to display is %s"}, {:str, "hello!"}]}}

      assert Tavern.Elisp.sexp(sexp) == "(message (format \"message to display is %s\" \"hello!\"))"
    end
  end

  describe "Tavern.Connection" do
    test "eval a simple sexp" do
      sexp = {:message, {:format, [{:str, "this is %s!"}, {:str, "Tavern"}]}}

      assert Tavern.emacs_eval(sexp) == "\"this is Tavern!\""
    end
  end

  describe "Tavern.Helpers" do
    test "render template" do
      sexp = Tavern.Helpers.render_template(:test, message: "hello!")

      assert sexp == "(message \"hello!\")"
      assert Tavern.emacs_eval(sexp) == "\"hello!\""
    end
  end
end
