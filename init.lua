-- Set leader keys first
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.clipboard = ''
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.termguicolors = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.cursorline = true
vim.opt.swapfile = false
vim.opt.updatetime = 1000
vim.opt.timeoutlen = 500

-- File navigation settings for TypeScript/Vue
vim.opt.suffixesadd = '.js,.ts,.tsx,.jsx,.vue,.json'

-- Custom gf to handle @/ aliases, relative paths, and system headers
vim.keymap.set('n', 'gf', function()
  local cfile = vim.fn.expand('<cfile>')

  -- Handle C/C++ system headers like <stdio.h>
  if vim.bo.filetype == 'c' or vim.bo.filetype == 'cpp' then
    -- Try LSP go-to-definition first for C/C++
    vim.lsp.buf.definition()
    return
  end

  -- Handle @/ alias by replacing with src/
  if cfile:sub(1, 2) == '@/' then
    cfile = 'src/' .. cfile:sub(3)
  end

  -- Remove leading slash if present (from absolute path resolution)
  if cfile:sub(1, 1) == '/' then
    cfile = 'src' .. cfile
  end

  -- Try with different extensions
  local extensions = {'', '.ts', '.js', '.vue', '.tsx', '.jsx'}
  for _, ext in ipairs(extensions) do
    local filepath = cfile .. ext
    if vim.fn.filereadable(filepath) == 1 then
      vim.cmd('edit ' .. filepath)
      return
    end
  end

  -- Fallback: try original gf behavior
  pcall(function() vim.cmd('normal! gf') end)
end, { desc = 'Go to file with LSP/alias support' })

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Add homebrew to PATH
vim.env.PATH = vim.env.PATH .. ':/opt/homebrew/bin'

-- Add FVM to PATH if it exists
local fvm_path = vim.fn.expand('~/.fvm_flutter/bin')
if vim.fn.isdirectory(fvm_path) == 1 then
  vim.env.PATH = vim.env.PATH .. ':' .. fvm_path
end

-- Split buffer functions
function Split_current_buffer_horizontally()
  local current_buf = vim.api.nvim_get_current_buf()
  vim.cmd('split')
  vim.api.nvim_set_current_buf(current_buf)
end

function Split_current_buffer_vertically()
  local current_buf = vim.api.nvim_get_current_buf()
  vim.cmd('vsplit')
  vim.api.nvim_set_current_buf(current_buf)
end


