defmodule Tavern.Elisp.Macros do
  def get_buffer_content(buffer) do
    {:"with-current-buffer", buffer, {:"buffer-string"}}
  end

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

  def render_template(template, params) do
    template
    |> template_filename()
    |> EEx.eval_file(assigns: params)
    |> String.trim()
  end

  def template_filename(template) do
    Path.expand("../templates/#{template}.eex.el", __ENV__.file)
  end
end
