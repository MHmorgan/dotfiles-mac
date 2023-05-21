-- Project functionality

function project_run()
    vim.cmd '!./run'
end

vim.keymap.set('n', '<leader>pr', project_run)


