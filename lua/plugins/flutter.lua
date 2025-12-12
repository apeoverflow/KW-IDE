return {
  {
    -- Flutter tools for enhanced development experience
    'akinsho/flutter-tools.nvim',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim',
    },
    config = function()
      require("flutter-tools").setup({
        ui = {
          border = "rounded",
          notification_style = 'native',
        },
        decorations = {
          statusline = {
            app_version = true,
            device = true,
          }
        },
        debugger = {
          enabled = true,
          run_via_dap = true,
          exception_breakpoints = {},
          register_configurations = function(_)
            local dap = require('dap')
            dap.adapters.dart = {
              type = "executable",
              command = "dart",
              args = {"debug_adapter"}
            }
            dap.configurations.dart = {
              {
                type = "dart",
                request = "launch",
                name = "Launch dart",
                dartSdkPath = "${workspaceFolder}",
                flutterSdkPath = "${workspaceFolder}",
                program = "${workspaceFolder}/lib/main.dart",
                cwd = "${workspaceFolder}",
              }
            }
          end,
        },
        flutter_path = nil, -- Let FVM handle this
        flutter_lookup_cmd = nil, -- Let FVM handle this
        fvm = true,
        widget_guides = {
          enabled = true,
        },
        closing_tags = {
          highlight = "Comment",
          prefix = "// ",
          enabled = true
        },
        dev_log = {
          enabled = true,
          notify_errors = true,
          open_cmd = "tabnew",
        },
        dev_tools = {
          autostart = false,
          auto_open_browser = false,
        },
        outline = {
          open_cmd = "30vnew",
          auto_open = false
        },
        lsp = {
          color = {
            enabled = true,
            background = false,
            background_color = nil,
            foreground = false,
            virtual_text = true,
            virtual_text_str = "■",
          },
          on_attach = function(client, bufnr)
            -- Additional Flutter-specific setup
            vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

            -- Buffer local mappings
            local opts = { noremap = true, silent = true, buffer = bufnr }

            -- Flutter specific keymaps
            vim.keymap.set('n', '<leader>ft', '<cmd>FlutterRun<cr>', vim.tbl_extend('force', opts, { desc = 'Flutter Run' }))
            vim.keymap.set('n', '<leader>fq', '<cmd>FlutterQuit<cr>', vim.tbl_extend('force', opts, { desc = 'Flutter Quit' }))
            vim.keymap.set('n', '<leader>fh', '<cmd>FlutterReload<cr>', vim.tbl_extend('force', opts, { desc = 'Flutter Hot Reload' }))
            vim.keymap.set('n', '<leader>fR', '<cmd>FlutterRestart<cr>', vim.tbl_extend('force', opts, { desc = 'Flutter Hot Restart' }))
            vim.keymap.set('n', '<leader>fd', '<cmd>FlutterDevices<cr>', vim.tbl_extend('force', opts, { desc = 'Flutter Devices' }))
            vim.keymap.set('n', '<leader>fe', '<cmd>FlutterEmulators<cr>', vim.tbl_extend('force', opts, { desc = 'Flutter Emulators' }))
            vim.keymap.set('n', '<leader>fo', '<cmd>FlutterOutlineToggle<cr>', vim.tbl_extend('force', opts, { desc = 'Flutter Outline Toggle' }))
            vim.keymap.set('n', '<leader>fdt', '<cmd>FlutterDevTools<cr>', vim.tbl_extend('force', opts, { desc = 'Flutter Dev Tools' }))
            vim.keymap.set('n', '<leader>fc', '<cmd>FlutterLogClear<cr>', vim.tbl_extend('force', opts, { desc = 'Flutter Log Clear' }))
            vim.keymap.set('n', '<leader>fl', '<cmd>FlutterLspRestart<cr>', vim.tbl_extend('force', opts, { desc = 'Flutter LSP Restart' }))

            -- Testing keymaps
            vim.keymap.set('n', '<leader>ft', '<cmd>lua require("flutter-tools.utils").test_file()<cr>', vim.tbl_extend('force', opts, { desc = 'Test Current File' }))
            vim.keymap.set('n', '<leader>fT', '<cmd>lua require("flutter-tools.utils").test_project()<cr>', vim.tbl_extend('force', opts, { desc = 'Test Project' }))
          end,
          capabilities = require('cmp_nvim_lsp').default_capabilities(),
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
            renameFilesWithClasses = "prompt",
            enableSnippets = true,
            updateImportsOnRename = true,
          }
        },
      })

      -- Helper function to get Flutter command with FVM support
      local function get_flutter_cmd(cmd)
        local fvm_check = vim.fn.system('fvm --version 2>/dev/null'):gsub('\n', '')
        if fvm_check ~= '' then
          return 'fvm flutter ' .. cmd
        else
          return 'flutter ' .. cmd
        end
      end

      -- Create Flutter-specific commands
      vim.api.nvim_create_user_command('FlutterPubGet', function()
        local cmd = get_flutter_cmd('pub get')
        vim.fn.system('cd ' .. vim.fn.getcwd() .. ' && ' .. cmd)
        print('Flutter pub get completed')
      end, { desc = 'Run flutter pub get' })

      vim.api.nvim_create_user_command('FlutterPubUpgrade', function()
        local cmd = get_flutter_cmd('pub upgrade')
        vim.fn.system('cd ' .. vim.fn.getcwd() .. ' && ' .. cmd)
        print('Flutter pub upgrade completed')
      end, { desc = 'Run flutter pub upgrade' })

      vim.api.nvim_create_user_command('FlutterClean', function()
        local cmd = get_flutter_cmd('clean')
        vim.fn.system('cd ' .. vim.fn.getcwd() .. ' && ' .. cmd)
        print('Flutter clean completed')
      end, { desc = 'Run flutter clean' })

      vim.api.nvim_create_user_command('FlutterDoctor', function()
        local cmd = get_flutter_cmd('doctor')
        vim.cmd('split')
        vim.cmd('terminal ' .. cmd)
        vim.cmd('resize 15')
      end, { desc = 'Run flutter doctor' })

      -- Auto-format Dart files on save
      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*.dart',
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
        desc = 'Auto-format Dart files on save',
      })
    end
  },

  {
    -- Enhanced debugging support for Flutter/Dart and C/C++
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'nvim-neotest/nvim-nio',
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')

      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        element_mappings = {},
        expand_lines = vim.fn.has("nvim-0.7") == 1,
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 0.25,
            position = "bottom",
          },
        },
        controls = {
          enabled = true,
          element = "repl",
          icons = {
            pause = "",
            play = "",
            step_into = "",
            step_over = "",
            step_out = "",
            step_back = "",
            run_last = "↻",
            terminate = "□",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "rounded",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil,
          max_value_lines = 100,
        },
      })

      -- Auto open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- C/C++ debugging with codelldb (LLDB adapter)
      local codelldb_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb"
      local liblldb_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/lldb/lib/liblldb.dylib"

      -- Check if codelldb is installed via Mason
      if vim.fn.filereadable(codelldb_path) == 1 then
        dap.adapters.codelldb = {
          type = "server",
          port = "${port}",
          executable = {
            command = codelldb_path,
            args = { "--port", "${port}" },
          },
        }
      else
        -- Fallback to lldb-vscode if available
        if vim.fn.executable("lldb-vscode") == 1 then
          dap.adapters.codelldb = {
            type = "executable",
            command = "lldb-vscode",
            name = "lldb",
          }
        elseif vim.fn.executable("lldb-dap") == 1 then
          dap.adapters.codelldb = {
            type = "executable",
            command = "lldb-dap",
            name = "lldb",
          }
        end
      end

      -- C/C++ debug configurations
      dap.configurations.cpp = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
        {
          name = "Launch with arguments",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = function()
            local args_string = vim.fn.input("Arguments: ")
            return vim.split(args_string, " ")
          end,
        },
        {
          name = "Attach to process",
          type = "codelldb",
          request = "attach",
          pid = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }

      -- Use same configs for C
      dap.configurations.c = dap.configurations.cpp

      -- Debugging keymaps
      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
      vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<F4>', dap.run_to_cursor, { desc = 'Debug: Run to Cursor' })
      vim.keymap.set('n', '<F6>', dap.pause, { desc = 'Debug: Pause' })
      vim.keymap.set('n', '<F9>', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<F10>', dap.terminate, { desc = 'Debug: Terminate' })
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
      end, { desc = 'Debug: Set Conditional Breakpoint' })
      vim.keymap.set('n', '<leader>lp', function()
        dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
      end, { desc = 'Debug: Set Log Point' })
      vim.keymap.set('n', '<leader>dr', dap.repl.open, { desc = 'Debug: Open REPL' })
      vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = 'Debug: Run Last' })
      vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = 'Debug: Toggle UI' })
      vim.keymap.set('n', '<leader>de', dapui.eval, { desc = 'Debug: Evaluate' })
      vim.keymap.set('v', '<leader>de', dapui.eval, { desc = 'Debug: Evaluate Selection' })

      -- Configure virtual text
      require('nvim-dap-virtual-text').setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        filter_references_pattern = '<module',
        virt_text_pos = 'eol',
        all_frames = false,
        virt_lines = false,
        virt_text_win_col = nil,
      })

      -- Breakpoint signs
      vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
      vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DapBreakpointCondition', linehl = '', numhl = '' })
      vim.fn.sign_define('DapLogPoint', { text = '◇', texthl = 'DapLogPoint', linehl = '', numhl = '' })
      vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DapStopped', linehl = 'DapStoppedLine', numhl = '' })
      vim.fn.sign_define('DapBreakpointRejected', { text = '○', texthl = 'DapBreakpointRejected', linehl = '', numhl = '' })

      -- Highlight groups for DAP signs
      vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#e51400' })
      vim.api.nvim_set_hl(0, 'DapBreakpointCondition', { fg = '#f0a30a' })
      vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef' })
      vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#98c379' })
      vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#2e4d3d' })
      vim.api.nvim_set_hl(0, 'DapBreakpointRejected', { fg = '#5c6370' })
    end
  },

  {
    -- Better terminal integration
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        persist_size = true,
        direction = "float",
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
          border = "curved",
          winblend = 0,
          highlights = {
            border = "Normal",
            background = "Normal",
          },
        },
      })

      -- Flutter terminal functions
      local Terminal = require('toggleterm.terminal').Terminal

      -- Helper function to get Flutter command
      local function get_flutter_terminal_cmd(subcmd)
        local fvm_check = vim.fn.system('fvm --version 2>/dev/null'):gsub('\n', '')
        if fvm_check ~= '' then
          local fvm_config = vim.fn.findfile('.fvmrc', '.;') or vim.fn.findfile('.fvm/fvm_config.json', '.;')
          if fvm_config ~= '' then
            return "fvm flutter " .. subcmd
          end
        end
        return "flutter " .. subcmd
      end

      -- Flutter run terminal (with FVM support)
      local flutter_run = Terminal:new({
        cmd = get_flutter_terminal_cmd("run"),
        dir = "git_dir",
        direction = "horizontal",
        close_on_exit = false,
        on_open = function(term)
          vim.cmd("startinsert!")
        end,
      })

      function _flutter_run_toggle()
        flutter_run:toggle(15)
      end

      -- Flutter test terminal (with FVM support)
      local flutter_test = Terminal:new({
        cmd = get_flutter_terminal_cmd("test"),
        dir = "git_dir",
        direction = "horizontal",
        close_on_exit = false,
      })

      function _flutter_test_toggle()
        flutter_test:toggle(15)
      end

      vim.api.nvim_set_keymap("n", "<leader>fr", "<cmd>lua _flutter_run_toggle()<CR>", {noremap = true, silent = true, desc = "Flutter Run Terminal"})
      vim.api.nvim_set_keymap("n", "<leader>ft", "<cmd>lua _flutter_test_toggle()<CR>", {noremap = true, silent = true, desc = "Flutter Test Terminal"})
    end
  }
}