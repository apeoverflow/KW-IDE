local map = vim.keymap.set
local options = { noremap = true, silent = true }

-- Leader keys are now set in options.lua

-- Remap for dealing with word wrap
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Terminal keymaps
map('n', '<C-n>', function()
  vim.cmd('call OpenTerminal()')
end, { desc = 'Open terminal', noremap = true, silent = true })
map('t', '<C-x>', '<C-\\><C-n>', options)

-- NvimTree toggle - these will be overridden by plugin config if needed
map('n', '<C-b>', function()
  if pcall(require, 'nvim-tree.api') then
    require('nvim-tree.api').tree.toggle()
  else
    vim.cmd('NvimTreeToggle')
  end
end, { desc = 'Toggle file explorer' })

map('n', '<C-S-b>', function()
  if pcall(require, 'nvim-tree.api') then
    require('nvim-tree.api').tree.find_file({ open = true })
  else
    vim.cmd('NvimTreeFindFile')
  end
end, { desc = 'Find current file in explorer' })

-- Use alt+hjkl to move between split/vsplit panels
map('t', '<A-h>', '<C-\\><C-n><C-w>h', options)
map('t', '<A-j>', '<C-\\><C-n><C-w>j', options)
map('t', '<A-k>', '<C-\\><C-n><C-w>k', options)
map('t', '<A-l>', '<C-\\><C-n><C-w>l', options)
map('n', '<A-h>', '<C-w>h', options)
map('n', '<A-j>', '<C-w>j', options)
map('n', '<A-k>', '<C-w>k', options)
map('n', '<A-l>', '<C-w>l', options)

-- Alt + 3 ==> #
map('i', '<A-3>', '#', options)

-- Tab Remapping
map('n', '<C-a>', ':tabprevious<CR>', options)

-- no highlight mapping
map('n', '<leader>h', ':noh<CR>', options)

-- Source current file
map('n', '<leader>s', ':source %<CR>', options)

-- Save file with ctrl + s
map('i', '<C-s>', '<C-c>:w<CR>', options)
map('n', '<C-s>', ':w<CR>', options)

-- Horizontal scroll
map('', '<C-L>', '20zl', options)
map('', '<C-H>', '20zh', options)

-- Yank to end of line with Y
map('n', 'Y', 'y$', options)

-- Yank to system clipboard with ctrl + y
map('v', 'Y', '"*y', options)

-- Ctrl J does the opposite of shift J
map('n', '<C-J>', 'a<CR><Esc>k$', options)
map('n', '<leader>j', '$a<CR><Esc>', options)

-- Remap Ctrl + d/u to center cursor line
map('n', '<C-d>', '<C-d>zz', options)
map('n', '<C-u>', '<C-u>zz', options)

-- Buffer splits
map('n', '<Leader>x', ':lua Split_current_buffer_horizontally()<CR>', options)
map('n', '<Leader>v', ':lua Split_current_buffer_vertically()<CR>', options)
map('n', '<Leader>-', '10<C-W>-<CR>', options)

-- Speed up scroll down and up
map('n', '<C-e>', '5<C-e>', options)
map('n', '<C-y>', '5<C-y>', options)

-- Copy current working directory to clipboard
map('n', '<Leader>cwd', ':lua CwdCopy()<CR>', options)

-- Copy current file path to clipboard
map('n', '<Space>cp', '<cmd>lua copy_current_file_path()<CR>', options)

-- LazyGit and other utils
map('n', '<Leader>lg', '<cmd>lua Open_lazygit()<CR>', options)
map('n', '<Leader>db', ':Dirbuf<CR>', options)
map('n', '<Leader>f.', ':silent !npx prettier --write %<CR>', options)
map('n', '<Leader>fa', ':!npx prettier --write .<CR>', { noremap = true, silent = true })

-- HTML tag wrapping
map('i', '<C-t>', '<Esc><cmd>lua Wrap_word_in_tags()<CR>', options)
map('n', '<C-t>', '<cmd>lua Wrap_word_in_tags()<CR>', options)
map('i', '<C-S-t>', '<Esc><cmd>lua Wrap_word_in_self_closing_tag()<CR>', options)
map('n', '<C-S-t>', '<cmd>lua Wrap_word_in_self_closing_tag()<CR>', options)

-- Smart indent with 'i' key
map('n', 'i', 'v:lua.indentWithI()', { expr = true, noremap = true, silent = true })

-- Claude Code toggle
map('n', '<leader>cc', '<cmd>ClaudeCode<CR>', { desc = 'Toggle Claude Code' })

-- Outline toggle (space o for objects pane)
map('n', '<space>o', '<cmd>Outline<CR>', { desc = 'Toggle outline' })

-- Telescope fallback keymaps (will be overridden by telescope plugin if loaded)
map('n', '<leader>sf', function()
  if pcall(require, 'telescope.builtin') then
    require('telescope.builtin').find_files()
  else
    vim.cmd('edit .')
  end
end, { desc = '[S]earch [F]iles' })

map('n', '<leader>sg', function()
  if pcall(require, 'telescope.builtin') then
    require('telescope.builtin').live_grep()
  else
    vim.cmd('vimgrep // **/*')
  end
end, { desc = '[S]earch by [G]rep' })

map('n', '<leader>ff', function()
  if pcall(require, 'telescope.builtin') then
    require('telescope.builtin').git_files()
  else
    require('telescope.builtin').find_files()
  end
end, { desc = 'Search git files' })

-- Debug keymap
map('n', '<leader>dk', function()
  print('Leader key: ' .. vim.g.mapleader)
  print('Telescope loaded: ' .. tostring(pcall(require, 'telescope.builtin')))
  print('NvimTree loaded: ' .. tostring(pcall(require, 'nvim-tree.api')))
  print('OpenTerminal exists: ' .. tostring(vim.fn.exists('*OpenTerminal') == 1))
end, { desc = 'Debug keymaps' })
