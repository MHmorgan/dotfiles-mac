-- Packer plugin
-- https://github.com/wbthomason/packer.nvim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

require('packer').startup(function()
	-- Let Packer manage Packer
	use 'wbthomason/packer.nvim'
	
	use 'tpope/vim-fugitive'
	use 'vim-airline/vim-airline'
	
	use 'tbastos/vim-lua'

	use 'preservim/nerdtree'
end)

