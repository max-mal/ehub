defmodule Connections.Http.Base do
  use Plug.Router
  require Logger  

  match _ do
    send_resp(conn, 404, "No route")
  end

  @doc """
    Запускает действие из роутера

      get "/" do
        run(Connections.Http.Actions.Home, conn)
      end
  """
  def run(module, connection) do
    res = module.run(connection)
    sendResponse(res, connection)
  end

  @doc """
    Возвращает ответ из роутера

      get "/" do
        ret(Connections.Http.Response.text("Hello World"), conn)
      end
  """
  def ret(response, connection) do
    sendResponse(response, connection)
  end

  ## Обработка ответа, из действия
  defp sendResponse(response, connection)

  ## Отправка текстового ответа
  defp sendResponse({:text, text, status, content_type}, connection) do
    connection = put_resp_content_type(connection, content_type)
    send_resp(connection, status, text)
  end

  ## Отправка HTML шаблона
  defp sendResponse({:template, template, params, options}, connection) do
    rendered = renderTemplate(template, params)
    body = case Keyword.fetch(options, :layout) do
      {:ok, nil} -> rendered
      {:ok, layout} -> renderTemplate(layout, [content: rendered] ++ layoutProperties(options, connection))          
      _ ->  renderTemplate("../layouts/main.", [content: rendered] ++ layoutProperties(options, connection))
    end
    connection = put_resp_content_type(connection, "text/html")
    send_resp(connection, getOption(options, :status, 200), body)
  end

  ## Отправка json ответа
  defp sendResponse({:json, data, status}, connection) do
    connection = put_resp_content_type(connection, "application/json")
    send_resp(connection, status, Jason.encode!(data))
  end

  defp sendResponse({:redirect, url}, connection) do
    connection |> Plug.Conn.resp(:found, "") |> Plug.Conn.put_resp_header("location", url)
  end


  ## Получение парамета по атому
  defp getOption(options, key, default) do
    case Keyword.fetch(options, key) do
      {:ok, value} -> value
      _ -> default
    end       
  end

  ## Рендер шаблона
  defp renderTemplate(template, assigns) do
    Utils.TemplateRenderer.render(template, assigns)
  end

  ## Получение свойств для layout
  defp layoutProperties(options, connection) do 
    props = [
      user: connection.assigns[:user]
    ]

    props = case Keyword.fetch(options, :title) do
      {:ok, title} -> props ++ [title: title]
      _ -> props ++ [title: "App"]
    end

    props = case Keyword.fetch(options, :description) do
      {:ok, description} -> props ++ [description: description]
      _ -> props ++ [description: "App description"]
    end
    props
  end
end