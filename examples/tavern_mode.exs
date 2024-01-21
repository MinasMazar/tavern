defmodule Tavern.Examples.TavernMode do
  import Tavern.Helpers

  @setup [
    :progn,
    [:"add-to-list", {:quote, :"load-path"}, "~/.emacs.d/vendor"],
    [:require, {:quote, :package}],
    [:setq, :"packages-archives", 
	{:quote, [
	  {"melpa", "https://melpa.org/packages/"},
	  {"elpa", "https://elpa.gnu.org/packages/"},
	  {"nongnu", "https://elpa.nongnu.org/nongnu/"}
	]}
    ],
    [:require, {:quote, :"use-package"}],
    [:require, {:quote, :"use-package-ensure"}],
    [:setq,
     :"use-package-always-ensure", :t,
     :"package-enable-at-startup", :t],
    [:"package-initialize"],
    [:"use-package", :"elixir-mode"],
    [:"use-package", :exunit, %{after: {:quote, "elixir-mode"}}]
  ]

  def run do
    Tavern.emacs_eval(@setup)
  end
end

Tavern.Examples.TavernMode.run()
