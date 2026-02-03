local M = {}

local function trim(s)
	return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function run(cmd, cwd)
	local res = vim.system(cmd, { text = true, cwd = cwd }):wait()
	local out, err = trim(res.stdout), trim(res.stderr)
	if out == "" and err ~= "" then return err end
	return out
end

local function read_file(path)
	local ok, lines = pcall(vim.fn.readfile, path)
	if not ok then return nil end
	return table.concat(lines, "\n")
end

local function write_file(path, content)
	-- writefile expects list of lines
	local lines = vim.split(content, "\n", { plain = true })
	vim.fn.writefile(lines, path)
end

local function explode_steps(step_str)
	-- semicolon-separated steps, with args split by spaces.
	-- Example:
	--   uv venv; uv pip sync pyproject.toml; gcloud config set project X; uv run python server.py
	local steps = {}
	step_str = trim(step_str or "")
	if step_str == "" then
		return steps
	end

	for seg in step_str:gmatch("([^;]+)") do
		local s = trim(seg)
		if s ~= "" then
			local argv = {}
			for tok in s:gmatch("%S+") do
				table.insert(argv, tok)
			end
			if #argv > 0 then
				table.insert(steps, argv)
			end
		end
	end
	return steps
end

local function go_string_literal(s)
	-- basic escaping for Go string literal
	s = s or ""
	s = s:gsub("\\", "\\\\"):gsub('"', '\\"')
	return '"' .. s .. '"'
end

local function build_up_go_file(opts)
	-- opts:
	--  project, cmd_var, use_str, project_dir_default, steps (argv arrays), gcloud_project_default
	local project = opts.project
	local cmd_var = opts.cmd_var
	local use_str = opts.use_str or (project .. "-up")

	-- Make steps; each step is {bin,args...}
	local step_calls = {}
	for i, argv in ipairs(opts.steps or {}) do
		local bin = argv[1]
		local args = {}
		for j = 2, #argv do
			table.insert(args, argv[j])
		end

		local goArgs = {}
		table.insert(goArgs, go_string_literal(bin))
		for _, a in ipairs(args) do
			table.insert(goArgs, go_string_literal(a))
		end

		table.insert(step_calls, table.concat({
			('\t\tif err := runStep(%s, projectDir, %s); err != nil {'):format(
				go_string_literal(("Step %d: %s"):format(i, table.concat(argv, " "))),
				table.concat(goArgs, ", ")
			),
			"\t\t\treturn err",
			"\t\t}",
			"",
		}, "\n"))
	end

	local steps_block = (#step_calls > 0) and table.concat(step_calls, "\n") or table.concat({
		"\t\t// TODO: Add bring-up steps.",
		"\t\t// Example:",
		"\t\t// _ = runStep(\"uv venv\", projectDir, \"uv\", \"venv\")",
		"",
	}, "\n")

	local go = table.concat({
		"package cmd",
		"",
		"import (",
		"\t\"fmt\"",
		"\t\"os\"",
		"\t\"os/exec\"",
		"",
		"\t\"github.com/spf13/cobra\"",
		")",
		"",
		("var %sProjectDir string"):format(project:gsub("%W", "_")),
		("var %sGcloudProject string"):format(project:gsub("%W", "_")),
		"",
		"func runStep(stepName, dir, bin string, args ...string) error {",
		"\tfmt.Println(stepName)",
		"\tc := exec.Command(bin, args...)",
		"\tc.Dir = dir",
		"\tc.Stdout = os.Stdout",
		"\tc.Stderr = os.Stderr",
		"\tif err := c.Run(); err != nil {",
		"\t\treturn fmt.Errorf(\"%s failed: %s %v: %w\", stepName, bin, args, err)",
		"\t}",
		"\treturn nil",
		"}",
		"",
		("// %sCmd represents the %s command"):format(cmd_var, use_str),
		("var %s = &cobra.Command{"):format(cmd_var),
		("\tUse:   %s,"):format(go_string_literal(use_str)),
		("\tShort: %s,"):format(go_string_literal("Bring up the " .. project .. " environment")),
		"\tLong: `Bring up the environment for this project by running the required setup steps",
		"\tand then starting the relevant services.`",
		"\tRunE: func(cmd *cobra.Command, args []string) error {",
		"\t\tprojectDir := " .. project:gsub("%W", "_") .. "ProjectDir",
		"\t\tgcloudProject := " .. project:gsub("%W", "_") .. "GcloudProject",
		"\t\tif projectDir == \"\" {",
		"\t\t\twd, err := os.Getwd()",
		"\t\t\tif err != nil {",
		"\t\t\t\treturn fmt.Errorf(\"failed to determine working directory: %w\", err)",
		"\t\t\t}",
		"\t\t\tprojectDir = wd",
		"\t\t}",
		"\t\t_ = gcloudProject // used in step list if present",
		"",
		steps_block,
		"\t\treturn nil",
		"\t},",
		"}",
		"",
		"func init() {",
		("\trootCmd.AddCommand(%s)"):format(cmd_var),
		"",
		("\t%s.Flags().StringVar(&%sProjectDir, \"project-dir\", %s, \"Working directory to run bring-up steps from\")")
			:format(
				cmd_var,
				project:gsub("%W", "_"),
				go_string_literal(opts.project_dir_default or "")
			),
		("\t%s.Flags().StringVar(&%sGcloudProject, \"gcloud-project\", %s, \"gcloud project id to set before starting\")")
			:format(
				cmd_var,
				project:gsub("%W", "_"),
				go_string_literal(opts.gcloud_project_default or "")
			),
		"}",
		"",
	}, "\n")

	return go
