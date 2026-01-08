return {
  -- Rust IDE Configuration
  -- Enhanced rust-analyzer, cargo integration, debugging, and testing
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy = false,
    ft = { "rust" },
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      -- Helper function to check if in a Rust project
      local function is_rust_project()
        return vim.fn.filereadable(vim.fn.getcwd() .. "/Cargo.toml") == 1
      end

      vim.g.rustaceanvim = {
        -- Plugin configuration
        tools = {
          hover_actions = {
            auto_focus = true,
          },
        },
        -- LSP configuration
        server = {
          on_attach = function(client, bufnr)
            -- Use the same on_attach as other LSPs for consistency
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

            -- Diagnostic keybindings
            nmap('[d', vim.diagnostic.goto_prev, 'Previous diagnostic')
            nmap(']d', vim.diagnostic.goto_next, 'Next diagnostic')
            nmap('<leader>e', vim.diagnostic.open_float, 'Show diagnostic')

            -- Create format command
            vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
              vim.lsp.buf.format()
            end, { desc = 'Format current buffer with LSP' })

            -- Enable inlay hints if supported
            if client.server_capabilities.inlayHintProvider then
              vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end
          end,
          default_settings = {
            -- rust-analyzer language server configuration
            ['rust-analyzer'] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                buildScripts = {
                  enable = true,
                },
              },
              checkOnSave = {
                allFeatures = true,
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
              procMacro = {
                enable = true,
                ignored = {
                  ["async-trait"] = { "async_trait" },
                  ["napi-derive"] = { "napi" },
                  ["async-recursion"] = { "async_recursion" },
                },
              },
              diagnostics = {
                enable = true,
                experimental = {
                  enable = true,
                },
              },
              inlayHints = {
                bindingModeHints = {
                  enable = false,
                },
                chainingHints = {
                  enable = true,
                },
                closingBraceHints = {
                  enable = true,
                  minLines = 25,
                },
                closureReturnTypeHints = {
                  enable = "never",
                },
                lifetimeElisionHints = {
                  enable = "never",
                  useParameterNames = false,
                },
                maxLength = 25,
                parameterHints = {
                  enable = true,
                },
                reborrowHints = {
                  enable = "never",
                },
                renderColons = true,
                typeHints = {
                  enable = true,
                  hideClosureInitialization = false,
                  hideNamedConstructor = false,
                },
              },
            },
          },
        },
        -- DAP configuration
        dap = {
          adapter = require('rustaceanvim.config').get_codelldb_adapter(
            vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
            vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/lldb/lib/liblldb.dylib"
          ),
        },
      }

      -- Create Rust-specific user commands

      -- Build project with cargo
      vim.api.nvim_create_user_command("RustBuild", function()
        vim.cmd("split")
        vim.cmd("terminal cargo build")
        vim.cmd("resize 12")
      end, { desc = "Build Rust project with cargo" })

      -- Build release
      vim.api.nvim_create_user_command("RustBuildRelease", function()
        vim.cmd("split")
        vim.cmd("terminal cargo build --release")
        vim.cmd("resize 12")
      end, { desc = "Build Rust project in release mode" })

      -- Run project
      vim.api.nvim_create_user_command("RustRun", function(opts)
        local args = opts.args ~= "" and " -- " .. opts.args or ""
        vim.cmd("split")
        vim.cmd("terminal cargo run" .. args)
        vim.cmd("resize 15")
      end, { nargs = "*", desc = "Run Rust project with optional args" })

      -- Run tests
      vim.api.nvim_create_user_command("RustTest", function(opts)
        local test_name = opts.args ~= "" and " " .. opts.args or ""
        vim.cmd("split")
        vim.cmd("terminal cargo test" .. test_name)
        vim.cmd("resize 15")
      end, { nargs = "?", desc = "Run Rust tests" })

      -- Run tests with output
      vim.api.nvim_create_user_command("RustTestVerbose", function()
        vim.cmd("split")
        vim.cmd("terminal cargo test -- --nocapture")
        vim.cmd("resize 15")
      end, { desc = "Run Rust tests with output" })

      -- Check project (faster than build)
      vim.api.nvim_create_user_command("RustCheck", function()
        vim.cmd("split")
        vim.cmd("terminal cargo check")
        vim.cmd("resize 12")
      end, { desc = "Check Rust project (fast compile check)" })

      -- Run clippy
      vim.api.nvim_create_user_command("RustClippy", function()
        vim.cmd("split")
        vim.cmd("terminal cargo clippy")
        vim.cmd("resize 12")
      end, { desc = "Run clippy lints" })

      -- Format with rustfmt
      vim.api.nvim_create_user_command("RustFmt", function()
        vim.fn.system("cargo fmt")
        vim.cmd("edit!")
        print("Formatted with rustfmt")
      end, { desc = "Format project with rustfmt" })

      -- Clean build artifacts
      vim.api.nvim_create_user_command("RustClean", function()
        vim.fn.system("cargo clean")
        print("Cargo clean completed")
      end, { desc = "Clean Rust build artifacts" })

      -- Update dependencies
      vim.api.nvim_create_user_command("RustUpdate", function()
        vim.cmd("split")
        vim.cmd("terminal cargo update")
        vim.cmd("resize 12")
      end, { desc = "Update Rust dependencies" })

      -- Open documentation
      vim.api.nvim_create_user_command("RustDoc", function()
        vim.cmd("split")
        vim.cmd("terminal cargo doc --open")
        vim.cmd("resize 12")
      end, { desc = "Build and open documentation" })

      -- Expand macros (using rustaceanvim)
      vim.api.nvim_create_user_command("RustExpandMacro", function()
        vim.cmd("RustLsp expandMacro")
      end, { desc = "Expand macro under cursor" })

      -- View HIR
      vim.api.nvim_create_user_command("RustViewHir", function()
        vim.cmd("RustLsp view hir")
      end, { desc = "View HIR" })

      -- View MIR
      vim.api.nvim_create_user_command("RustViewMir", function()
        vim.cmd("RustLsp view mir")
      end, { desc = "View MIR" })

      -- Open Cargo.toml
      vim.api.nvim_create_user_command("RustCargoToml", function()
        local cargo = vim.fn.findfile('Cargo.toml', '.;')
        if cargo ~= '' then
          vim.cmd('edit ' .. cargo)
        else
          print('Cargo.toml not found')
        end
      end, { desc = "Open Cargo.toml" })

      -- Show Rust toolchain info
      vim.api.nvim_create_user_command("RustInfo", function()
        print("=== Rust Development Info ===")

        -- Check rustc
        if vim.fn.executable("rustc") == 1 then
          local version = vim.fn.system("rustc --version"):gsub("\n", "")
          print("rustc: " .. version)
        else
          print("rustc: NOT FOUND - Install from https://rustup.rs")
        end

        -- Check cargo
        if vim.fn.executable("cargo") == 1 then
          local version = vim.fn.system("cargo --version"):gsub("\n", "")
          print("cargo: " .. version)
        else
          print("cargo: NOT FOUND - Install from https://rustup.rs")
        end

        -- Check rust-analyzer
        if vim.fn.executable("rust-analyzer") == 1 then
          print("rust-analyzer: installed")
        else
          print("rust-analyzer: NOT FOUND - Install with: rustup component add rust-analyzer")
        end

        -- Check rustfmt
        if vim.fn.executable("rustfmt") == 1 then
          print("rustfmt: installed")
        else
          print("rustfmt: NOT FOUND - Install with: rustup component add rustfmt")
        end

        -- Check clippy
        if vim.fn.executable("cargo-clippy") == 1 then
          print("clippy: installed")
        else
          print("clippy: NOT FOUND - Install with: rustup component add clippy")
        end

        -- Check codelldb for debugging
        local codelldb_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb"
        if vim.fn.filereadable(codelldb_path) == 1 then
          print("CodeLLDB (DAP): installed via Mason")
        else
          print("CodeLLDB (DAP): NOT FOUND - Install via :Mason")
        end

        -- Check if in Rust project
        if is_rust_project() then
          print("Rust Project: Cargo.toml found")

          -- Show active toolchain
          local toolchain = vim.fn.system("rustup show active-toolchain"):gsub("\n.*", "")
          print("Active Toolchain: " .. toolchain)
        else
          print("Rust Project: No Cargo.toml in current directory")
        end

        -- Active LSP
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients > 0 then
          for _, client in ipairs(clients) do
            if client.name == "rust-analyzer" or client.name == "rust_analyzer" then
              print("LSP Status: rust-analyzer attached")
            end
          end
        else
          print("LSP Status: No active LSP")
        end
      end, { desc = "Show Rust development info" })

      -- Rust-specific keybindings (buffer-local when opening Rust files)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "rust" },
        callback = function(args)
          local opts = { buffer = args.buf, silent = true }

          -- Build & Run
          vim.keymap.set("n", "<leader>rb", "<cmd>RustBuild<cr>", vim.tbl_extend("force", opts, { desc = "Rust Build" }))
          vim.keymap.set("n", "<leader>rr", "<cmd>RustRun<cr>", vim.tbl_extend("force", opts, { desc = "Rust Run" }))
          vim.keymap.set("n", "<leader>rt", "<cmd>RustTest<cr>", vim.tbl_extend("force", opts, { desc = "Rust Test" }))
          vim.keymap.set("n", "<leader>rT", "<cmd>RustTestVerbose<cr>", vim.tbl_extend("force", opts, { desc = "Rust Test Verbose" }))
          vim.keymap.set("n", "<leader>rk", "<cmd>RustCheck<cr>", vim.tbl_extend("force", opts, { desc = "Rust Check" }))
          vim.keymap.set("n", "<leader>rl", "<cmd>RustClippy<cr>", vim.tbl_extend("force", opts, { desc = "Rust Clippy" }))
          vim.keymap.set("n", "<leader>rf", "<cmd>RustFmt<cr>", vim.tbl_extend("force", opts, { desc = "Rust Format" }))
          vim.keymap.set("n", "<leader>rc", "<cmd>RustClean<cr>", vim.tbl_extend("force", opts, { desc = "Rust Clean" }))
          vim.keymap.set("n", "<leader>ru", "<cmd>RustUpdate<cr>", vim.tbl_extend("force", opts, { desc = "Rust Update" }))
          vim.keymap.set("n", "<leader>rd", "<cmd>RustDoc<cr>", vim.tbl_extend("force", opts, { desc = "Rust Doc" }))
          vim.keymap.set("n", "<leader>ri", "<cmd>RustInfo<cr>", vim.tbl_extend("force", opts, { desc = "Rust Info" }))

          -- Cargo.toml access
          vim.keymap.set("n", "<leader>rp", "<cmd>RustCargoToml<cr>", vim.tbl_extend("force", opts, { desc = "Open Cargo.toml" }))

          -- Rustaceanvim features
          vim.keymap.set("n", "<leader>rm", "<cmd>RustExpandMacro<cr>", vim.tbl_extend("force", opts, { desc = "Expand Macro" }))
          vim.keymap.set("n", "<leader>rh", "<cmd>RustViewHir<cr>", vim.tbl_extend("force", opts, { desc = "View HIR" }))
          vim.keymap.set("n", "<leader>rM", "<cmd>RustViewMir<cr>", vim.tbl_extend("force", opts, { desc = "View MIR" }))

          -- Hover actions
          vim.keymap.set("n", "<leader>ra", function()
            vim.cmd.RustLsp('codeAction')
          end, vim.tbl_extend("force", opts, { desc = "Rust Code Action" }))

          -- Runnables
          vim.keymap.set("n", "<leader>rR", function()
            vim.cmd.RustLsp('runnables')
          end, vim.tbl_extend("force", opts, { desc = "Rust Runnables" }))

          -- Debuggables
          vim.keymap.set("n", "<leader>rD", function()
            vim.cmd.RustLsp('debuggables')
          end, vim.tbl_extend("force", opts, { desc = "Rust Debuggables" }))

          -- Test under cursor
          vim.keymap.set("n", "<leader>rtt", function()
            vim.cmd.RustLsp('testables')
          end, vim.tbl_extend("force", opts, { desc = "Run Test Under Cursor" }))

          -- Explain error
          vim.keymap.set("n", "<leader>re", function()
            vim.cmd.RustLsp('explainError')
          end, vim.tbl_extend("force", opts, { desc = "Explain Error" }))

          -- Open Cargo.toml
          vim.keymap.set("n", "<leader>rC", function()
            vim.cmd.RustLsp('openCargo')
          end, vim.tbl_extend("force", opts, { desc = "Open Cargo.toml" }))

          -- Parent module
          vim.keymap.set("n", "<leader>rP", function()
            vim.cmd.RustLsp('parentModule')
          end, vim.tbl_extend("force", opts, { desc = "Parent Module" }))

          -- Join lines (smart Rust join)
          vim.keymap.set("n", "J", function()
            vim.cmd.RustLsp('joinLines')
          end, vim.tbl_extend("force", opts, { desc = "Join Lines" }))
        end,
      })

      -- Auto-format Rust files on save with rustfmt
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.rs" },
        callback = function()
          -- Use LSP formatting if available
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          for _, client in ipairs(clients) do
            if client.name == "rust-analyzer" or client.name == "rust_analyzer" then
              vim.lsp.buf.format({ async = false, timeout_ms = 3000 })
              return
            end
          end
        end,
        desc = "Auto-format Rust files on save",
      })

      -- Set up proper indentation for Rust
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "rust" },
        callback = function()
          vim.bo.tabstop = 4
          vim.bo.shiftwidth = 4
          vim.bo.softtabstop = 4
          vim.bo.expandtab = true
          vim.bo.textwidth = 100
        end,
      })

      -- Show diagnostics on cursor hold (Rust files only)
      vim.api.nvim_create_autocmd('CursorHold', {
        pattern = { "*.rs" },
        callback = function()
          local opts = {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            border = 'rounded',
            source = 'always',
            prefix = ' ',
            scope = 'cursor',
          }
          vim.diagnostic.open_float(nil, opts)
        end
      })
    end,
  },

  -- Crates.io integration for managing dependencies
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup({
        text = {
          loading = "  Loading...",
          version = "  %s",
          prerelease = "  %s",
          yanked = "  %s yanked",
          nomatch = "  Not found",
          upgrade = "  %s",
          error = "  Error fetching crate",
        },
        popup = {
          autofocus = true,
          hide_on_select = false,
          copy_register = '"',
          style = "minimal",
          border = "rounded",
          show_version_date = true,
          show_dependency_version = true,
          max_height = 30,
          min_width = 20,
          padding = 1,
        },
        src = {
          cmp = {
            enabled = true,
          },
        },
        null_ls = {
          enabled = false,
        },
      })

      -- Crates.nvim keybindings (only in Cargo.toml)
      -- Using <leader>C* (capital C) to avoid conflicts with C++ <leader>c* keybindings
      vim.api.nvim_create_autocmd("BufRead", {
        pattern = "Cargo.toml",
        callback = function(args)
          local opts = { buffer = args.buf, silent = true }
          local crates = require("crates")

          vim.keymap.set("n", "<leader>Ct", crates.toggle, vim.tbl_extend("force", opts, { desc = "Crates: Toggle" }))
          vim.keymap.set("n", "<leader>Cr", crates.reload, vim.tbl_extend("force", opts, { desc = "Crates: Reload" }))
          vim.keymap.set("n", "<leader>Cv", crates.show_versions_popup, vim.tbl_extend("force", opts, { desc = "Crates: Show Versions" }))
          vim.keymap.set("n", "<leader>Cf", crates.show_features_popup, vim.tbl_extend("force", opts, { desc = "Crates: Show Features" }))
          vim.keymap.set("n", "<leader>Cd", crates.show_dependencies_popup, vim.tbl_extend("force", opts, { desc = "Crates: Show Dependencies" }))
          vim.keymap.set("n", "<leader>Cu", crates.update_crate, vim.tbl_extend("force", opts, { desc = "Crates: Update Crate" }))
          vim.keymap.set("v", "<leader>Cu", crates.update_crates, vim.tbl_extend("force", opts, { desc = "Crates: Update Selected" }))
          vim.keymap.set("n", "<leader>CU", crates.upgrade_crate, vim.tbl_extend("force", opts, { desc = "Crates: Upgrade Crate" }))
          vim.keymap.set("v", "<leader>CU", crates.upgrade_crates, vim.tbl_extend("force", opts, { desc = "Crates: Upgrade Selected" }))
          vim.keymap.set("n", "<leader>CA", crates.upgrade_all_crates, vim.tbl_extend("force", opts, { desc = "Crates: Upgrade All" }))
          vim.keymap.set("n", "<leader>CH", crates.open_homepage, vim.tbl_extend("force", opts, { desc = "Crates: Open Homepage" }))
          vim.keymap.set("n", "<leader>CR", crates.open_repository, vim.tbl_extend("force", opts, { desc = "Crates: Open Repository" }))
          vim.keymap.set("n", "<leader>CD", crates.open_documentation, vim.tbl_extend("force", opts, { desc = "Crates: Open Documentation" }))
          vim.keymap.set("n", "<leader>CC", crates.open_crates_io, vim.tbl_extend("force", opts, { desc = "Crates: Open Crates.io" }))
        end,
      })
    end,
  },
}
