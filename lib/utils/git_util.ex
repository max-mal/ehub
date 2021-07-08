defmodule Utils.GitUtil do
	@storage "storage/repos"

	def init(name, namespace) do
		path = Utils.GitUtil.get_path(name, namespace)
	    case System.cmd("bash", ["-c", "mkdir -p #{path} && cd #{path} && git init --bare"]) do
	    	{_, 0} -> :ok
	    	_ -> :err
	    end
	end

	def exists?(name, namespace) do
		path = Utils.GitUtil.get_path(name, namespace)
		File.exists?(path)
	end

	def get_path(name, namespace) do
		@storage
	      |> Path.join(namespace)
	      |> Path.join(name)
	      |> Path.absname
	end

	def branch_list(name, namespace) do
		path = Utils.GitUtil.get_path(name, namespace)
		{output, 0} = System.cmd("bash", ["-c", "cd #{path} && git branch -a"])
		output |> String.replace("*", "")
			|> String.split("\n")
			|> Enum.map(fn x -> String.trim(x) end)
			|> Enum.filter(fn x -> String.length(x) > 0 end)
	end

	def create_branch(name, namespace, branch, source_branch \\ "") do
		branch = Shell.escape_value(branch)
		source_branch = Shell.escape_value(source_branch)
		path = Utils.GitUtil.get_path(name, namespace)

		{_, code} = System.cmd("bash", ["-c", "cd #{path} && git branch #{branch} #{source_branch}"])
		code == 0
	end

	def delete_branch(name, namespace, branch) do
		branch = Shell.escape_value(branch)
		path = Utils.GitUtil.get_path(name, namespace)
		{_, code} = System.cmd("bash", ["-c", "cd #{path} && git branch -D #{branch}"])
		code == 0
	end

	def create_readme(name, namespace, contents \\ "") do
		path = Utils.GitUtil.get_path(name, namespace)
		timestamp = :os.system_time(:millisecond)
		tmp_path = "/tmp/tmp_repo_#{name}_#{namespace}_#{timestamp}"

		System.cmd("bash", ["-c", "git clone #{path} #{tmp_path}"])
		File.write!(Path.join(path, "/README.md"), contents)
		System.cmd("bash", ["-c", "cd #{tmp_path} && git add . && git commit -m \"Added README.md\" && git push "])
		System.cmd("bash", ["-c", "rm -rf #{tmp_path}"])
	end

	def get_files(name, namespace, branch, directory \\ "") do
		gitDirectory = if directory == "" do
			"."
		else
			directory
		end

		path = Utils.GitUtil.get_path(name, namespace)
		{output, 0} = System.cmd("git", ["--git-dir=#{path}", "ls-tree",  "#{branch}", "#{gitDirectory}"])
		output |> String.replace("\t", " ")
			|> String.split("\n")
			|> Enum.map(fn x -> String.trim(x) end)
			|> Enum.filter(fn x -> String.length(x) > 0 end)
			|> Enum.map(fn x ->
				[mode, type, hash | filename] = x |> String.split(" ")
				filename = Enum.join(filename, " ")
				%{
					filename: String.replace(filename, directory, "", global: false),
					type: type,
					hash: hash,
					mode: mode
				}
			end)

	end

	def file_log(name, namespace, branch, file, count \\ "") do
		args = if count != "" do
			["-n", "#{count}"]
		else
			[]
		end

		path = Utils.GitUtil.get_path(name, namespace)
		{output, 0} = System.cmd("git", ["--git-dir=#{path}", "log",] ++ args ++ ["--pretty=fuller",  "#{branch}", "--", "#{file}"])

		commits = output |> String.split(~r/^commit /m)
		commits |> Enum.filter(fn x -> String.length(x) > 0 end) |> Enum.map(fn commit ->
			Utils.GitUtil.parse_commit(String.split(commit, "\n"))
		end)


	end

	def parse_commit(commit, data \\ %{})
	def parse_commit([head | tail], data) do
		data = cond do
			String.starts_with?(head, "Merge: ") ->
				Map.put(data, :merge, String.replace(head, "Merge: ", ""))
			String.starts_with?(head, "Author: ") ->
				Map.put(data, :author, String.trim(String.replace(head, "Author: ", "")))
			String.starts_with?(head, "AuthorDate: ") ->
				Map.put(data, :author_date, String.replace(head, "AuthorDate: ", ""))
			String.starts_with?(head, "Commit: ") ->
				Map.put(data, :commit, String.trim(String.replace(head, "Commit: ", "")))
			String.starts_with?(head, "CommitDate: ") ->
				Map.put(data, :commit_date, String.replace(head, "CommitDate: ", ""))
			String.length(head) == 40 ->
				Map.put(data, :hash, head)
			true ->
				if data[:message] == nil do
					Map.put(data, :message, String.trim(head))
				else
					Map.put(data, :message, String.trim(data[:message] <> "\n" <> String.trim(head)))
				end
		end
		parse_commit(tail, data)
	end

	def parse_commit([], data) do
		data
	end

	def get_file_contents(name, namespace, branch, file) do
		path = Utils.GitUtil.get_path(name, namespace)
		{output, 0} = System.cmd("git", ["--git-dir=#{path}", "show", "#{branch}:#{file}"])
		is_text = String.valid?(output)
		if is_text == false do
			tmp_id = :base64.encode(:crypto.strong_rand_bytes(10))
			File.write!("/tmp/#{tmp_id}", output)
			{mime_output, _} = System.cmd("file", ["--mime-type", "/tmp/#{tmp_id}"])
			File.rm!("/tmp/#{tmp_id}")
			[_, mime] = mime_output |> String.trim |> String.split(": ")
			%{mime_type: mime}
		else
			%{mime_type: "text/plain", contents: output}
		end
	end

	def get_binary_file_contents(name, namespace, branch, file) do
		path = Utils.GitUtil.get_path(name, namespace)
		{output, 0} = System.cmd("git", ["--git-dir=#{path}", "show", "#{branch}:#{file}"])
		output
	end

	def commit_file(name, namespace, branch, filename, contents, message, username \\ "system", email \\ "system@syst.em") do
		tmp_id = :base64.encode(:crypto.strong_rand_bytes(10))
		tmp_path = "/tmp/#{tmp_id}"
		path = Utils.GitUtil.get_path(name, namespace)
		IO.puts(filename)
		try do
			System.cmd("git", ["clone", "#{path}", "#{tmp_path}", "-b", "#{branch}"])

			System.cmd("git", ["--git-dir=#{tmp_path}/.git", "config", "user.name", "#{username}"])
			System.cmd("git", ["--git-dir=#{tmp_path}/.git", "config", "user.email", "#{email}"])

			File.write!("#{tmp_path}/#{filename}", contents)
			System.cmd("git", ["--git-dir=#{tmp_path}/.git", "--work-tree=#{tmp_path}", "add", "#{tmp_path}/#{filename}"])
			System.cmd("git", ["--git-dir=#{tmp_path}/.git", "commit", "-m", "#{message}"])
			System.cmd("git", ["--git-dir=#{tmp_path}/.git", "push"])
		after
			# File.rm_rf(tmp_path)
		end
		%{status: "ok"}
	end

	def commit_changes(name, namespace, hash) do
		path = Utils.GitUtil.get_path(name, namespace)
		# {output, 0} = System.cmd("git", ["--git-dir=#{path}", "diff", "#{hash}~", "#{hash}"])
		{output, 0} = System.cmd("git", ["--git-dir=#{path}", "show", "#{hash}"])
		files = output |> String.split("diff --git ")
		  |> Enum.filter(fn x -> String.length(x) > 0 and (not String.starts_with?(x, "commit ")) end)
			|> Enum.map(fn string -> String.split(string, "\n") |> Utils.GitUtil.parse_diff end)
		%{
			files: files,
			info: Utils.GitUtil.commit_info(name, namespace, hash)
		}
	end

	def parse_diff(diff_line, data \\ %{hunks: []})
	def parse_diff([head | tail], data) do
		path_regex = ~r/^a\/(?'s_path'.*) b\/(?'d_path'.*)$/
		data = cond do
			String.match?(head, path_regex) ->
				[_, a_path, b_path]	= Regex.run(path_regex, head)
				data = Map.put(data, :a_path, a_path)
				Map.put(data, :b_path, b_path)
			String.starts_with?(head, "new file mode") ->
				Map.put(data, :new_mode, String.replace(head, "new file mode ", ""))
			String.starts_with?(head, "old mode") ->
				Map.put(data, :old_mode, String.replace(head, "old mode ", ""))
			String.starts_with?(head, "new mode") ->
				Map.put(data, :changed_mode, String.replace(head, "new mode ", ""))
			String.starts_with?(head, "deleted file mode") ->
				Map.put(data, :deleted_mode, String.replace(head, "deleted file mode ", ""))
			String.starts_with?(head, "similarity index") ->
				Map.put(data, :similarity_index, String.replace(head, "similarity index ", ""))
			String.starts_with?(head, "rename from") ->
				Map.put(data, :rename_from, String.replace(head, "rename from ", ""))
			String.starts_with?(head, "rename to") ->
				Map.put(data, :rename_to, String.replace(head, "rename to ", ""))
			String.starts_with?(head, "---") ->
				Map.put(data, :del_path, String.replace(head, "--- ", ""))
			String.starts_with?(head, "+++") ->
				Map.put(data, :add_path, String.replace(head, "+++ ", ""))
			String.match?(head, ~r/^index ([A-z0-9]*)..([A-z0-9]*) ?(.{1,})?/) ->
				case Regex.run(~r/^index ([A-z0-9]*)..([A-z0-9]*) ?(.{1,})?/, head) do
					[_, from, to] ->
						data = Map.put(data, :blob_a, from)
						Map.put(data, :blob_b, to)
					[_, from, to, mode] ->
						data = Map.put(data, :blob_a, from)
						data = Map.put(data, :blob_b, to)
						Map.put(data, :mode, mode)
				end
			String.match?(head, ~r/^@@ [-+0-9,]* [-+0-9,]* @@/) ->
				[_, from, to, rests] = Regex.run(~r/^@@ ([-+0-9,]*) ([-+0-9,]*) @@(.*)/, head)
				data =  Map.put(data, :hunk_signatures, Map.get(data, :hunk_signatures, []) ++ [%{start: from, end: to}])
				case Map.get(data, :current_hunk) do
					nil -> Map.put(data, :current_hunk, [rests])
					hunk ->
						data = Map.put(data, :hunks, Map.get(data, :hunks) ++ [hunk])
						# Map.delete(data, :current_hunk)
						Map.put(data, :current_hunk, [rests])
				end
			true ->
				case Map.get(data, :current_hunk) do
					nil -> data
					hunk -> Map.put(data, :current_hunk, hunk ++ [head])
				end
		end
		parse_diff(tail, data)
	end

	def parse_diff([], data) do
		data = case Map.get(data, :current_hunk) do
			nil -> data
			hunk ->
				data = Map.put(data, :hunks, Map.fetch!(data, :hunks) ++ [hunk])
				Map.delete(data, :current_hunk)
		end
		Map.put(data, :hunks, Map.get(data, :hunks, []) |> Enum.map(fn hunk -> Enum.join(hunk, "\n") |> String.trim end))
	end

	def commit_info(name, namespace, hash) do
		path = Utils.GitUtil.get_path(name, namespace)
		{output, 0} = System.cmd("git", ["--git-dir=#{path}", "log", "--pretty=fuller",  "#{hash}", "-n", "1"])

		commits = output |> String.split(~r/^commit /m)
		commits |> Enum.filter(fn x -> String.length(x) > 0 end) |> Enum.map(fn commit ->
			Utils.GitUtil.parse_commit(String.split(commit, "\n"))
		end) |> List.first
	end
end
