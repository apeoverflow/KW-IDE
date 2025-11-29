return {
  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- Useful plugin to show you pending keybinds
  { 'folke/which-key.nvim', opts = {} },

  -- Comment plugin
  { 'numToStr/Comment.nvim', opts = {} },

  -- Autopairs
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = function()
      require('nvim-autopairs').setup({
        disable_filetype = { "TelescopePrompt", "vim" },
      })
    end,
  },

  -- Vim sneak for quick navigation (disable gd mapping to preserve LSP goto definition)
  {
    'justinmk/vim-sneak',
    init = function()
      -- Prevent vim-sneak from mapping gd (preserve LSP goto definition)
      vim.g['sneak#textobject_z'] = 0
    end,
    config = function()
      -- Unmap gd after sneak loads to ensure LSP gd works
      pcall(vim.keymap.del, 'n', 'gd')
      pcall(vim.keymap.del, 'x', 'gd')
    end
  },

  -- Directory buffer
  { "elihunter173/dirbuf.nvim" },

  -- Hard time for breaking bad vim habits
  { "takac/vim-hardtime" },

  -- Circom syntax highlighting
  { 'iden3/vim-circom-syntax' },

  -- Tree-sitter comment support
  { 'stsewd/tree-sitter-comment' },
}