local function trim(s)
	return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function read_file(path)
	local ok, lines = pcall(vim.fn.readfile, path)
	if not ok then
		return nil
	end
	return table.concat(lines, "\n")
end

local function parse_args(args)
	local raw = args and (args.user_prompt or args.args) or ""
	raw = trim(raw)
	local tokens = {}
	for t in raw:gmatch("%S+") do
		table.insert(tokens, t)
	end
	return tokens[1], raw
end

return {
	context = function(args)
		local project, raw = parse_args(args)
		if not project or project == "" then
			return table.concat({
				"ERROR: missing project name.",
				"Usage: /make-patch project-name",
				"You typed: " .. (raw ~= "" and raw or "(empty)"),
			}, "\n")
		end

		local up_path = ("./cmd/%s-up.go"):format(project)
		local tilt_path = ("./assets/%s.Tiltfile"):format(project)

		local up_src = read_file(up_path) or ""
		local tilt_src = read_file(tilt_path) or ""

		return table.concat({
			("Project: %s"):format(project),
			("Up file: %s"):format(up_path),
			("Tiltfile: %s"):format(tilt_path),
			"",
			"# cmd/<project>-up.go (current)",
			"```go",
			up_src,
			"```",
			"",
			"# assets/<project>.Tiltfile (current)",
			"```python",
			tilt_src,
			"```",
		}, "\n")
	end,
}
