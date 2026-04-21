-- Terminal function
vim.api.nvim_exec([[
  function! OpenTerminal()
    split term://zsh
    resize 10
  endfunction
]], false)

-- Start terminal in insert mode
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*',
  callback = function()
    if vim.bo.buftype == "terminal" then
      vim.cmd('startinsert')
    end
  end,
})

-- Helper functions
_G.Split_current_buffer_horizontally = function()
  local current_buf = vim.api.nvim_get_current_buf()
  vim.cmd('split')
  vim.api.nvim_win_set_buf(0, current_buf)
  vim.cmd('normal! gg')
end

_G.Split_current_buffer_vertically = function()
  local current_buf = vim.api.nvim_get_current_buf()
  vim.cmd('vsplit')
  vim.api.nvim_win_set_buf(0, current_buf)
  vim.cmd('normal! gg')
end

_G.CwdCopy = function()
  vim.cmd('!pwd | pbcopy')
end

_G.Open_lazygit = function()
  vim.cmd('split')
  vim.cmd('terminal /opt/homebrew/bin/lazygit')
  vim.cmd('startinsert')
end

_G.copy_current_file_path = function()
  local file_path = vim.fn.expand('%:p')
  vim.fn.system('pbcopy', file_path)
  print('File path copied to clipboard: ' .. file_path)
end

_G.Wrap_word_in_tags = function()
  local mode = vim.fn.mode()
  local word = vim.fn.expand('<cword>')

  if word == '' or word == nil then
    print('No word under cursor')
    return
  end

  if mode == 'i' then
    vim.cmd('stopinsert')
  end

  local replacement = '<' .. word .. '></' .. word .. '>'
  vim.cmd('normal! ciw' .. replacement)
  vim.cmd('normal! F>a')
end

_G.Wrap_word_in_self_closing_tag = function()
  local mode = vim.fn.mode()
  local word = vim.fn.expand('<cword>')

  if word == '' or word == nil then
    print('No word under cursor')
    return
  end

  if mode == 'i' then
    vim.cmd('stopinsert')
  end

  local replacement = '<' .. word .. ' />'
  vim.cmd('normal! ciw' .. replacement)
  vim.cmd('normal! F a')
end

_G.indentWithI = function()
  local line = vim.api.nvim_get_current_line()
  if #line == 0 then
    return "\"_cc"
  else
    return "i"
  end
end

-- :Glow <path> — render a markdown file (path relative to project root) with glow in a split terminal
vim.api.nvim_create_user_command('Glow', function(opts)
  local root = vim.fs.root(0, { '.git' }) or vim.fn.getcwd()
  local rel = opts.args
  if rel == '' then
    rel = vim.fn.expand('%:p')
  end
  local path = rel
  if not vim.startswith(rel, '/') then
    path = root .. '/' .. rel
  end
  if vim.fn.filereadable(path) == 0 then
    vim.notify('Glow: file not found: ' .. path, vim.log.levels.ERROR)
    return
  end
  vim.cmd('split')
  vim.cmd('terminal glow -p ' .. vim.fn.shellescape(path))
  vim.cmd('startinsert')
end, {
  nargs = '?',
  desc = 'Render markdown with glow (path relative to project root)',
  complete = function(arg_lead)
    local root = vim.fs.root(0, { '.git' }) or vim.fn.getcwd()
    local matches = vim.fn.globpath(root, arg_lead .. '*', false, true)
    local results = {}
    for _, m in ipairs(matches) do
      local rel = m:sub(#root + 2)
      if vim.fn.isdirectory(m) == 1 then
        rel = rel .. '/'
      end
      table.insert(results, rel)
    end
    return results
  end,
})

-- Setup treesitter after plugins are loaded
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    -- Delay treesitter setup to ensure it's loaded
    vim.defer_fn(function()
      require('config.treesitter').setup()
    end, 100)
  end,
})