-- Basic keymaps
local map = vim.keymap.set
map('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })
map('i', '<C-s>', '<C-c>:w<CR>', { noremap = true, silent = true })

-- Terminal function
vim.api.nvim_exec([[
  function! OpenTerminal()
    split term://zsh
    resize 10
  endfunction
]], false)

map('n', '<C-n>', ':call OpenTerminal()<CR>', { desc = 'Open terminal' })
map('t', '<C-x>', '<C-\\><C-n>', { noremap = true, silent = true })

-- Alt+hjkl to move between split/vsplit panels
map('t', '<A-h>', '<C-\\><C-n><C-w>h', { noremap = true, silent = true })
map('t', '<A-j>', '<C-\\><C-n><C-w>j', { noremap = true, silent = true })
map('t', '<A-k>', '<C-\\><C-n><C-w>k', { noremap = true, silent = true })
map('t', '<A-l>', '<C-\\><C-n><C-w>l', { noremap = true, silent = true })
map('n', '<A-h>', '<C-w>h', { noremap = true, silent = true })
map('n', '<A-j>', '<C-w>j', { noremap = true, silent = true })
map('n', '<A-k>', '<C-w>k', { noremap = true, silent = true })
map('n', '<A-l>', '<C-w>l', { noremap = true, silent = true })

-- Alt + 3 for # (from old config)
map('i', '<A-3>', '#', { noremap = true, silent = true })

-- Toggle search highlight
map('n', '<leader>h', ':noh<CR>', { noremap = true, silent = true, desc = 'Clear search highlight' })

-- Copy working directory to clipboard
map('n', '<leader>cd', function()
  local cwd = vim.fn.getcwd()
  vim.fn.setreg('+', cwd)
  print('Copied to clipboard: ' .. cwd)
end, { noremap = true, silent = true, desc = 'Copy working directory to clipboard' })

-- Persistent mark file location
local mark_file = vim.fn.stdpath('data') .. '/persistent_mark.txt'

local function save_mark(file, line)
  local f = io.open(mark_file, 'w')
  if f then
    f:write(file .. '\n' .. line)
    f:close()
  end
end

local function load_mark()
  local f = io.open(mark_file, 'r')
  if f then
    local file = f:read('*l')
    local line = tonumber(f:read('*l'))
    f:close()
    if file and line then
      return file, line
    end
  end
  return nil, nil
end

-- Mark current file and line position (persists across all sessions)
map('n', '<leader>mm', function()
  local file = vim.fn.expand('%:p')
  local line = vim.fn.line('.')
  save_mark(file, line)
  print('Marked: ' .. file .. ':' .. line)
end, { noremap = true, silent = true, desc = 'Mark current file and line (persistent)' })

-- Jump to marked file and line position
map('n', '<leader>mj', function()
  local file, line = load_mark()
  if file and line then
    vim.cmd('edit ' .. vim.fn.fnameescape(file))
    vim.fn.cursor(line, 0)
    print('Jumped to: ' .. file .. ':' .. line)
  else
    print('No mark set. Use <leader>mm to set a mark.')
  end
end, { noremap = true, silent = true, desc = 'Jump to marked file and line (persistent)' })

-- Mark current position and copy nvim command to clipboard
map('n', '<leader>mc', function()
  local file = vim.fn.expand('%:p')
  local line = vim.fn.line('.')
  save_mark(file, line)
  local cmd = 'nvim +' .. line .. ' ' .. file
  vim.fn.setreg('+', cmd)
  print('Marked & copied: ' .. cmd)
end, { noremap = true, silent = true, desc = 'Mark position and copy nvim command' })

-- Tab navigation
map('n', '<C-a>', ':tabprevious<CR>', { noremap = true, silent = true })

-- Debug LSP status
map('n', '<leader>li', function()
  print('=== LSP Info ===')
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  if #clients > 0 then
    for _, client in ipairs(clients) do
      print('Active LSP: ' .. client.name)
      if client.name == 'dartls' then
        print('Dart LSP cmd:', vim.inspect(client.config.cmd))
      end
    end
  else
    print('No active LSP clients')
  end
  print('Filetype: ' .. vim.bo.filetype)
  print('File: ' .. vim.fn.expand('%'))

  -- Check if clangd is available
  if vim.fn.executable('clangd') == 1 then
    print('clangd found in PATH')
  else
    print('clangd NOT found in PATH')
  end

  -- Check FVM and Dart availability
  local fvm_check = vim.fn.system('fvm --version 2>/dev/null'):gsub('\n', '')
  if fvm_check ~= '' then
    print('FVM found: ' .. fvm_check)
    local fvm_config = vim.fn.findfile('.fvmrc', '.;') or vim.fn.findfile('.fvm/fvm_config.json', '.;')
    if fvm_config ~= '' then
      print('FVM config found: ' .. fvm_config)
      local fvm_flutter = vim.fn.system('fvm flutter --version 2>/dev/null | head -1'):gsub('\n', '')
      if fvm_flutter ~= '' then
        print('FVM Flutter: ' .. fvm_flutter)
      end
    else
      print('No FVM config in current project')
    end
  else
    print('FVM not found')
  end

  if vim.fn.executable('dart') == 1 then
    local dart_version = vim.fn.system('dart --version 2>&1'):gsub('\n', '')
    print('Dart found: ' .. dart_version)
  else
    print('Dart NOT found in PATH')
  end
end, { desc = 'LSP Info' })

-- Manual LSP start for C/C++
map('n', '<leader>lc', function()
  if vim.bo.filetype == 'c' or vim.bo.filetype == 'cpp' then
    print('Starting clangd...')
    vim.lsp.start({
      name = 'clangd',
      cmd = { 'clangd', '--background-index', '--clang-tidy' },
      root_dir = vim.fn.getcwd(),
      on_attach = function(client, bufnr)
        print('clangd attached to buffer')
      end,
    })
  else
    print('Not a C/C++ file')
  end
end, { desc = 'Start clangd LSP' })

-- Word wrap navigation
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Yank to end of line with Y (normal mode)
map('n', 'Y', 'y$', { noremap = true, silent = true })

-- Yank to system clipboard with Y (visual mode)
map('v', 'Y', '"*y', { noremap = true, silent = true })

-- Center cursor after half-page moves
map('n', '<C-d>', '<C-d>zz', { noremap = true, silent = true })
map('n', '<C-u>', '<C-u>zz', { noremap = true, silent = true })

-- Buffer splits
map('n', '<Leader>x', ':lua Split_current_buffer_horizontally()<CR>', { noremap = true, silent = true, desc = 'Split buffer horizontally' })
map('n', '<Leader>v', ':lua Split_current_buffer_vertically()<CR>', { noremap = true, silent = true, desc = 'Split buffer vertically' })

-- File explorer find current file
map('n', '<Leader><C-b>', function()
  if pcall(require, 'nvim-tree.api') then
    require('nvim-tree.api').tree.find_file({ open = true, focus = true })
  else
    vim.cmd('edit .')
  end
end, { noremap = true, silent = true, desc = 'Find current file in explorer' })


-- Alternative mappings for macOS (Option key might be different)
map('n', '<M-h>', '<C-w>h', { noremap = true, silent = true })
map('n', '<M-j>', '<C-w>j', { noremap = true, silent = true })
map('n', '<M-k>', '<C-w>k', { noremap = true, silent = true })
map('n', '<M-l>', '<C-w>l', { noremap = true, silent = true })
map('t', '<M-h>', '<C-\\><C-n><C-w>h', { noremap = true, silent = true })
map('t', '<M-j>', '<C-\\><C-n><C-w>j', { noremap = true, silent = true })
map('t', '<M-k>', '<C-\\><C-n><C-w>k', { noremap = true, silent = true })
map('t', '<M-l>', '<C-\\><C-n><C-w>l', { noremap = true, silent = true })

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "onedark", "habamax" } },
  checker = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})

