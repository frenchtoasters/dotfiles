local actions = require('telescope.actions')
local cmp = require('cmp')
local lspconfig = require('lspconfig')
local opts = { noremap=true, silent=true }

vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.formatting(opts)]]

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

vim.g.mapleader = ','
vim.keymap.set("n","<leader>h",":lua require('harpoon.ui').toggle_quick_menu()<CR>", opts)
vim.keymap.set("n","<leader>m",":lua require('harpoon.mark').add_file()<CR>", opts)
vim.keymap.set("n","<leader>l",":lua require('harpoon.term').gotoTerminal(1)<CR>", opts)
vim.keymap.set("n","<leader>o",":lua require('harpoon.term').gotoTerminal(2)<CR>", opts)
vim.keymap.set("n","<leader>a", ":lua require('harpoon.ui').nav_file(1)<CR>", opts)
vim.keymap.set("n","<leader>s", ":lua require('harpoon.ui').nav_file(2)<CR>", opts)
vim.keymap.set("n","<leader>d", ":lua require('harpoon.ui').nav_file(3)<CR>", opts)
vim.keymap.set("n","<leader>f", ":lua require('harpoon.ui').nav_file(4)<CR>", opts)
vim.keymap.set("n","<leader>bf", ":lua require('telescope.builtin').find_files()<CR>", opts)
vim.keymap.set("n","<leader>g", ":lua require('telescope.builtin').live_grep()<CR>", opts)
vim.keymap.set("n","<leader>tf", ":lua require('telescope.builtin').help_tags()<CR>", opts)
vim.keymap.set("n","<leader>k", ":lua require('telescope').load_extension('k8s_commands').k8s(require('telescope.themes').get_ivy())<CR>", opts)
vim.keymap.set("n","<leader>j", ":lua require('telescope').load_extension('linode_commands').linode_ssh(require('telescope.themes').get_ivy())<CR>", opts)
vim.keymap.set("n","<leader>ps", ":lua require('telescope').load_extension('docker_commands').docker_version(require('telescope.themes').get_ivy())<CR>", opts)
vim.keymap.set("n","<leader>y", ":lua require('telescope').load_extension('neoclip').neoclip(require('telescope.themes').get_ivy())<CR>", opts)
vim.keymap.set("t","<Esc>", "<C-\\><C-n>", opts)
vim.keymap.set('n', '<leader>e', ":Ex<CR>", opts)
vim.keymap.set("n","<leader><down>","<C-W><down>", opts)
vim.keymap.set("n","<leader><up>","<C-W><up>", opts)
vim.keymap.set("n","<leader><left>","<C-W><left>", opts)
vim.keymap.set("n","<leader><right>","<C-W><right>", opts)

local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', '<leader>Q', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', '<leader>q', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', '<leader>r', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
end

require('nvim-treesitter.configs').setup {
	highlight = {
		enable = true
	},
	textobjects = {
		enable = true
	},
	ensure_installed = {"lua", "python", "go", "yaml", "json", "hcl", "rust"}
}

require("telescope").setup {
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
}

require('nvim_comment').setup {
	comment_empty = false,
	line_mapping = "<leader>cl",
	operator_mapping = "<leader>c"
}

require('nvim-autopairs').setup()
require('harpoon').setup()
require('neoclip').setup {
	default_register = {'"', '+', '*'}
}
require("telescope").load_extension("fzy_native")
require("telescope").load_extension("k8s_commands")
require("telescope").load_extension("linode_commands")
require("telescope").load_extension("neoclip")

require("indent_blankline").setup {
	char = "┊",
	show_current_context = true,
}

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
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
		{ name = 'buffer' },
	}
}

local servers = {"gopls", "terraformls", "dockerls", "bashls", "vimls", "jedi_language_server"}
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		on_attach = on_attach,
		capabilities = capabilities,
	})
end

require('lspconfig').sumneko_lua.setup {
	on_attach = on_attach,
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
	capabilities = capabilities,
}

require'lspconfig'.rust_analyzer.setup {
    capabilities= capabilities,
    on_attach = on_attach,
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = {
          command = "clippy"
        },
      }
    }
}

-- Enable diagnostics
-- vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
--   vim.lsp.diagnostic.on_publish_diagnostics, {
--     virtual_text = false,
--     signs = true,
--     update_in_insert = true,
--   }
-- )
