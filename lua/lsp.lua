local cmp = require("cmp")
local lspconfig = require('lspconfig')
local mason_registry = require("mason-registry")
local servers = { "gopls", "terraform-ls", "vim-language-server", "python-lsp-server", "lua-language-server",
	"rust-analyzer", "yaml-language-server", "typescript-language-server" }

cmp.setup {
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		['<C-d>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.close(),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
	}),
	sources = {
		{ name = 'luasnip' },
		{ name = 'nvim_lsp' },
		{ name = 'buffer' },
	}
}


local on_attach = function(_, bufnr)
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set('n', '<leader>Q', vim.lsp.buf.declaration, bufopts)
	vim.keymap.set('n', '<leader>q', vim.lsp.buf.definition, bufopts)
	vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
	vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
	vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
	vim.keymap.set('n', '<leader>r', vim.lsp.buf.references, bufopts)
	vim.keymap.set('n', '<space>f', vim.lsp.buf.format, bufopts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
	vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
	vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
	vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, bufopts)
	vim.keymap.set('n', '<space>l', vim.diagnostic.setloclist, bufopts)
end

local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

require('mason').setup()
-- Install LSP servers via mason
for _, server in ipairs(servers) do
	local pkg = mason_registry.get_package(server)
	if not pkg:is_installed() then
		pkg:install()
	end
end

lspconfig.gopls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

lspconfig.terraformls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

lspconfig.vimls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

lspconfig.pylsp.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

lspconfig.ts_ls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

lspconfig.lua_ls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	root_dir = function() return vim.fn.getcwd() end,
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
				path = {
					"?.lua", "?/init.lua",
					vim.fn.expand("$VIMRUNTIME/lua/?.lua"),
					vim.fn.expand("$VIMRUNTIME/lua/?/init.lua"),
				},
			},
			diagnostics = {
				globals = { "vim" },
			},
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

lspconfig.rust_analyzer.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		["rust-analyzer"] = {
			checkOnSave = { command = "clippy" },
		},
	},
})

local cfg = require('yaml-companion').setup()
require("lspconfig").yamlls.setup(cfg)
-- Prevent rogue lua_ls attach
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client.name == "lua_ls" and client.config.root_dir == nil then
			client.stop()
			vim.notify("Stopped unintended lua_ls attach", vim.log.levels.WARN)
		end
	end,
})
