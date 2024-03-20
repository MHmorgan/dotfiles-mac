-- Packer plugin
-- https://github.com/wbthomason/packer.nvim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

require('packer').startup(function()
	-- Let Packer manage Packer
	use 'wbthomason/packer.nvim'
	
    -- Git wrapper
	use 'tpope/vim-fugitive'
	use 'vim-airline/vim-airline'
	
    -- Improved Lua 5.3 syntax and indentation support
	use 'tbastos/vim-lua'

    -- File explorer
	use 'preservim/nerdtree'
end)

