local cmp = require("cmp")
local mason_registry = require("mason-registry")

local mason_packages = {
	"gopls",
	"vim-language-server",
	"python-lsp-server",
	"lua-language-server",
	"rust-analyzer",
	"yaml-language-server",
	"typescript-language-server",
	"terraform-ls",
}

cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.close(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = {
		{ name = "luasnip" },
		{ name = "nvim_lsp" },
		{ name = "buffer" },
	},
})

local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("my.lsp.attach", { clear = true }),
	callback = function(args)
		local bufnr = args.buf

		vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

		local bufopts = { noremap = true, silent = true, buffer = bufnr }

		vim.keymap.set("n", "<leader>Q", vim.lsp.buf.declaration, bufopts)
		vim.keymap.set("n", "<leader>q", vim.lsp.buf.definition, bufopts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
		vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
		vim.keymap.set("n", "<leader>r", vim.lsp.buf.references, bufopts)
		vim.keymap.set("n", "<space>f", function()
			vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 3000 })
		end, bufopts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)

		vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, bufopts)
		vim.keymap.set("n", "]d", vim.diagnostic.goto_next, bufopts)
		vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, bufopts)
		vim.keymap.set("n", "<space>l", vim.diagnostic.setloclist, bufopts)

		vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
		vim.diagnostic.config({
			virtual_text = true,
		})
	end,
})

require("mason").setup()

for _, pkg_name in ipairs(mason_packages) do
	local ok, pkg = pcall(mason_registry.get_package, pkg_name)
	if ok and pkg and not pkg:is_installed() then
		pkg:install()
	end
end

vim.lsp.config("*", {
	capabilities = capabilities,
	root_markers = { ".git" },
})

vim.lsp.config("gopls", {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_markers = { "go.work", "go.mod", ".git" },
})
vim.lsp.enable("gopls")

vim.lsp.config("terraformls", {
	cmd = { "terraform-ls", "serve" },
	filetypes = { "terraform", "tf", "hcl" },
	root_markers = { ".terraform", ".git" },
})
-- vim.lsp.enable("terraformls")

vim.lsp.config("vimls", {
	cmd = { "vim-language-server", "--stdio" },
	filetypes = { "vim" },
	root_markers = { ".git" },
})
vim.lsp.enable("vimls")

vim.lsp.config("pylsp", {
	cmd = { "pylsp" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
	settings = {
		pylsp = {
			plugins = {
				pyflakes = { enabled = true },
				pycodestyle = {
					enabled = true,
					maxLineLength = 120,
				},
				pylsp_mypy = { enabled = false },
				black = {
					enabled = false,
					line_length = 120,
				},
				autopep8 = { enabled = false },
			},
		},
	},
})
vim.lsp.enable("pylsp")

vim.lsp.config("ts_ls", {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
})
vim.lsp.enable("ts_ls")

vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { { ".luarc.json", ".luarc.jsonc" }, ".git" },
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
				path = {
					"?.lua",
					"?/init.lua",
					vim.fn.expand("$VIMRUNTIME/lua/?.lua"),
					vim.fn.expand("$VIMRUNTIME/lua/?/init.lua"),
				},
			},
			diagnostics = { globals = { "vim" } },
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
					[vim.fn.expand("~/.config/nvim/lua")] = true,
				},
				checkThirdParty = false,
			},
			telemetry = { enable = false },
		},
	},
})
vim.lsp.enable("lua_ls")

vim.lsp.config("rust_analyzer", {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = { "Cargo.toml", ".git" },
	settings = {
		["rust-analyzer"] = {
			checkOnSave = { command = "clippy" },
		},
	},
})
vim.lsp.enable("rust_analyzer")

local ok_yaml, yaml_companion = pcall(require, "yaml-companion")
if ok_yaml then
	local cfg = yaml_companion.setup({
	})
	vim.lsp.config("yamlls", cfg)
else
	vim.lsp.config("yamlls", {
		cmd = { "yaml-language-server", "--stdio" },
		filetypes = { "yaml", "yml" },
		root_markers = { ".git" },
	})
end
vim.lsp.enable("yamlls")
