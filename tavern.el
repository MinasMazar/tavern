(use-package websocket
  :config
  (require 'websocket)

  (defvar tavern-endpoint "ws://localhost:4305/tavern"
    "Endpoint of tavern elixir application")

  (defun tavern-start ()
    "Start webserver connection to Tavern (Elixir WS server)"
    (interactive)
    (setq tavern--websocket
          (websocket-open
           tavern-endpoint
           :on-message
           (lambda (_websocket frame)
             (let ((body (websocket-frame-text frame)))
               (tavern-eval body)))
					;(message "[tavern] message received: %S" body)))
           :on-close (lambda (_websocket) (message "websocket closed")))))

  (defun tavern-stop
      (interactive)
      (websocket-close tavern--websocket))

  (defun tavern-send (payload)
    (interactive "sMessage: ")
    (unless (tavern-open-connection)
      (tavern-start))
    (websocket-send-text tavern--websocket payload))

  (defun tavern-open-connection ()
    (websocket-openp tavern--websocket))

  (defun tavern-eval (string)
    "Evaluate elisp code stored in a string."
    ;; (message (format "tavern> evaluating %s" string))
    (eval (car (read-from-string string))))

  (defun tavern--pong ()
    (tavern-send "tavern-pong"))

  (setq tavern--websocket nil))
