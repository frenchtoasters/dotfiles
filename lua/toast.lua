local actions = require('telescope.actions')

require('nvim-treesitter').setup {
	ensure_installed = { "lua", "python", "go", "yaml", "json", "hcl", "rust", "markdown", "markdown_inline" },
	sync_install = false,
	auto_install = true,
	ignore_install = {},

	highlight = {
		enable = true,
		additional_vim_regex_highlighting = true,
	},

	textobjects = {
		select = {
			enable = true,
			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
			},
		},
	},
	modules = {}
}

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("treesitter_auto_start", { clear = true }),
	callback = function(ev)
		-- Start TS highlighting if a parser exists; ignore errors for ft with no parser
		pcall(vim.treesitter.start, ev.buf)
	end,
})


require("telescope").setup {
	defaults = {
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
	default_register = { '"', '+', '*' }
}
require("telescope").load_extension("fzy_native")
require("telescope").load_extension("k8s_commands")
require("telescope").load_extension("linode_commands")
require("telescope").load_extension("neoclip")

local highlight = {
	"RainbowRed",
	"RainbowYellow",
	"RainbowBlue",
	"RainbowOrange",
	"RainbowGreen",
	"RainbowViolet",
	"RainbowCyan",
}

local hooks = require "ibl.hooks"
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
	vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
	vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
	vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
	vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
	vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
	vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
	vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
end)

require("ibl").setup {
	indent = {
		highlight = highlight
	},
	scope = {
		enabled = false
	}
}

require("obsidian").setup({
	workspaces = {
		{
			name = "Work",
			path = "/Volumes/homes/toast/Notes/AppDat",
			strict = false,
		}
	},
	daily_notes = {
		folder = "DailyNotes",
		template = "Daily_Template"
	},
	templates = {
		folder = "Templates",
	},
	ui = {
		enable = false,
	}
})

require('fga').setup({
	-- install_treesitter_grammar = true,
	lsp_server = "/Users/tfrench/.config/nvim/plugged/vscode-ext/server/out/server.node.js"
})

require('gemini').setup({
	model = "gemini-3-pro",
	max_output_token = 81960,
	task = {
		get_system_text = function()
			return 'You are an AI assistant that helps user write code.\n'
				.. 'Your output should be a code diff for git. It should only contain changes for the code that was highlighted.'
		end,
	}
})

require('todo-comments').setup()
require('yaml-companion').setup()

require('go').setup()
require("codecompanion").setup({
	prompt_library = {
		markdown = {
			dirs = {
				vim.fn.getcwd() .. "/.prompts",
				"~/.config/nvim/prompts",
			},
		},
	},
	strategies = {
		chat = {
			-- adapter = "gemini",
			-- model = "models/gemini-3-pro",
			adapter = "local_chat",
		},
		inline = {
			adapter = "gemini",
			model = "models/gemini-3-pro",
		},
		cmd = {
			adapter = "gemini",
			model = "models/gemini-3-pro",
		}
	},
	adapters = {
		openai = function()
			return require("codecompanion.adapters").extend("openai", {
				env = {
					api_key = "echo $OPENAPI_API_KEY",
				},
			})
		end,
		http = {
			local_chat = function()
				return require("codecompanion.adapters").extend("openai_compatible", {
					env = {
						-- url = "http://spark-f6cd.local:8000",
						-- url = "http://localhost:4000",
						url = "http://jeeves-studio-21.local:52415",
						chat_url = "/v1/chat/completions",
						api_key = "sk-1234",
					},
					schema = {
						model = {
							-- default = "mlx-community/GLM-4.7-8bit-gs32",
							default = "mlx-community/GLM-4.7-Flash-8bit",
						}
					},
					-- model = "jeeves"
					-- model = "auto"
					-- model = "mlx-community/GLM-4.7-8bit-gs32",
				})
			end,
		},
	},
	rules = {
		speedy = {
			description = "Rules file for the speedy project",
			files = {
				"~/.config/nvim/rules/speedy.md",
			},
		},
	},
	display = {
		action_palette = {
			opts = {
				show_prompt_library_builtins = false,
			}
		},
	},
	extensions = {
		mcphub = {
			callback = "mcphub.extensions.codecompanion",
			opts = {
				make_tools = true,
				show_server_tools_in_chat = true,
				add_mcp_prefix_to_tool_names = false,
				show_result_in_chat = true,
				format_tool = nil,
				make_vars = true,
				make_slash_commands = true,
			}
		}
	}
})

require("extensions.fidget-spinner"):init()
require("fidget").setup()

require("mcphub").setup()
