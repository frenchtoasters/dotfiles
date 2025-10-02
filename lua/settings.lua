local opts                              = { noremap = true, silent = true }

local set                               = vim.opt
set.tabstop                             = 4
set.shiftwidth                          = 4
set.laststatus                          = 2
set.textwidth                           = 0
set.colorcolumn                         = '80'
set.wildmode                            = 'longest,list,full'
set.encoding                            = 'utf-8'
set.clipboard                           = 'unnamedplus'
set.smarttab                            = true
set.autoindent                          = true
set.incsearch                           = true
set.ignorecase                          = true
set.smartcase                           = true
set.hlsearch                            = true
set.ruler                               = true
set.showcmd                             = true
set.showmode                            = true
set.wrap                                = true
set.breakindent                         = true
set.hidden                              = true
set.number                              = true
set.relativenumber                      = true
set.title                               = true
set.termguicolors                       = true
set.list                                = true
set.foldmethod                          = 'indent'
set.listchars                           = 'trail:┊,tab:┊ '
vim.g['blamer_enabled']                 = 1
vim.g['go_highlight_build_constraints'] = 1
vim.g['go_highlight_extra_types']       = 1
vim.g['go_highlight_fields']            = 1
vim.g['go_highlight_functions']         = 1
vim.g['go_highlight_methods']           = 1
vim.g['go_highlight_operators']         = 1
vim.g['go_highlight_structs']           = 1
vim.g['go_highlight_types']             = 1
vim.g['go_auto_sameids']                = 0
vim.g['go_auto_type_info']              = 1
vim.g['go_addtags_transform']           = 'snakecase'
vim.g['airline#extensions#ale#enabled'] = 1
vim.g['airline_powerline_fonts']        = 1
vim.g['airline_section_z']              = ' %{strftime("%-I:%M %p")}'
vim.g['airline_section_warning']        = ''
vim.g['ale_sign_error']                 = '⤫'
vim.g['ale_sign_warning']               = '⚠'
vim.g['startify_fortune_use_unicode']   = 1
vim.g['signify_sign_add']               = '│'
vim.g['signify_sign_delete']            = '│'
vim.g['signify_sign_change']            = '│'
vim.g['cursorhold_updatetime']          = 100
vim.g['seoul256_srgb']                  = 1
vim.g['jedi#goto_command']              = "<leader>t"
vim.g['jedi#goto_assignments_command']  = "<leader>>"
vim.g['jedi#goto_stubs_command']        = "<leader>."
vim.g['jedi#completions_enabled']       = 0
vim.g['jedi#show_call_signatures']      = 0
vim.g['go_addtags_transform']           = 'camelcase'
vim.cmd [[
	syntax on
]]
vim.g.go_gopls_enabled = 0
vim.g.go_fmt_autosave = 0
vim.g.go_imports_autosave = 0
vim.g.go_def_mapping_enabled = 0
vim.g.go_doc_keywordprg_enabled = 0
vim.g.go_auto_type_info = 0
vim.g.go_highlight_types = 0
vim.g.go_code_completion_enabled = 0

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	update_in_insert = true,
	underline = true,
	severity_sort = true,
	virtual_lines = { only_current_line = false },
})

vim.cmd [[autocmd BufWritePre *.* lua vim.lsp.buf.format(opts)]]
vim.cmd [[autocmd BufWritePre *.go lua vim.cmd("GoImports")]]

vim.cmd [[autocmd BufEnter *.tf lua vim.api.nvim_buf_set_option(0, "commentstring", "# %s")]]
vim.cmd [[autocmd BufFilePost *.tf lua vim.api.nvim_buf_set_option(0, "commentstring", "# %s")]]

vim.g.mapleader = ','
vim.keymap.set("n", "<leader>h", ":lua require('harpoon.ui').toggle_quick_menu()<CR>", opts)
vim.keymap.set("n", "<leader>m", ":lua require('harpoon.mark').add_file()<CR>", opts)
vim.keymap.set("n", "<leader>l", ":lua require('harpoon.term').gotoTerminal(1)<CR>", opts)
vim.keymap.set("n", "<leader>o", ":lua require('harpoon.term').gotoTerminal(2)<CR>", opts)
vim.keymap.set("n", "<leader>a", ":lua require('harpoon.ui').nav_file(1)<CR>", opts)
vim.keymap.set("n", "<leader>s", ":lua require('harpoon.ui').nav_file(2)<CR>", opts)
vim.keymap.set("n", "<leader>d", ":lua require('harpoon.ui').nav_file(3)<CR>", opts)
vim.keymap.set("n", "<leader>f", ":lua require('harpoon.ui').nav_file(4)<CR>", opts)
vim.keymap.set("n", "<leader>v", ":lua require('telescope.builtin').find_files()<CR>", opts)
vim.keymap.set("n", "<leader>g", ":lua require('telescope.builtin').live_grep()<CR>", opts)
vim.keymap.set("n", "<leader>t", ":TodoTelescope<CR>", opts)
vim.keymap.set("n", "<leader>k",
	":lua require('telescope').load_extension('k8s_commands').k8s(require('telescope.themes').get_ivy())<CR>", opts)
vim.keymap.set("n", "<leader>j",
	":lua require('telescope').load_extension('linode_commands').linode_ssh(require('telescope.themes').get_ivy())<CR>",
	opts)
vim.keymap.set("n", "<leader>ps",
	":lua require('telescope').load_extension('docker_commands').docker_version(require('telescope.themes').get_ivy())<CR>",
	opts)
vim.keymap.set("n", "<leader>y",
	":lua require('telescope').load_extension('neoclip').neoclip(require('telescope.themes').get_ivy())<CR>", opts)
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)
vim.keymap.set('n', '<leader>e', ":Ex<CR>", opts)
vim.keymap.set("n", "<leader><down>", "<C-W><down>", opts)
vim.keymap.set("n", "<leader><up>", "<C-W><up>", opts)
vim.keymap.set("n", "<leader><left>", "<C-W><left>", opts)
vim.keymap.set("n", "<leader><right>", "<C-W><right>", opts)
--vim.keymap.set("n", "<leader>z", require("lsp_lines").toggle, opts)
vim.keymap.set("n", "<leader>x", ":GoAddTags<CR>", opts)
vim.keymap.set("n", "<leader>b", ":ChatGPT<CR>", opts)
vim.keymap.set("n", "<leader>nb", ":ObsidianToday<CR>", opts)
vim.keymap.set("n", "<leader>z", ":Telescope buffers<CR>", opts)