end

local function insert_local_resource(tilt_src, project)
	-- Insert after the docker_compose(...) call inside composer()
	-- Assumes the generated file looks like the one you pasted.
	local lines = vim.split(tilt_src or "", "\n", { plain = true })

	local in_composer = false
	local inserted = false
	local docker_compose_seen = false
	local docker_close_line = nil

	for i, line in ipairs(lines) do
		if line:match("^def%s+composer%(%):") then
			in_composer = true
		elseif in_composer and line:match("^%S") and not line:match("^#") and not line:match("^def%s") then
			-- top-level non-indented line ends the function (best-effort)
			in_composer = false
		end

		if in_composer then
			if line:match("^%s+docker_compose%(") then
				docker_compose_seen = true
			elseif docker_compose_seen and line:match("^%s*%)%s*$") then
				-- the close paren line for docker_compose(...)
				docker_close_line = i
				break
			end
		end
	end

	if docker_close_line and not inserted then
		local block = {
			"",
			"    local_resource(",
			("        %q,"):format(project),
			("        serve_cmd = [speedy_bin, %q, \"--issue\", issue],"):format(project .. "-up"),
			"        dir = project_dir,",
			"        labels = [\"addon\"],",
			"        env = {\"ORIGINAL_CWD\": original_cwd},",
			"    )",
		}
		-- insert after docker_close_line
		local out = {}
		for i, line in ipairs(lines) do
			table.insert(out, line)
			if i == docker_close_line then
				for _, b in ipairs(block) do
					table.insert(out, b)
				end
				inserted = true
			end
		end
		return table.concat(out, "\n"), inserted
	end

	return tilt_src, false
end

M.run = function(_args)
	-- Ask user for inputs (reliable, doesn't depend on CodeCompanion args)
	local project = trim(vim.fn.input("Project name (e.g. test-prompts): "))
	if project == "" then
		return "Canceled: no project name provided."
	end

	-- Step 1: generate Tiltfile
	local gen_tilt = run({ "./bin/speedy", "generate-tiltfile", "-p", project })

	-- Ask about up scaffold
	local do_up = (vim.fn.confirm(("Scaffold and customize '%s-up' command?"):format(project), "&Yes\n&No", 1) == 1)

	local gen_up = ""
	local steps_str = ""
	local steps = {}
	local gcloud_project = ""

	if do_up then
		gen_up = run({ "./bin/speedy", "generate", "-n", project .. "-up" })

		steps_str = trim(vim.fn.input(
			"Bring-up steps (semicolon-separated, e.g. 'uv venv; uv pip sync pyproject.toml; ...'): "
		))
		steps = explode_steps(steps_str)

		gcloud_project = trim(vim.fn.input("gcloud project id (optional): "))
	end

	-- Read generated files
	local tilt_path = ("./assets/%s.Tiltfile"):format(project)
	local up_path = ("./cmd/%s-up.go"):format(project)

	local tilt_src = read_file(tilt_path) or ""
	local up_src = read_file(up_path) -- may be nil if do_up is false

	-- If we have up scaffold, rewrite it with a real implementation
	if do_up then
		if not up_src then
			return table.concat({
				"ERROR: Up scaffold file not found after generation.",
				("Expected: %s"):format(up_path),
			}, "\n")
		end

		-- Derive command var + Use string from scaffold
		local cmd_var = up_src:match("var%s+([%w_]+)%s*=%s*&cobra%.Command")
		cmd_var = cmd_var or (project:gsub("%W", ""):gsub("^%l", string.upper) .. "UpCmd")

		local use_str = up_src:match('Use:%s+"([^"]+)"')
		use_str = use_str or (project .. "-up")

		-- Default dir: prefer compose_file_abs_dir if present in Tiltfile; else blank -> cwd
		local compose_dir = tilt_src:match("^compose_file_abs_dir%s*=%s*os%.path%.join%([^%)]*%)")
		local project_dir_default = "" -- let it default to os.Getwd() in runtime if empty

		local new_up = build_up_go_file({
			project = project,
			cmd_var = cmd_var,
			use_str = use_str,
			project_dir_default = project_dir_default,
			gcloud_project_default = gcloud_project,
			steps = steps,
		})
		write_file(up_path, new_up)

		-- Now ensure Tiltfile gets local_resource inserted
		local new_tilt, inserted = insert_local_resource(tilt_src, project)
		if inserted then
			write_file(tilt_path, new_tilt)
		end
	end

	-- Return patch
	local patch = run({ "git", "diff", "--no-ext-diff" })
	local status = run({ "git", "status", "--porcelain=v1", "-uall" })

	return table.concat({
		"# Generator output",
		"## generate-tiltfile",
		gen_tilt ~= "" and gen_tilt or "(no output)",
		"",
		"## generate (up scaffold)",
		do_up and (gen_up ~= "" and gen_up or "(no output)") or "(skipped)",
		"",
		"# Summary",
		("Project: %s"):format(project),
		("Up scaffold/customized: %s"):format(do_up and "yes" or "no"),
		do_up and ("Steps: " .. (steps_str ~= "" and steps_str or "(none)")) or "",
		"",
		"# git status",
		status ~= "" and status or "(clean)",
		"",
		"# PATCH (apply with: git apply -p0)",
		patch ~= "" and patch or "(no diff)",
	}, "\n")
end

return M
