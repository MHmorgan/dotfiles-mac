-- Packer plugin
-- https://github.com/wbthomason/packer.nvim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

require('packer').startup(function()
    -- Let Packer manage Packer
    use 'wbthomason/packer.nvim'

    -- Telescope: fuzzy file finder
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.1',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }

    -- Treesitter: code parsing
    use {
        'nvim-treesitter/nvim-treesitter',
        -- this will fail on first PackerSync! Try twice!
        run = ':TSUpdate'
    }
    -- See the treesitter AST
    -- TSPlaygroundToggle
    use 'nvim-treesitter/playground'

    -- Super-fast file navigation
    use 'theprimeagen/harpoon'

    -- Undo change tree
    use 'mbbill/undotree'

    -- Super awesome Git plugin
    use 'tpope/vim-fugitive'

    -- Sweet file explorer
    use 'preservim/nerdtree'

    -- LSP with lsp-zero
    -- https://github.com/VonHeikemen/lsp-zero.nvim
    --use {
    --    'VonHeikemen/lsp-zero.nvim',
    --    branch = 'v2.x',
    --    requires = {
    --        -- LSP Support
    --        { 'neovim/nvim-lspconfig' }, -- Required
    --        {
    --            'williamboman/mason.nvim',
    --            run = function() -- Optional
    --                pcall(vim.cmd, 'MasonUpdate')
    --            end
    --        },
    --        { 'williamboman/mason-lspconfig.nvim' }, -- Optional

    --        -- Autocompletion
    --        { 'hrsh7th/nvim-cmp' },     -- Required
    --        { 'hrsh7th/cmp-nvim-lsp' }, -- Required
    --        { 'L3MON4D3/LuaSnip' },     -- Required
    --    }
    --}
end)
