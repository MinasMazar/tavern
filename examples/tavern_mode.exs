defmodule Tavern.Examples.TavernMode do
  import Tavern.Helpers

  @tavern_mode_src """
  (add-to-list 'load-path "~/.emacs.d/vendor/")
  (require 'package)
  (setq package-archives '(("melpa" . "https://melpa.org/packages/")
			   ("elpa" . "https://elpa.gnu.org/packages/")
			   ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
  (require 'use-package)
  (require 'use-package-ensure)
  (setq use-package-always-ensure t
	package-enable-at-startup t)
  (package-initialize)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((shell . t)
     (elixir. t)))
  
  (add-to-list 'load-path "~/.emacs.d/vendor/apprentice.el/")
  (require 'apprentice)
  (use-package elixir-mode)
  (use-package exunit
    :after 'elixir-mode)

  """

  def run do
    System.cmd("git", ~w[git clone https://github.com/Sasanidas/Apprentice ~/.emacs.d/vendor/apprentice.el])
    Tavern.emacs_eval(@tavern_mode_src)
  end
end

Tavern.Examples.TavernMode.run()
