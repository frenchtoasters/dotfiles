local set = vim.opt
set.tabstop        = 4
set.shiftwidth     = 4
set.laststatus     = 2
set.textwidth      = 0
set.wildmode       = 'longest,list,full'
set.encoding       = 'utf-8'
set.clipboard      = 'unnamedplus'
set.smarttab       = true
set.autoindent     = true
set.incsearch      = true
set.ignorecase     = true
set.smartcase      = true
set.hlsearch       = true
set.ruler          = true
set.showcmd        = true
set.showmode       = true
set.wrap           = true
set.breakindent    = true
set.hidden         = true
set.number         = true
set.relativenumber = true
set.title          = true
set.termguicolors  = true
set.list           = true
-- set.listchars = 'trail:»,tab:»-'
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
vim.cmd [[
	syntax on
]]
