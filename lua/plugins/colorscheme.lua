return {
  {
    -- OneDark theme
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'onedark'
      -- Transparent background settings
      vim.cmd [[ hi Normal guibg=NONE ctermbg=NONE ]]
      vim.cmd [[ hi SignColumn guibg=NONE ctermbg=NONE ]]
      vim.cmd [[ hi VertSplit guifg=NONE ctermfg=NONE ]]
      vim.cmd [[ hi MsgArea guibg=NONE ctermbg=NONE ]]
      vim.cmd [[ hi MsgSeparator guibg=NONE ctermbg=NONE ]]
      vim.cmd [[highlight CursorLine guibg=#24364a ]]
    end,
  },
}