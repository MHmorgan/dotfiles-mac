" Vim config - Magnus Hirth
"
" https://developer.ibm.com/technologies/linux/articles/l-vim-script-1/
" https://devhints.io/vimscript
" https://vim.rtorr.com/

" ------------------------------------------------------------------------------
" General

colorscheme default

set nocompatible

set number " line number
set relativenumber

set nowrap " Do not wrap lines wider than screen

syntax enable " syntax highlighting
hi clear TODO " Disable TODO highlighting

set shiftwidth=4
set tabstop=4

set smarttab

set path+=**

set modeline

set foldmethod=marker

autocmd Filetype c setlocal ts=4 sw=4 expandtab
autocmd Filetype perl setlocal ts=4 sw=4 expandtab
autocmd Filetype dart setlocal ts=2 sw=2 expandtab
autocmd Filetype m4 setlocal ts=4 sw=4 expandtab
autocmd Filetype python setlocal ts=4 sw=4 expandtab
autocmd Filetype tcl setlocal ts=2 sw=2 expandtab
autocmd Filetype xml setlocal ts=2 sw=2 expandtab
autocmd Filetype html setlocal ts=2 sw=2 expandtab

" ------------------------------------------------------------------------------
" Vundle plugin
"
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just
" :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to
" auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'dracula/vim', { 'name': 'dracula' }

Plugin 'tpope/vim-fugitive'
Plugin 'vim-airline/vim-airline'

Plugin 'arcticicestudio/nord-vim'

Plugin 'wlangstroth/vim-racket'
Plugin 'tbastos/vim-lua'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

