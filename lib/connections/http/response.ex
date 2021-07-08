defmodule Connections.Http.Response do
  def text(response, status \\ 200, content_type \\ "text/plain") do
    {:text, response, status, content_type}
  end

  def template(template, params \\ [], options \\ []) do
    {:template, template, params, options}
  end

  def json(data, status \\ 200) do
    {:json, data, status}
  end

  def redirect(url) do
    {:redirect, url}
  end
end