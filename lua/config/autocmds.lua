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
