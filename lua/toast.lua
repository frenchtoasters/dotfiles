local actions = require('telescope.actions')
local cmp = require('cmp')
local lspconfig = require('lspconfig')
local servers = {"gopls", "terraformls", "dockerls", "bashls", "vimls"}

USER = vim.fn.expand('$USER')

local sumneko_root_path = ""
local sumneko_binary = ""

if vim.fn.has("mac") == 1 then
    sumneko_root_path = "/Users/" .. USER .. "/.config/nvim/lua-language-server"
    sumneko_binary = "/Users/" .. USER .. "/.config/nvim/lua-language-server/bin/macOS/lua-language-server"
elseif vim.fn.has("unix") == 1 then
    sumneko_root_path = "/home/" .. USER .. "/.config/nvim/lua-language-server"
    sumneko_binary = "/home/" .. USER .. "/.config/nvim/lua-language-server/bin/Linux/lua-language-server"
else
    print("Unsupported system for sumneko")
end

require("telescope").setup({
	defaults= {
		file_sorter = require("telescope.sorters").get_fzy_sorter,
		prompt_prefix = " > ",
		color_devicons = true,
		file_previewer = require("telescope.previewers").vim_buffer_cat.new,
		grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
		qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
		mappings = {
			i = {
				["<esc>"] = actions.close,
			}
		}
	},
	pickers = {
		find_files = {
			theme = "ivy",
		},
		live_grep = {
			theme = "ivy",
		},
		buffers = {
			theme = "ivy",
		},
		help_tags = {
			theme = "ivy",
		},
	},
	extensions = {
		k8s_commands = {
			kubeconfig = "/users/tfrench/kube/kubeconfig/tfrench"
		},
	}
})

require('nvim_comment').setup({
	comment_empty = false,
	line_mapping = "<leader>cl",
	operator_mapping = "<leader>c"
})

require('nvim-treesitter.configs').setup({
	highlight = {
		enable = true
	},
	textobjects = {
		enable = true
	},
	ensure_installed = "maintained"
})

require('nvim-autopairs').setup()
require('harpoon').setup()
require('neoclip').setup({
	default_register = {'"', '+', '*'}
})
require("telescope").load_extension("fzy_native")
require("telescope").load_extension("k8s_commands")
require("telescope").load_extension("linode_commands")
require("telescope").load_extension("neoclip")
-- require("telescope").load_extension("docker_commands")

require("indent_blankline").setup({
	char = "┊",
	show_current_context = true,
})

cmp.setup({
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
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
		{ name = 'buffer' },
	},
})

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
	})
end
-- require('lspconfig').pyright.setup{}
require'lspconfig'.jedi_language_server.setup{}
require('lspconfig').sumneko_lua.setup {
    cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
                path = vim.split(package.path, ';')
            },
            diagnostics = {
                globals = {'vim'}
            },
            workspace = {
                library = {[vim.fn.expand('$VIMRUNTIME/lua')] = true, [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true}
            }
        }
    },
	capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
}

