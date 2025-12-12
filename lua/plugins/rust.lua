return {
  -- Rust IDE Configuration
  -- rust-analyzer LSP, Cargo integration, debugging, and crates.nvim
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy = false,
    ft = { "rust" },
    config = function()
      vim.g.rustaceanvim = {
        -- Plugin configuration
        tools = {
          autoSetHints = true,
          inlay_hints = {
            show_parameter_hints = true,
            parameter_hints_prefix = "<- ",
            other_hints_prefix = "=> ",
          },
          hover_actions = {
            border = "rounded",
            auto_focus = true,
          },
          float_win_config = {
            border = "rounded",
          },
        },
        -- LSP configuration
        server = {
          on_attach = function(client, bufnr)
            local opts = { buffer = bufnr, silent = true }

            -- Rust-specific keybindings
            vim.keymap.set("n", "<leader>ra", function()
              vim.cmd.RustLsp("codeAction")
            end, vim.tbl_extend("force", opts, { desc = "Rust Code Action" }))

            vim.keymap.set("n", "<leader>rr", function()
              vim.cmd.RustLsp("runnables")
            end, vim.tbl_extend("force", opts, { desc = "Rust Runnables" }))

            vim.keymap.set("n", "<leader>rd", function()
              vim.cmd.RustLsp("debuggables")
            end, vim.tbl_extend("force", opts, { desc = "Rust Debuggables" }))

            vim.keymap.set("n", "<leader>rt", function()
              vim.cmd.RustLsp("testables")
            end, vim.tbl_extend("force", opts, { desc = "Rust Testables" }))

            vim.keymap.set("n", "<leader>rm", function()
              vim.cmd.RustLsp("expandMacro")
            end, vim.tbl_extend("force", opts, { desc = "Rust Expand Macro" }))

            vim.keymap.set("n", "<leader>rc", function()
              vim.cmd.RustLsp("openCargo")
            end, vim.tbl_extend("force", opts, { desc = "Open Cargo.toml" }))

            vim.keymap.set("n", "<leader>rp", function()
              vim.cmd.RustLsp("parentModule")
            end, vim.tbl_extend("force", opts, { desc = "Rust Parent Module" }))

            vim.keymap.set("n", "<leader>rj", function()
              vim.cmd.RustLsp("joinLines")
            end, vim.tbl_extend("force", opts, { desc = "Rust Join Lines" }))

            vim.keymap.set("n", "<leader>rh", function()
              vim.cmd.RustLsp({ "hover", "actions" })
            end, vim.tbl_extend("force", opts, { desc = "Rust Hover Actions" }))

            vim.keymap.set("n", "<leader>re", function()
              vim.cmd.RustLsp("explainError")
            end, vim.tbl_extend("force", opts, { desc = "Rust Explain Error" }))

            vim.keymap.set("n", "<leader>rD", function()
              vim.cmd.RustLsp("renderDiagnostic")
            end, vim.tbl_extend("force", opts, { desc = "Rust Render Diagnostic" }))

            vim.keymap.set("n", "<leader>ro", function()
              vim.cmd.RustLsp("openDocs")
            end, vim.tbl_extend("force", opts, { desc = "Rust Open Docs" }))

            vim.keymap.set("n", "J", function()
              vim.cmd.RustLsp("joinLines")
            end, vim.tbl_extend("force", opts, { desc = "Rust Join Lines" }))

            -- Cargo keybindings
            vim.keymap.set("n", "<leader>Rb", "<cmd>RustLsp! runnables<cr>", vim.tbl_extend("force", opts, { desc = "Cargo Build (last)" }))
            vim.keymap.set("n", "<leader>Rr", "<cmd>RustLsp! runnables<cr>", vim.tbl_extend("force", opts, { desc = "Cargo Run (last)" }))
            vim.keymap.set("n", "<leader>Rt", "<cmd>RustLsp! testables<cr>", vim.tbl_extend("force", opts, { desc = "Cargo Test (last)" }))

            -- Enable inlay hints
            if client.server_capabilities.inlayHintProvider then
              vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end
          end,
          default_settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
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
              inlayHints = {
                bindingModeHints = { enable = true },
                chainingHints = { enable = true },
                closingBraceHints = { enable = true, minLines = 25 },
                closureReturnTypeHints = { enable = "with_block" },
                lifetimeElisionHints = { enable = "skip_trivial", useParameterNames = true },
                maxLength = 25,
                parameterHints = { enable = true },
                reborrowHints = { enable = "mutable" },
                renderColons = true,
                typeHints = {
                  enable = true,
                  hideClosureInitialization = false,
                  hideNamedConstructor = false,
                },
              },
              completion = {
                fullFunctionSignatures = { enable = true },
                postfix = { enable = true },
              },
              diagnostics = {
                enable = true,
                experimental = { enable = true },
              },
              lens = {
                enable = true,
                references = {
                  adt = { enable = true },
                  enumVariant = { enable = true },
                  method = { enable = true },
                  trait = { enable = true },
                },
              },
            },
          },
        },
        -- DAP configuration
        dap = {
          adapter = {
            type = "executable",
            command = "lldb-vscode",
            name = "rt_lldb",
          },
        },
      }
    end,
  },

  -- Crates.nvim for Cargo.toml management
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local crates = require("crates")
      crates.setup({
        smart_insert = true,
        insert_closing_quote = true,
        autoload = true,
        autoupdate = true,
        autoupdate_throttle = 250,
        loading_indicator = true,
        date_format = "%Y-%m-%d",
        thousands_separator = ",",
        notification_title = "crates.nvim",
        curl_args = { "-sL", "--retry", "1" },
        max_parallel_requests = 80,
        open_programs = { "xdg-open", "open" },
        popup = {
          autofocus = false,
          hide_on_select = false,
          copy_register = '"',
          style = "minimal",
          border = "rounded",
          show_version_date = true,
          show_dependency_version = true,
          max_height = 30,
          min_width = 20,
          padding = 1,
          text = {
            title = " %s",
            pill_left = "",
            pill_right = "",
            description = "%s",
            created_label = " created        ",
            created = "%s",
            updated_label = " updated        ",
            updated = "%s",
            downloads_label = " downloads      ",
            downloads = "%s",
            homepage_label = " homepage       ",
            homepage = "%s",
            repository_label = " repository     ",
            repository = "%s",
            documentation_label = " documentation  ",
            documentation = "%s",
            crates_io_label = " crates.io      ",
            crates_io = "%s",
            categories_label = " categories     ",
            keywords_label = " keywords       ",
            version = "  %s",
            prerelease = " %s",
            yanked = " %s",
            version_date = "  %s",
            feature = "  %s",
            enabled = " %s",
            transitive = " %s",
            normal_dependencies_title = " Dependencies",
            build_dependencies_title = " Build dependencies",
            dev_dependencies_title = " Dev dependencies",
            dependency = "  %s",
            optional = " %s",
            dependency_version = "  %s",
            loading = "  ",
          },
          highlight = {
            title = "CratesNvimPopupTitle",
            pill_text = "CratesNvimPopupPillText",
            pill_border = "CratesNvimPopupPillBorder",
            description = "CratesNvimPopupDescription",
            created_label = "CratesNvimPopupLabel",
            created = "CratesNvimPopupValue",
            updated_label = "CratesNvimPopupLabel",
            updated = "CratesNvimPopupValue",
            downloads_label = "CratesNvimPopupLabel",
            downloads = "CratesNvimPopupValue",
            homepage_label = "CratesNvimPopupLabel",
            homepage = "CratesNvimPopupUrl",
            repository_label = "CratesNvimPopupLabel",
            repository = "CratesNvimPopupUrl",
            documentation_label = "CratesNvimPopupLabel",
            documentation = "CratesNvimPopupUrl",
            crates_io_label = "CratesNvimPopupLabel",
            crates_io = "CratesNvimPopupUrl",
            categories_label = "CratesNvimPopupLabel",
            keywords_label = "CratesNvimPopupLabel",
            version = "CratesNvimPopupVersion",
            prerelease = "CratesNvimPopupPreRelease",
            yanked = "CratesNvimPopupYanked",
            version_date = "CratesNvimPopupVersionDate",
            feature = "CratesNvimPopupFeature",
            enabled = "CratesNvimPopupEnabled",
            transitive = "CratesNvimPopupTransitive",
            normal_dependencies_title = "CratesNvimPopupNormalDependenciesTitle",
            build_dependencies_title = "CratesNvimPopupBuildDependenciesTitle",
            dev_dependencies_title = "CratesNvimPopupDevDependenciesTitle",
            dependency = "CratesNvimPopupDependency",
            optional = "CratesNvimPopupOptional",
            dependency_version = "CratesNvimPopupDependencyVersion",
            loading = "CratesNvimPopupLoading",
          },
          keys = {
            hide = { "q", "<esc>" },
            open_url = { "<cr>" },
            select = { "<cr>" },
            select_alt = { "s" },
            toggle_feature = { "<cr>" },
            copy_value = { "yy" },
            goto_item = { "gd", "K", "<C-LeftMouse>" },
            jump_forward = { "<c-i>" },
            jump_back = { "<c-o>", "<C-RightMouse>" },
          },
        },
        completion = {
          insert_closing_quote = true,
          text = {
            prerelease = "  pre-release ",
            yanked = "  yanked ",
          },
          cmp = {
            enabled = true,
          },
          coq = {
            enabled = false,
            name = "crates.nvim",
          },
        },
        lsp = {
          enabled = true,
          on_attach = function(client, bufnr)
            -- Crates.nvim keybindings for Cargo.toml
            local opts = { buffer = bufnr, silent = true }

            vim.keymap.set("n", "<leader>ct", crates.toggle, vim.tbl_extend("force", opts, { desc = "Toggle Crates" }))
            vim.keymap.set("n", "<leader>cr", crates.reload, vim.tbl_extend("force", opts, { desc = "Reload Crates" }))

            vim.keymap.set("n", "<leader>cv", crates.show_versions_popup, vim.tbl_extend("force", opts, { desc = "Show Versions" }))
            vim.keymap.set("n", "<leader>cf", crates.show_features_popup, vim.tbl_extend("force", opts, { desc = "Show Features" }))
            vim.keymap.set("n", "<leader>cd", crates.show_dependencies_popup, vim.tbl_extend("force", opts, { desc = "Show Dependencies" }))

            vim.keymap.set("n", "<leader>cu", crates.update_crate, vim.tbl_extend("force", opts, { desc = "Update Crate" }))
            vim.keymap.set("v", "<leader>cu", crates.update_crates, vim.tbl_extend("force", opts, { desc = "Update Crates" }))
            vim.keymap.set("n", "<leader>ca", crates.update_all_crates, vim.tbl_extend("force", opts, { desc = "Update All Crates" }))
            vim.keymap.set("n", "<leader>cU", crates.upgrade_crate, vim.tbl_extend("force", opts, { desc = "Upgrade Crate" }))
            vim.keymap.set("v", "<leader>cU", crates.upgrade_crates, vim.tbl_extend("force", opts, { desc = "Upgrade Crates" }))
            vim.keymap.set("n", "<leader>cA", crates.upgrade_all_crates, vim.tbl_extend("force", opts, { desc = "Upgrade All Crates" }))

            vim.keymap.set("n", "<leader>cx", crates.expand_plain_crate_to_inline_table, vim.tbl_extend("force", opts, { desc = "Expand Crate to Table" }))
            vim.keymap.set("n", "<leader>cX", crates.extract_crate_into_table, vim.tbl_extend("force", opts, { desc = "Extract Crate to Table" }))

            vim.keymap.set("n", "<leader>cH", crates.open_homepage, vim.tbl_extend("force", opts, { desc = "Open Homepage" }))
            vim.keymap.set("n", "<leader>cR", crates.open_repository, vim.tbl_extend("force", opts, { desc = "Open Repository" }))
            vim.keymap.set("n", "<leader>cD", crates.open_documentation, vim.tbl_extend("force", opts, { desc = "Open Documentation" }))
            vim.keymap.set("n", "<leader>cC", crates.open_crates_io, vim.tbl_extend("force", opts, { desc = "Open crates.io" }))
          end,
          actions = true,
          completion = true,
          hover = true,
        },
      })
    end,
  },

  -- Rust-specific functionality and commands
  {
    "nvim-lua/plenary.nvim",
    lazy = false,
    config = function()
      -- Helper function to check if in a Rust project
      local function is_rust_project()
        return vim.fn.filereadable(vim.fn.getcwd() .. "/Cargo.toml") == 1
      end

      -- Create user commands for Rust development

      -- Cargo build
      vim.api.nvim_create_user_command("CargoBuild", function(opts)
        local args = opts.args ~= "" and " " .. opts.args or ""
        vim.cmd("split")
        vim.cmd("terminal cargo build" .. args)
        vim.cmd("resize 12")
      end, { nargs = "*", desc = "Run cargo build" })

      -- Cargo run
      vim.api.nvim_create_user_command("CargoRun", function(opts)
        local args = opts.args ~= "" and " " .. opts.args or ""
        vim.cmd("split")
        vim.cmd("terminal cargo run" .. args)
        vim.cmd("resize 15")
      end, { nargs = "*", desc = "Run cargo run" })

      -- Cargo test
      vim.api.nvim_create_user_command("CargoTest", function(opts)
        local args = opts.args ~= "" and " " .. opts.args or ""
        vim.cmd("split")
        vim.cmd("terminal cargo test" .. args)
        vim.cmd("resize 15")
      end, { nargs = "*", desc = "Run cargo test" })

      -- Cargo check
      vim.api.nvim_create_user_command("CargoCheck", function(opts)
        local args = opts.args ~= "" and " " .. opts.args or ""
        vim.cmd("split")
        vim.cmd("terminal cargo check" .. args)
        vim.cmd("resize 12")
      end, { nargs = "*", desc = "Run cargo check" })

      -- Cargo clippy
      vim.api.nvim_create_user_command("CargoClippy", function(opts)
        local args = opts.args ~= "" and " " .. opts.args or ""
        vim.cmd("split")
        vim.cmd("terminal cargo clippy" .. args)
        vim.cmd("resize 15")
      end, { nargs = "*", desc = "Run cargo clippy" })

      -- Cargo fmt
      vim.api.nvim_create_user_command("CargoFmt", function()
        vim.cmd("!cargo fmt")
        vim.cmd("edit")
        print("Cargo fmt completed")
      end, { desc = "Run cargo fmt" })

      -- Cargo clean
      vim.api.nvim_create_user_command("CargoClean", function()
        vim.fn.system("cargo clean")
        print("Cargo clean completed")
      end, { desc = "Run cargo clean" })

      -- Cargo doc
      vim.api.nvim_create_user_command("CargoDoc", function(opts)
        local open_flag = opts.bang and " --open" or ""
        vim.cmd("split")
        vim.cmd("terminal cargo doc" .. open_flag)
        vim.cmd("resize 12")
      end, { bang = true, desc = "Run cargo doc (! to open)" })

      -- Cargo add
      vim.api.nvim_create_user_command("CargoAdd", function(opts)
        if opts.args == "" then
          print("Usage: :CargoAdd <crate_name>")
          return
        end
        vim.cmd("split")
        vim.cmd("terminal cargo add " .. opts.args)
        vim.cmd("resize 10")
      end, { nargs = "+", desc = "Add a crate dependency" })

      -- Cargo remove
      vim.api.nvim_create_user_command("CargoRemove", function(opts)
        if opts.args == "" then
          print("Usage: :CargoRemove <crate_name>")
          return
        end
        vim.fn.system("cargo remove " .. opts.args)
        print("Removed: " .. opts.args)
      end, { nargs = "+", desc = "Remove a crate dependency" })

      -- Cargo update
      vim.api.nvim_create_user_command("CargoUpdate", function()
        vim.cmd("split")
        vim.cmd("terminal cargo update")
        vim.cmd("resize 12")
      end, { desc = "Run cargo update" })

      -- Cargo bench
      vim.api.nvim_create_user_command("CargoBench", function(opts)
        local args = opts.args ~= "" and " " .. opts.args or ""
        vim.cmd("split")
        vim.cmd("terminal cargo bench" .. args)
        vim.cmd("resize 15")
      end, { nargs = "*", desc = "Run cargo bench" })

      -- Show Rust info
      vim.api.nvim_create_user_command("RustInfo", function()
        print("=== Rust Development Info ===")

        -- Check rustc
        if vim.fn.executable("rustc") == 1 then
          local version = vim.fn.system("rustc --version"):gsub("\n", "")
          print("rustc: " .. version)
        else
          print("rustc: NOT FOUND - Install via rustup")
        end

        -- Check cargo
        if vim.fn.executable("cargo") == 1 then
          local version = vim.fn.system("cargo --version"):gsub("\n", "")
          print("cargo: " .. version)
        else
          print("cargo: NOT FOUND - Install via rustup")
        end

        -- Check rust-analyzer
        if vim.fn.executable("rust-analyzer") == 1 then
          local version = vim.fn.system("rust-analyzer --version 2>/dev/null"):gsub("\n", "")
          print("rust-analyzer: " .. (version ~= "" and version or "installed"))
        else
          print("rust-analyzer: NOT FOUND - Install via rustup component add rust-analyzer")
        end

        -- Check clippy
        if vim.fn.executable("cargo-clippy") == 1 then
          print("clippy: installed")
        else
          print("clippy: NOT FOUND - Install via rustup component add clippy")
        end

        -- Check rustfmt
        if vim.fn.executable("rustfmt") == 1 then
          print("rustfmt: installed")
        else
          print("rustfmt: NOT FOUND - Install via rustup component add rustfmt")
        end

        -- Check debugger
        local codelldb_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb"
        if vim.fn.filereadable(codelldb_path) == 1 then
          print("CodeLLDB (DAP): installed via Mason")
        elseif vim.fn.executable("lldb-vscode") == 1 then
          print("lldb-vscode: installed")
        else
          print("Debugger: NOT FOUND - Install CodeLLDB via :Mason")
        end

        -- Check if in Rust project
        if is_rust_project() then
          print("Project: Cargo.toml found")
          local cargo_name = vim.fn.system("grep '^name' Cargo.toml | head -1"):gsub("\n", "")
          if cargo_name ~= "" then
            print("  " .. cargo_name)
          end
        else
          print("Project: No Cargo.toml found")
        end

        -- Active LSP
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        for _, client in ipairs(clients) do
          if client.name == "rust-analyzer" or client.name == "rust_analyzer" then
            print("LSP Status: rust-analyzer attached")
          end
        end
      end, { desc = "Show Rust development info" })

      -- Create new Rust project
      vim.api.nvim_create_user_command("CargoNew", function(opts)
        if opts.args == "" then
          print("Usage: :CargoNew <project_name> [--lib]")
          return
        end
        vim.cmd("split")
        vim.cmd("terminal cargo new " .. opts.args)
        vim.cmd("resize 10")
      end, { nargs = "+", desc = "Create new Cargo project" })

      -- Rust-specific keybindings (buffer-local when opening Rust files)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "rust" },
        callback = function(args)
          local opts = { buffer = args.buf, silent = true }

          -- Cargo commands
          vim.keymap.set("n", "<leader>Cb", "<cmd>CargoBuild<cr>", vim.tbl_extend("force", opts, { desc = "Cargo Build" }))
          vim.keymap.set("n", "<leader>Cr", "<cmd>CargoRun<cr>", vim.tbl_extend("force", opts, { desc = "Cargo Run" }))
          vim.keymap.set("n", "<leader>Ct", "<cmd>CargoTest<cr>", vim.tbl_extend("force", opts, { desc = "Cargo Test" }))
          vim.keymap.set("n", "<leader>Cc", "<cmd>CargoCheck<cr>", vim.tbl_extend("force", opts, { desc = "Cargo Check" }))
          vim.keymap.set("n", "<leader>Cl", "<cmd>CargoClippy<cr>", vim.tbl_extend("force", opts, { desc = "Cargo Clippy" }))
          vim.keymap.set("n", "<leader>Cf", "<cmd>CargoFmt<cr>", vim.tbl_extend("force", opts, { desc = "Cargo Fmt" }))
          vim.keymap.set("n", "<leader>Cd", "<cmd>CargoDoc!<cr>", vim.tbl_extend("force", opts, { desc = "Cargo Doc (open)" }))
          vim.keymap.set("n", "<leader>Cu", "<cmd>CargoUpdate<cr>", vim.tbl_extend("force", opts, { desc = "Cargo Update" }))
          vim.keymap.set("n", "<leader>Cn", "<cmd>CargoClean<cr>", vim.tbl_extend("force", opts, { desc = "Cargo Clean" }))

          -- Info
          vim.keymap.set("n", "<leader>ri", "<cmd>RustInfo<cr>", vim.tbl_extend("force", opts, { desc = "Rust Info" }))
        end,
      })

      -- Auto-format Rust files on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.rs" },
        callback = function()
          vim.lsp.buf.format({ async = false, timeout_ms = 3000 })
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
        end,
      })

      -- Force diagnostic refresh after text changes for Rust
      vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        pattern = { "*.rs" },
        callback = function()
          vim.defer_fn(function()
            vim.diagnostic.show()
          end, 500)
        end,
      })
    end,
  },
}
