-- Neovim config
-- https://developer.ibm.com/technologies/linux/articles/l-vim-script-1/
-- https://devhints.io/vimscript
-- https://vim.rtorr.com/
-- https://www.youtube.com/watch?v=w7i4amO_zaE&list=TLPQMjAwNTIwMjOEA-5siPVFIQ

-- See ./lua/m/
require("m")

--vim.wo.number = true
--vim.wo.relativenumber = true
--vim.wo.wrap = false
--vim.cmd('hi clear TODO')
--vim.bo.shiftwidth = 4
--vim.bo.tabstop = 4
--vim.o.path = vim.o.path .. ',**'
--vim.o.modeline = true

vim.wo.foldmethod = 'marker'

--vim.cmd([[
--  autocmd Filetype c setlocal ts=4 sw=4 expandtab
--  autocmd Filetype perl setlocal ts=4 sw=4 expandtab
--  autocmd Filetype dart setlocal ts=2 sw=2 expandtab
--  autocmd Filetype m4 setlocal ts=4 sw=4 expandtab
--  autocmd Filetype python setlocal ts=4 sw=4 expandtab
--  autocmd Filetype lua setlocal ts=4 sw=4 expandtab
--  autocmd Filetype tcl setlocal ts=2 sw=2 expandtab
--  autocmd Filetype xml setlocal ts=2 sw=2 expandtab
--  autocmd Filetype html setlocal ts=2 sw=2 expandtab
--]])

--vim.cmd('filetype plugin indent on')

print('Config :: v2 ::')
