call plug#begin('~/.config/nvim/plugged')
Plug 'nvim-lua/plenary.nvim' " General
Plug 'nvim-lua/popup.nvim' " General
Plug 'ThePrimeagen/harpoon'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'frenchtoasters/telescope-kubectl.nvim'
Plug 'frenchtoasters/telescope-linode.nvim'
Plug 'AckslD/nvim-neoclip.lua'
Plug 'vim-airline/vim-airline' " Bottom bar fancy stuff
Plug 'vim-airline/vim-airline-themes' " Bottom bar fancy stuff
Plug 'junegunn/seoul256.vim' " Theme
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'mhinz/vim-signify' " Git changes on side file :cheifskiss:
Plug 'heavenshell/vim-pydocstring', { 'do': 'make install' }
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'APZelos/blamer.nvim' " Git blamer
Plug 'terrortylor/nvim-comment' " Comment hot keys
" Plug 'neoclide/coc.nvim', {'branch': 'release'} " coc-go coc-pairs coc-lua coc-python coc-snippets
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/nvim-cmp'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'windwp/nvim-autopairs'
"Plug 'tzachar/cmp-tabnine', { 'do': './install.sh' }
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' } " gofmt, goimports
" Plug 'davidhalter/jedi-vim' " python stuff
call plug#end()
" Personal config
autocmd VimEnter * lua require('settings')
autocmd VimEnter * lua require('keymap')
autocmd VimEnter * lua require('toast')
autocmd VimEnter * LspStart
autocmd BufWritePre *.tf lua vim.lsp.buf.formatting_sync(nil, 2000)
color seoul256
hi NonText guifg=250 guifg=none
hi Normal guifg=252 guibg=none
hi DiffDelete guifg=#ff5555 guibg=none
