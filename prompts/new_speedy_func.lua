local function trim(s)
	return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function run(cmd, cwd)
	local res = vim.system(cmd, { text = true, cwd = cwd }):wait()
	local out = trim(res.stdout)
	local err = trim(res.stderr)
	if out == "" and err ~= "" then
		return err
	end
	return out
end

local function parse_args(args)
	-- CodeCompanion passes args into the function; for slash prompts the user text
	-- ends up in args.user_prompt (and sometimes args.args). Handle both.
	local raw = args and (args.user_prompt or args.args) or ""
	raw = trim(raw)

	local tokens = {}
	for t in raw:gmatch("%S+") do
		table.insert(tokens, t)
	end

	local project = tokens[1]
	local with_up = false
	for _, t in ipairs(tokens) do
		if t == "--with-up" or t == "--up" then
			with_up = true
		end
	end

	return project, with_up, raw
end

return {
	plan = function(args)
		local project, with_up, raw = parse_args(args)

		if not project or project == "" then
			return table.concat({
				"ERROR: missing project name.",
				"",
				"Usage:",
				"  /new-cli-fn project-name",
				"  /new-cli-fn project-name --with-up",
				"",
				"You typed:",
				raw ~= "" and raw or "(empty)",
			}, "\n")
		end

		-- Run generators
		local gen_tilt = run({ "./bin/speedy", "generate-tiltfile", "-p", project })

		local gen_up = ""
		if with_up then
			gen_up = run({ "./bin/speedy", "generate", "-n", project .. "-up" })
		end

		-- Collect diffs + status
		local status = run({ "git", "status", "--porcelain=v1", "-uall" })
		local diff_unstaged = run({ "git", "diff", "--no-ext-diff" })
		local diff_staged = run({ "git", "diff", "--no-ext-diff", "--staged" })

		local parts = {}

		table.insert(parts, "# Generator output")
		table.insert(parts, "")
		table.insert(parts, "## generate-tiltfile")
		table.insert(parts, gen_tilt ~= "" and gen_tilt or "(no output)")

		if with_up then
			table.insert(parts, "")
			table.insert(parts, "## generate (up scaffold)")
			table.insert(parts, gen_up ~= "" and gen_up or "(no output)")
		end

		table.insert(parts, "")
		table.insert(parts, "# Repo changes")
		table.insert(parts, "")
		table.insert(parts, "## git status (porcelain)")
		table.insert(parts, status ~= "" and status or "(clean)")

		table.insert(parts, "")
		table.insert(parts, "## unstaged diff")
		table.insert(parts, diff_unstaged ~= "" and diff_unstaged or "(none)")

		table.insert(parts, "")
		table.insert(parts, "## staged diff")
		table.insert(parts, diff_staged ~= "" and diff_staged or "(none)")

		-- Helpful reminders for the LLM response
		table.insert(parts, "")
		table.insert(parts, "# Prompt hints")
		table.insert(parts, "")
		table.insert(parts, ("Project name: `%s`"):format(project))
		table.insert(parts, ("Scaffolded up command: `%s`"):format(with_up and "yes" or "no"))
		table.insert(parts, ("Expected tiltfile path: `./assets/%s.Tiltfile`"):format(project))
		if with_up then
			table.insert(parts, ("Expected up scaffold path: `./cmd/%s-up.go`"):format(project))
		end

		return table.concat(parts, "\n")
	end,
}
