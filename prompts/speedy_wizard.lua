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

local function parse_args(args)
	local raw = trim((args and (args.user_prompt or args.args)) or "")
	local tokens = {}
	for t in raw:gmatch("%S+") do table.insert(tokens, t) end

	local project = tokens[1]
	local with_up = false
	local steps = nil

	-- Allow: --with-up and --steps="..."
	for i, t in ipairs(tokens) do
		if t == "--with-up" or t == "--up" then with_up = true end
		if t:match("^%-%-steps=") then
			steps = t:gsub("^%-%-steps=", "")
			steps = steps:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")
		end
	end

	return {
		project = project,
		with_up = with_up,
		steps = steps,
		raw = raw,
	}
end

return {
	-- Runs generators and returns context (files + diffs) for the LLM
	context = function(args)
		local a = parse_args(args)

		if not a.project or a.project == "" then
			return table.concat({
				"ERROR: missing project name.",
				"",
				"Usage:",
				"  /project-wizard project-name",
				"  /project-wizard project-name --with-up --steps=\"uv venv; uv pip sync pyproject.toml; gcloud config set project X; uv run python server.py\"",
				"",
				"You typed:",
				a.raw ~= "" and a.raw or "(empty)",
			}, "\n")
		end

		-- Always generate the tiltfile
		local gen_tilt = run({ "./bin/speedy", "generate-tiltfile", "-p", a.project })

		-- Optionally generate the up scaffold
		local gen_up = nil
		if a.with_up then
			gen_up = run({ "./bin/speedy", "generate", "-n", a.project .. "-up" })
		end

		local tilt_path = ("./assets/%s.Tiltfile"):format(a.project)
		local up_path = ("./cmd/%s-up.go"):format(a.project)

		local tilt_src = read_file(tilt_path)
		local up_src = read_file(up_path)

		local status = run({ "git", "status", "--porcelain=v1", "-uall" })
		local diff_unstaged = run({ "git", "diff", "--no-ext-diff" })
		local diff_staged = run({ "git", "diff", "--no-ext-diff", "--staged" })

		return table.concat({
			("Project: `%s`"):format(a.project),
			("Mode: %s"):format(a.with_up and "with-up" or "tilt-only"),
			("Steps provided inline: %s"):format(a.steps and "yes" or "no"),
			"",
			"# Generator output",
			"## generate-tiltfile",
			gen_tilt ~= "" and gen_tilt or "(no output)",
			"",
			"## generate (up scaffold)",
			a.with_up and (gen_up ~= "" and gen_up or "(no output)") or "(skipped)",
			"",
			"# Generated / current files",
			("## %s"):format(tilt_path),
			tilt_src and ("```python\n" .. tilt_src .. "\n```") or "(missing)",
			"",
			("## %s"):format(up_path),
			up_src and ("```go\n" .. up_src .. "\n```") or "(missing)",
			"",
			"# Repo diffs (current working tree)",
			"## git status",
			status ~= "" and status or "(clean)",
			"",
			"## git diff (unstaged)",
			diff_unstaged ~= "" and diff_unstaged or "(none)",
			"",
			"## git diff (staged)",
			diff_staged ~= "" and diff_staged or "(none)",
			"",
			"# Inline steps string (if provided)",
			a.steps and a.steps or "(none)",
		}, "\n")
	end,

	-- Exposes parsed args to the markdown via ${project_wizard.args}
	args = function(args)
		local a = parse_args(args)
		return table.concat({
			"project=" .. (a.project or ""),
			"with_up=" .. tostring(a.with_up),
			"steps=" .. (a.steps or ""),
			"raw=" .. (a.raw or ""),
		}, "\n")
	end,
}
