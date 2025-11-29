return {
  {
    "greggh/claude-code.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("claude-code").setup({
        window = {
          height_ratio = 0.3,
          position = "botright",
          enter_insert = true,
          hide_numbers = true,
          hide_signcolumn = true,
        },
        refresh = {
          enable = true,
          updatetime = 100,
          timer_interval = 1000,
          show_notifications = true,
        },
        git = {
          use_git_root = true,
        },
        command = "claude",
        keymaps = {
          toggle = {
            normal = "<C-,>",
            terminal = "<C-,>",
          },
          window_navigation = true,
          scrolling = true,
        }
      })
    end,
  },
}