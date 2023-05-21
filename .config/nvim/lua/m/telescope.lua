-- Configuration for telescope plugin

local builtin = require('telescope.builtin')

-- Find files
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})

-- Grep files
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})

-- Find files in git repo
vim.keymap.set('n', '<leader>fr', builtin.git_files, {})

-- Interactive grep files
vim.keymap.set('n', '<leader>fs', function()
	builtin.grep_string({ search = vim.fn.input("grep> ") });
end)

