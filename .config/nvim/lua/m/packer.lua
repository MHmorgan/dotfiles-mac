-- Packer plugin
-- https://github.com/wbthomason/packer.nvim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

require('packer').startup(function()
    -- Let Packer manage Packer
    use 'wbthomason/packer.nvim'

    -- Telescope: fuzzy file finder
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.6',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }

    -- Improved status/tabline
	use 'vim-airline/vim-airline'

    -- Super awesome Git plugin
    use 'tpope/vim-fugitive'

    -- Sweet file explorer
    use 'preservim/nerdtree'
end)
