defmodule Tavern.IEx.Helpers do
  def calc do
    Tavern.emacs_eval("(+ 93 3)")
  end

  def other_window do
    Tavern.emacs_eval("(other-window 1)")
  end

  @script """
  (message "Hello from Elixir side! (via Tavern)")
  """
  def script do
    Tavern.emacs_eval(@script)
  end
end

alias Tavern.IEx.Helpers, as: H
alias Tavern.Helpers, as: HH
