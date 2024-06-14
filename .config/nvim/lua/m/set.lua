-- Line numbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- Indenting
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Editor Colours
vim.cmd('colorscheme vim')

-- Folding
vim.opt.foldmethod = 'marker'

-- Don't wrap lines
vim.opt.wrap = false

-- Swap file and undo history
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv('HOME') .. "/.vim/undodir"
vim.opt.undofile = true

-- Search highlighting
--vim.opt.hlsearch = false  -- Disables search highlighting
vim.opt.incsearch = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "no"
vim.opt.isfname:append('@-@')

vim.opt.updatetime = 50

--vim.opt.colorcolumn = '80'

-- Disable cursor styling - don't override the terminal configuration...
vim.opt.guicursor = nil