-- Auto-start LSP servers for different file types (immediate)
-- Note: C/C++ LSP is handled by lua/plugins/lsp.lua with enhanced clangd config

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'vue' },
  callback = function()
    vim.lsp.start({
      name = 'volar',
      cmd = { 'vue-language-server', '--stdio' },
      root_dir = vim.fn.getcwd(),
    })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'dart' },
  callback = function()
    -- Helper function to get Dart command with FVM support
    local function get_dart_cmd()
      local fvm_check = vim.fn.system('fvm --version 2>/dev/null'):gsub('\n', '')
      if fvm_check ~= '' then
        local fvm_config = vim.fn.findfile('.fvmrc', '.;') or vim.fn.findfile('.fvm/fvm_config.json', '.;')
        if fvm_config ~= '' then
          return { 'fvm', 'dart', 'language-server', '--protocol=lsp' }
        end
      end
      return { 'dart', 'language-server', '--protocol=lsp' }
    end

    vim.lsp.start({
      name = 'dartls',
      cmd = get_dart_cmd(),
      root_dir = vim.fn.getcwd(),
    })
  end,
})

-- Add more keymaps after plugins load
vim.defer_fn(function()
  -- NvimTree keymaps
  map('n', '<C-b>', function()
    if pcall(require, 'nvim-tree.api') then
      require('nvim-tree.api').tree.toggle()
    else
      vim.cmd('edit .')
    end
  end, { desc = 'Toggle file explorer' })

  -- Telescope keymaps
  map('n', '<leader>sf', function()
    if pcall(require, 'telescope.builtin') then
      require('telescope.builtin').find_files()
    else
      vim.cmd('edit .')
    end
  end, { desc = '[S]earch [F]iles' })

  map('n', '<leader>ff', function()
    if pcall(require, 'telescope.builtin') then
      require('telescope.builtin').git_files()
    else
      require('telescope.builtin').find_files()
    end
  end, { desc = 'Find files' })

  -- Outline toggle
  map('n', '<space>o', '<cmd>Outline<CR>', { desc = 'Toggle outline' })

  -- Copilot manual trigger - open panel with suggestions
  vim.keymap.set('i', '<C-g>', '<cmd>Copilot panel<CR>', { desc = 'Open Copilot panel' })

  -- LazyGit
  map('n', '<leader>lg', function()
    if pcall(require, 'lazygit') then
      vim.cmd('LazyGit')
    else
      print('LazyGit plugin not loaded')
    end
  end, { desc = 'Open LazyGit' })

  -- Manual lookup for word under cursor
  map('n', '<leader>cm', function()
    local word = vim.fn.expand('<cword>')
    if word and word ~= '' then
      vim.cmd('split')
      vim.cmd('terminal man ' .. word)
      vim.cmd('resize 15')
    else
      print('No word under cursor')
    end
  end, { desc = 'Search word under cursor in manual' })

  -- Flutter/Dart specific keybindings
  -- Quick pubspec.yaml access
  map('n', '<leader>fp', function()
    local pubspec = vim.fn.findfile('pubspec.yaml', '.;')
    if pubspec ~= '' then
      vim.cmd('edit ' .. pubspec)
    else
      print('pubspec.yaml not found')
    end
  end, { desc = 'Open pubspec.yaml' })

  -- Quick main.dart access
  map('n', '<leader>fm', function()
    local main = vim.fn.findfile('lib/main.dart', '.;')
    if main ~= '' then
      vim.cmd('edit ' .. main)
    else
      print('lib/main.dart not found')
    end
  end, { desc = 'Open main.dart' })

end, 100)
