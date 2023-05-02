--[[

Cheatsheet
----------

For details always check out :help <cmd>

See all diagraphs
	:diagraphs

Insert a diagraph
    Ctrl-k + <key-sequence>

Open current window in another tab:
	CTRL-w T

--]]

-- vim.cmd "set runtimepath^=~/.vim runtimepath+=~/.vim/after"
-- vim.cmd "let &packpath = &runtimepath"
-- vim.cmd "source ~/.vimrc"

-- Neovim config - Magnus Hirth
-- https://developer.ibm.com/technologies/linux/articles/l-vim-script-1/
-- https://devhints.io/vimscript
-- https://vim.rtorr.com/

-- General
vim.cmd('colorscheme default')

vim.wo.number = true
vim.wo.relativenumber = true

vim.wo.wrap = false

vim.cmd('syntax enable')
vim.cmd('hi clear TODO')

vim.bo.shiftwidth = 4
vim.bo.tabstop = 4

vim.o.path = vim.o.path .. ',**'

vim.o.modeline = true

vim.wo.foldmethod = 'marker'

vim.cmd([[
  autocmd Filetype c setlocal ts=4 sw=4 expandtab
  autocmd Filetype perl setlocal ts=4 sw=4 expandtab
  autocmd Filetype dart setlocal ts=2 sw=2 expandtab
  autocmd Filetype m4 setlocal ts=4 sw=4 expandtab
  autocmd Filetype python setlocal ts=4 sw=4 expandtab
  autocmd Filetype tcl setlocal ts=2 sw=2 expandtab
  autocmd Filetype xml setlocal ts=2 sw=2 expandtab
  autocmd Filetype html setlocal ts=2 sw=2 expandtab
]])

-- LEADER KEY
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Packer plugin
-- https://github.com/wbthomason/packer.nvim

-- PLUGINS
--
-- My plugin setup (./lua/plugins.lua)
--
require 'plugins'

vim.cmd('filetype plugin indent on')

-- FILE EXPLORER
--
-- Using NERDTree as file explorer for neovim
--
vim.api.nvim_set_keymap('n', '<leader>e', ':NERDTreeFocus<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>E', ':NERDTreeToggle<CR>', {noremap = true, silent = true})


