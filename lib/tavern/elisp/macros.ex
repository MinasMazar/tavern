defmodule Tavern.Elisp.Macros do
  def select(prompt, options) do
    [:"completing-read", prompt, {:quote, options}]
  end

  def get_buffer_content(buffer) do
    {:"with-current-buffer", buffer, {:"buffer-string"}}
  end

  def message(message), do: [:message, message]

  def replace_buffer_content(buffer, src) do
    [:progn,
     clear_buffer(buffer),
     with_current_buffer(buffer) do
       [:insert, src <> "\n"]
     end
    ]
  end

  def clear_buffer(buffer) do
    with_current_buffer(buffer) do
      [:"delete-region", [:"point-min"], [:"point-max"]]
    end
  end

  def with_current_buffer(buffer, do: body) do
    [:"with-current-buffer",
     [:"get-buffer-create", buffer],
     body
    ]
  end
end
