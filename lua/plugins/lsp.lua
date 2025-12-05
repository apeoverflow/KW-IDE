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

      -- Configure Vue LSP (Volar) - optimized for Vue 3
      local function get_typescript_server_path(root_dir)
        local project_root = root_dir or vim.fn.getcwd()
        local found = vim.fn.glob(project_root .. '/node_modules/typescript/lib', false, true)
        if found and #found > 0 then
          return found[1]
        end
        local global_ts = vim.fn.system('npm root -g'):gsub('\n', '') .. '/typescript/lib'
        if vim.fn.isdirectory(global_ts) == 1 then
          return global_ts
        end
        return ''
      end

      vim.lsp.config.volar = {
        cmd = { 'vue-language-server', '--stdio' },
        filetypes = { 'vue' },
        root_markers = { 'package.json', 'vite.config.ts', 'vite.config.js', 'vue.config.js', 'nuxt.config.js', '.git' },
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          on_attach(client, bufnr)
        end,
        on_new_config = function(new_config, new_root_dir)
          new_config.init_options.typescript.tsdk = get_typescript_server_path(new_root_dir)
        end,
        init_options = {
          typescript = {
            tsdk = get_typescript_server_path(nil)
          },
        },
      }

      -- Configure Clang LSP
      vim.lsp.config.clangd = {
        cmd = { 'clangd', '--background-index', '--clang-tidy' },
        filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
        root_markers = { '.clangd', '.clang-tidy', '.clang-format', 'compile_commands.json', 'compile_flags.txt', 'configure.ac', '.git' },
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- Helper function to get Dart command with FVM support
      local function get_dart_cmd()
        local fvm_check = vim.fn.system('fvm --version 2>/dev/null'):gsub('\n', '')
        if fvm_check ~= '' then
          -- Check if we're in a Flutter project with FVM config
          local fvm_config = vim.fn.findfile('.fvmrc', '.;') or vim.fn.findfile('.fvm/fvm_config.json', '.;')
          if fvm_config ~= '' then
            return { 'fvm', 'dart', 'language-server', '--protocol=lsp' }
          end
        end
        return { 'dart', 'language-server', '--protocol=lsp' }
      end

      -- Configure Dart LSP
      vim.lsp.config.dartls = {
        cmd = get_dart_cmd(),
        filetypes = { 'dart' },
        root_markers = { 'pubspec.yaml', '.fvmrc', '.fvm/fvm_config.json', '.git' },
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          on_attach(client, bufnr)

          -- Flutter-specific keymaps
          local nmap = function(keys, func, desc)
            if desc then
              desc = 'Flutter: ' .. desc
            end
            vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
          end

          nmap('<leader>fr', '<cmd>FlutterRun<CR>', 'Run')
          nmap('<leader>fq', '<cmd>FlutterQuit<CR>', 'Quit')
          nmap('<leader>fh', '<cmd>FlutterReload<CR>', 'Hot Reload')
          nmap('<leader>fR', '<cmd>FlutterRestart<CR>', 'Hot Restart')
          nmap('<leader>fd', '<cmd>FlutterDevices<CR>', 'Devices')
          nmap('<leader>fe', '<cmd>FlutterEmulators<CR>', 'Emulators')
          nmap('<leader>fo', '<cmd>FlutterOutlineToggle<CR>', 'Toggle Outline')
        end,
        settings = {
          dart = {
            completeFunctionCalls = true,
            showTodos = true,
          }
        },
        init_options = {
          onlyAnalyzeProjectsWithOpenFiles = true,
          suggestFromUnimportedLibraries = true,
          closingLabels = true,
          outline = true,
          flutterOutline = true,
        },
      }

      -- Auto-enable LSP servers when opening relevant files
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact' },
        callback = function(args)
          vim.lsp.start({
            name = 'ts_ls',
            cmd = { 'typescript-language-server', '--stdio' },
            root_dir = vim.fs.root(args.buf, { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' }),
            capabilities = capabilities,
          })
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'lua' },
        callback = function(args)
          vim.lsp.start({
            name = 'lua_ls',
            cmd = { 'lua-language-server' },
            root_dir = vim.fs.root(args.buf, { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' }),
            capabilities = capabilities,
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
          })
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'vue' },
        callback = function(args)
          local root_dir = vim.fs.root(args.buf, { 'package.json', 'vite.config.ts', 'vite.config.js', 'vue.config.js', 'nuxt.config.js', '.git' })
          vim.lsp.start({
            name = 'volar',
            cmd = { 'vue-language-server', '--stdio' },
            root_dir = root_dir,
            capabilities = capabilities,
            init_options = {
              typescript = {
                tsdk = get_typescript_server_path(root_dir)
              },
            },
          })
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
        callback = function(args)
          vim.lsp.start({
            name = 'clangd',
            cmd = { 'clangd', '--background-index', '--clang-tidy' },
            root_dir = vim.fs.root(args.buf, { '.clangd', '.clang-tidy', '.clang-format', 'compile_commands.json', 'compile_flags.txt', 'configure.ac', '.git' }),
            capabilities = capabilities,
          })
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'dart' },
        callback = function(args)
          local root_dir = vim.fs.root(args.buf, { 'pubspec.yaml', '.fvmrc', '.fvm/fvm_config.json', '.git' })

          -- Determine Dart command based on FVM availability
          local dart_cmd = get_dart_cmd()

          vim.lsp.start({
            name = 'dartls',
            cmd = dart_cmd,
            root_dir = root_dir,
            capabilities = capabilities,
            settings = {
              dart = {
                completeFunctionCalls = true,
                showTodos = true,
              }
            },
            init_options = {
              onlyAnalyzeProjectsWithOpenFiles = true,
              suggestFromUnimportedLibraries = true,
              closingLabels = true,
              outline = true,
              flutterOutline = true,
            },
          })
        end,
      })

      -- Configure diagnostics with more explicit settings
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          source = "always",
          prefix = "●",
        },
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
        signs = {
          active = true,
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- Define diagnostic signs
      local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- Diagnostic keymaps
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
      vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

      -- Debug diagnostic display
      vim.keymap.set('n', '<leader>dd', function()
        print('Virtual text enabled:', vim.diagnostic.config().virtual_text ~= false)
        print('Signs enabled:', vim.diagnostic.config().signs ~= false)
        print('Diagnostic count:', #vim.diagnostic.get(0))
        vim.diagnostic.show()
      end, { desc = 'Debug diagnostics' })

      -- Ensure on_attach runs for all LSP clients
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client then
            on_attach(client, ev.buf)
          end
        end,
      })
    end,
  },
}