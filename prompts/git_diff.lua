local function run(cmd)
	local res = vim.system(cmd, { text = true }):wait()
	local out = (res.stdout or ""):gsub("%s+$", "")
	local err = (res.stderr or ""):gsub("%s+$", "")
	if out == "" and err ~= "" then
		return err
	end
	return out
end

return {
	diff = function()
		local unstaged = run({ "git", "diff", "--no-ext-diff" })
		local staged = run({ "git", "diff", "--no-ext-diff", "--staged" })
		local status = run({ "git", "status", "--porcelain=v1", "-uall" })

		local parts = {}

		table.insert(parts, "## git status (porcelain)")
		table.insert(parts, status ~= "" and status or "(clean)")

		table.insert(parts, "")
		table.insert(parts, "## unstaged diff")
		table.insert(parts, unstaged ~= "" and unstaged or "(none)")

		table.insert(parts, "")
		table.insert(parts, "## staged diff")
		table.insert(parts, staged ~= "" and staged or "(none)")

		return table.concat(parts, "\n")
	end,
}
