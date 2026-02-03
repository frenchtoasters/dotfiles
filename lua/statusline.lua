local M = {}

local function hl(name, opts)
	vim.api.nvim_set_hl(0, name, opts)
end

local function mode_label()
	local m = vim.fn.mode(1)
	local map = {
		n     = "NORMAL",
		no    = "N-PENDING",
		i     = "INSERT",
		ic    = "INSERT",
		v     = "VISUAL",
		V     = "V-LINE",
		[""] = "V-BLOCK",
		s     = "SELECT",
		S     = "S-LINE",
		[""] = "S-BLOCK",
		R     = "REPLACE",
		Rc    = "REPLACE",
		c     = "COMMAND",
		cv    = "EX",
		ce    = "EX",
		r     = "PROMPT",
		rm    = "MORE",
		t     = "TERMINAL",
	}
	return map[m] or m
end

local function git_branch()
	local b = vim.b.gitsigns_head
	if type(b) == "string" and b ~= "" then
		return " " .. b
	end
	return ""
end

local function lsp_clients()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if not clients or #clients == 0 then return "" end

	local names = {}
	for _, c in ipairs(clients) do
		if c and c.name then
			names[#names + 1] = c.name
		end
	end

	if #names == 0 then return "" end
	return " " .. table.concat(names, ",")
end

local function diag_counts()
	local diags = vim.diagnostic.get(0)
	if not diags or #diags == 0 then return "" end

	local e, w, i, h = 0, 0, 0, 0
	for _, d in ipairs(diags) do
		local s = d.severity
		if s == vim.diagnostic.severity.ERROR then
			e = e + 1
		elseif s == vim.diagnostic.severity.WARN then
			w = w + 1
		elseif s == vim.diagnostic.severity.INFO then
			i = i + 1
		elseif s == vim.diagnostic.severity.HINT then
			h = h + 1
		end
	end

	local parts = {}
	if e > 0 then parts[#parts + 1] = "%#StlDiagError# " .. e .. " ✖%*" end
	if w > 0 then parts[#parts + 1] = "%#StlDiagWarn# " .. w .. " ▲%*" end
	if i > 0 then parts[#parts + 1] = "%#StlDiagInfo# " .. i .. " ●%*" end
	if h > 0 then parts[#parts + 1] = "%#StlDiagHint# " .. h .. " ◆%*" end

	return table.concat(parts, " ")
end

function _G.NightlyStatusline()
	local file = vim.fn.expand("%:t")
	if file == "" then file = "[No Name]" end

	local ft = vim.bo.filetype
	if ft == "" then ft = "text" end

	local enc = vim.bo.fileencoding
	if enc == "" then enc = vim.o.encoding end

	local ro = vim.bo.readonly and "" or ""
	local mod = vim.bo.modified and "●" or ""

	local left = table.concat({
		"%#StlMode# ", mode_label(), " %*",
		"%#StlSep#│%* ",
		"%#StlFile#",
		file, " ", mod, ro,
		"%*",
	})

	local branch = git_branch()
	if branch ~= "" then
		left = left .. " " .. "%#StlSep#│%* " .. "%#StlGit#" .. branch .. "%*"
	end

	local lsp = lsp_clients()
	if lsp ~= "" then
		left = left .. " " .. "%#StlSep#│%* " .. "%#StlLsp#" .. lsp .. "%*"
	end

	local diags = diag_counts()
	if diags ~= "" then
		left = left .. " " .. "%#StlSep#│%* " .. diags
	end

	local right = table.concat({
		"%=",
		"%#StlMeta#", ft, " ", enc, "%*",
		" ", "%#StlSep#│%* ",
		"%#StlPos#", "%l:%c", " ", "%p%%", "%*",
		" ",
	})

	return left .. right
end

function M.setup()
	local palette = {
		bg    = "NONE",
		fg    = "#d0d0d0",
		dim   = "#9e9e9e",
		dark  = "#6c6c6c",
		mode  = "#e4e4e4",
		git   = "#87afaf",
		lsp   = "#afafd7",
		info  = "#87afd7",
		warn  = "#d7af5f",
		error = "#d75f5f",
		hint  = "#8a8a8a",
	}

	hl("StatusLine", { fg = palette.fg, bg = palette.bg })
	hl("StatusLineNC", { fg = palette.dark, bg = palette.bg })
	hl("StlMode", { fg = palette.mode, bg = palette.bg, bold = true })
	hl("StlSep", { fg = palette.dim, bg = palette.bg })
	hl("StlFile", { fg = palette.fg, bg = palette.bg })
	hl("StlGit", { fg = palette.git, bg = palette.bg })
	hl("StlLsp", { fg = palette.lsp, bg = palette.bg })
	hl("StlMeta", { fg = palette.dim, bg = palette.bg })
	hl("StlPos", { fg = palette.dim, bg = palette.bg })
	hl("StlDiagError", { fg = palette.error, bg = palette.bg })
	hl("StlDiagWarn", { fg = palette.warn, bg = palette.bg })
	hl("StlDiagInfo", { fg = palette.info, bg = palette.bg })
	hl("StlDiagHint", { fg = palette.hint, bg = palette.bg })

	vim.o.statusline = "%!v:lua.NightlyStatusline()"

	local grp = vim.api.nvim_create_augroup("nightly_statusline", { clear = true })
	vim.api.nvim_create_autocmd(
		{ "BufEnter", "BufWritePost", "DiagnosticChanged", "LspAttach", "LspDetach", "WinEnter", "WinLeave" },
		{ group = grp, callback = function() vim.cmd("redrawstatus") end }
	)

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = grp,
		callback = function()
			hl("StlMode", { bold = true })
			hl("StlSep", { link = "Comment" })
			hl("StlFile", { link = "StatusLine" })
			hl("StlGit", { link = "Identifier" })
			hl("StlLsp", { link = "Function" })
			hl("StlMeta", { link = "Type" })
			hl("StlPos", { link = "StatusLine" })
			hl("StlDiagError", { link = "DiagnosticError" })
			hl("StlDiagWarn", { link = "DiagnosticWarn" })
			hl("StlDiagInfo", { link = "DiagnosticInfo" })
			hl("StlDiagHint", { link = "DiagnosticHint" })
		end,
	})
end

return M
