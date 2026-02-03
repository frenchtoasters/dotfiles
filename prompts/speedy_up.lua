local function trim(s) return (s or ""):gsub("^%s+", ""):gsub("%s+$", "") end

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
	return tokens[1], raw
end

return {
	context = function(args)
		local project, raw = parse_args(args)
		if not project or project == "" then
			return table.concat({
				"ERROR: missing project name.",
				"Usage: /fill-up project-name",
				"You typed: " .. (raw ~= "" and raw or "(empty)"),
			}, "\n")
		end

		local up_path = ("./cmd/%s-up.go"):format(project)
		local src = read_file(up_path)

		local status = run({ "git", "status", "--porcelain=v1", "-uall" })
		local diff = run({ "git", "diff", "--no-ext-diff" })

		return table.concat({
			("Project: `%s`"):format(project),
			("Up command path: `%s`"):format(up_path),
			"",
			"# Current generated file",
			src and ("```go\n" .. src .. "\n```")
			or ("(Missing) File not found. Run: ./bin/speedy generate -n " .. project .. "-up"),
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
