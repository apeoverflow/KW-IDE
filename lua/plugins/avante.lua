return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    build = "make",
    config = function(_, opts)
      require("avante").setup(opts)

      local ghe_host = "pcs.ghe.com"
      local copilot = require("avante.providers.copilot")
      local patched = false
      for i = 1, 30 do
        local name, value = debug.getupvalue(copilot.setup, i)
        if not name then break end
        if name == "H" then
          value.chat_auth_url = "https://" .. ghe_host .. "/api/v3/copilot_internal/v2/token"
          patched = true
          break
        end
      end
      if not patched then
        vim.notify("avante: GHE patch failed — copilot provider internals may have changed", vim.log.levels.WARN)
      end
    end,
    opts = {
      provider = "copilot",
      behaviour = {
        auto_suggestions = false,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
      },
      mappings = {
        suggestion = {
          accept = "<M-CR>",
          next = "<M-n>",
          prev = "<M-p>",
          dismiss = "<M-c>",
        },
      },
    },
    dependencies = {
      "zbirenbaum/copilot.lua",
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
}
