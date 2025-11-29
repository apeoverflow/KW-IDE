return {
  {
    -- Automatically install LSPs to stdpath for neovim
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end
  },

  -- Useful status updates for LSP
  { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },

  -- LSP configuration using the new vim.lsp.config API
  {
    "nvim-lua/plenary.nvim", -- Just using as a dependency placeholder
    lazy = false,
    config = function()
      -- LSP settings
      local on_attach = function(client, bufnr)
        local nmap = function(keys, func, desc)
          if desc then
            desc = 'LSP: ' .. desc
          end
          vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
        end

        nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

        nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
        nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
        nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
        nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

        nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
        nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
        nmap('<leader>wl', function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, '[W]orkspace [L]ist Folders')

        -- Create format command
        vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
          vim.lsp.buf.format()
        end, { desc = 'Format current buffer with LSP' })
      end

      -- nvim-cmp capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      -- Configure TypeScript/JavaScript LSP
      vim.lsp.config.ts_ls = {
        cmd = { 'typescript-language-server', '--stdio' },
        filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact' },
        root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- Configure Lua LSP with enhanced Neovim configuration
      vim.lsp.config.lua_ls = {
        cmd = { 'lua-language-server' },
        filetypes = { 'lua' },
        root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim' } },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
                "${3rd}/luv/library",
                "${3rd}/busted/library",
              },
            },
            telemetry = { enable = false },
          },
        },
      }

      -- Configure Vue LSP (Volar)
      vim.lsp.config.volar = {
        cmd = { 'vue-language-server', '--stdio' },
        filetypes = { 'vue' },
        root_markers = { 'package.json', 'vue.config.js', 'vite.config.js', '.git' },
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- Configure Clang LSP
      vim.lsp.config.clangd = {
        cmd = { 'clangd', '--background-index', '--clang-tidy' },
        filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
        root_markers = { '.clangd', '.clang-tidy', '.clang-format', 'compile_commands.json', 'compile_flags.txt', 'configure.ac', '.git' },
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- Auto-enable LSP servers when opening relevant files
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact' },
        callback = function(args)
          vim.lsp.enable('ts_ls', { bufnr = args.buf })
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'lua' },
        callback = function(args)
          vim.lsp.enable('lua_ls', { bufnr = args.buf })
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'vue' },
        callback = function(args)
          vim.lsp.enable('volar', { bufnr = args.buf })
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
        callback = function(args)
          vim.lsp.enable('clangd', { bufnr = args.buf })
        end,
      })

      -- Diagnostic keymaps
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
      vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
    end,
  },
}