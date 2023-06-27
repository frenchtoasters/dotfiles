let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/plugged')
Plug 'nvim-lua/plenary.nvim' " General
Plug 'nvim-lua/popup.nvim' " General
Plug 'ThePrimeagen/harpoon'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-telescope/telescope.nvim'
Plug 'junegunn/fzf', {'do': { -> fzf#install() } }
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'frenchtoasters/telescope-kubectl.nvim'
Plug 'frenchtoasters/telescope-linode.nvim'
Plug 'AckslD/nvim-neoclip.lua'
Plug 'vim-airline/vim-airline' " Bottom bar fancy stuff
Plug 'vim-airline/vim-airline-themes' " Bottom bar fancy stuff
Plug 'junegunn/seoul256.vim' " Theme
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'mhinz/vim-signify' " Git changes on side file :cheifskiss:
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'APZelos/blamer.nvim' " Git blamer
Plug 'terrortylor/nvim-comment' " Comment hot keys
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim', { 'do': ':MasonUpdate' }
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/nvim-cmp'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'windwp/nvim-autopairs'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' } " gofmt, goimports
Plug 'davidhalter/jedi-vim'
Plug 'simrat39/rust-tools.nvim'
Plug 'maan2003/lsp_lines.nvim'
call plug#end()
" Personal config
autocmd VimEnter * lua require('settings')
autocmd VimEnter * lua require('toast')
autocmd VimEnter * LspStart
color seoul256
hi NonText guifg=250 guifg=none
hi Normal guifg=252 guibg=none
hi DiffDelete guifg=#ff5555 guibg=none
