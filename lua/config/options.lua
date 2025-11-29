local opt = vim.opt

-- Set leader keys early
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set highlight on search
opt.hlsearch = true

-- Make line numbers default
opt.number = true
opt.relativenumber = true

-- Enable mouse mode
opt.mouse = 'a'

-- Disable clipboard sync - using custom copy functions instead
opt.clipboard = ""

-- Enable break indent
opt.breakindent = true

-- Save undo history
opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
opt.ignorecase = true
opt.smartcase = true

-- Keep signcolumn on by default
opt.signcolumn = 'yes'

-- Set completeopt to have a better completion experience
opt.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
opt.termguicolors = true

-- Split settings
opt.splitright = true
opt.splitbelow = true

-- Indentation settings
opt.autoindent = true
opt.smarttab = true
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2

-- Disable folding
opt.foldenable = false

-- Cursor line highlighting
opt.cursorline = true

-- Disable swap files
opt.swapfile = false

-- Timing settings
opt.updatetime = 1000
opt.timeoutlen = 500

-- Disable netrw (using nvim-tree instead)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Ensure PATH includes homebrew for lazygit and other tools
vim.env.PATH = vim.env.PATH .. ':/opt/homebrew/bin'
