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

vim.cmd "set runtimepath^=~/.vim runtimepath+=~/.vim/after"
vim.cmd "let &packpath = &runtimepath"
vim.cmd "source ~/.vimrc"

vim.g.mapleader = " "
vim.keymap.set('n', '<Leader>h', '<cmd>echo "Example 1"<cr>')
--vim.keymap.set('n', '<Leader>r', function ()
--	-- print'Hello, World!'
--     vim.ui.select({ 'tabs', 'spaces' }, {
--         prompt = 'Select tabs or spaces:',
--         format_item = function(item)
--             return "I'd like to choose " .. item
--         end,
--     }, function(choice)
--		 print("in:", choice)
--     end)
--end)

-- require "foo"

