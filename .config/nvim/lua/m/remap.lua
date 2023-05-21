vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- 'n' for normal mode.
-- when pressing '<leader>e'
-- call this function handler: vim.cmd.NERDTreeFocus
vim.keymap.set('n', '<leader>e', vim.cmd.NERDTreeFocus)

-- Paste-overwrite without loosing paste register
-- The void register is _
vim.keymap.set('x', '<leader>p', '"_dP')

-- Copy (yank) into the system clipboard
-- The system clipboard (register) is +
vim.keymap.set('n', '<leader>y', '"+y')
vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>Y', '"+P')

-- Execute current file
vim.keymap.set('n', '<leader>x', '<cmd>!./%<CR>')
-- Make current file executable
vim.keymap.set('n', '<leader>X', '<cmd>!chmod +x %<CR>', { silent = true })

