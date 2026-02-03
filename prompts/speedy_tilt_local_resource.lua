local function trim(s) return (s or ""):gsub("^%s+", ""):gsub("%s+$", "") end

local function read_file(path)
	local ok, lines = pcall(vim.fn.readfile, path)
	if not ok then return nil end
	return table.concat(lines, "\n")
end

local function run(cmd, cwd)
	local res = vim.system(cmd, { text = true, cwd = cwd }):wait()
	local out, err = trim(res.stdout), trim(res.stderr)
	if out == "" and err ~= "" then return err end
	return out
end

local function parse_args(args)
	local raw = trim((args and (args.user_prompt or args.args)) or "")
	local tokens = {}
	for t in raw:gmatch("%S+") do table.insert(tokens, t) end
	return tokens[1], raw
end

return {
	context = function(args)
		local project, raw = parse_args(args)
		if not project or project == "" then
			return table.concat({
				"ERROR: missing project name.",
				"Usage: /add-local-resource project-name",
				"You typed: " .. (raw ~= "" and raw or "(empty)"),
			}, "\n")
		end

		local tilt_path = ("./assets/%s.Tiltfile"):format(project)
		local src = read_file(tilt_path)

		local status = run({ "git", "status", "--porcelain=v1", "-uall" })
		local diff = run({ "git", "diff", "--no-ext-diff" })

		return table.concat({
			("Project: `%s`"):format(project),
			("Tiltfile: `%s`"):format(tilt_path),
			"",
			"# Current Tiltfile",
			src and ("```python\n" .. src .. "\n```")
			or ("(Missing) File not found. Run: ./bin/speedy generate-tiltfile -p " .. project),
			"",
			"# Repo context",
			"## git status",
			status ~= "" and status or "(clean)",
			"",
			"## git diff (unstaged)",
			diff ~= "" and diff or "(none)",
		}, "\n")
	end,
}
