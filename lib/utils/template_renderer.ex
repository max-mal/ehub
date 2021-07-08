defmodule Utils.TemplateRenderer do
	@template_dir "resources/templates"
	@doc"""
		Рендер HTML шаблона

		Utils.TemplateRenderer.render("templae.", [data: some_data])

	"""
	def render(template, assigns \\ []) do
	    @template_dir
	      |> Path.join(template)
	      |> String.replace_suffix(".", ".html.eex")
	      |> Path.absname
	      |> EEx.eval_file(assigns, engine: Phoenix.HTML.Engine, functions: [
	      	{ Kernel, [length: 1]},
	      	{ Utils.TemplateRenderer, [render: 2]},
	      	{ Utils.TemplateRenderer, [render: 1]},
	      	{ Phoenix.HTML, [raw: 1]},
	      	{ Utils.TemplateRenderer, [webpack: 1] }
	      ])	      
	      |> Phoenix.HTML.safe_to_string
	  end

	def webpack(path) do
		if Application.get_env(:app, :env) == :production do
			"/static/dist/" <> path
		else
			case :gen_tcp.listen(9000, []) do
				{:error, :eaddrinuse} -> "http://127.0.0.1:9000/" <> path
				{:ok, port} -> Port.close port
					"/static/dist/" <> path
			end
		end
	end
end