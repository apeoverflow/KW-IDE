return {
  -- Go IDE Configuration
  -- gopls LSP, debugging with delve, testing, and Go tools integration
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("go").setup({
        -- Disable default keymaps, we'll set our own
        disable_defaults = false,
        -- Go command
        go = "go",
        -- goimports command
        goimports = "gopls",
        -- fillstruct command
        fillstruct = "gopls",
        -- gofmt command
        gofmt = "gofumpt",
        -- Tag transform - snakecase, camelcase, etc
        tag_transform = false,
        -- Tag options
        tag_options = "json=omitempty",
        -- gotests template directory
        gotests_template = "",
        -- gotests template directory for parallel tests
        gotests_template_dir = "",
        -- Comment placeholder
        comment_placeholder = "",
        -- Icons for virtual text
        icons = { breakpoint = "🔴", currentpos = "👉" },
        -- Verbose mode
        verbose = false,
        -- Log path
        log_path = vim.fn.expand("$HOME") .. "/tmp/gonvim.log",
        -- LSP config
        lsp_cfg = {
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
          settings = {
            gopls = {
              analyses = {
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
                shadow = true,
              },
              experimentalPostfixCompletions = true,
              gofumpt = true,
              staticcheck = true,
              usePlaceholders = true,
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              codelenses = {
                gc_details = true,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              semanticTokens = true,
            },
          },
        },
        -- LSP on attach
        lsp_on_attach = function(client, bufnr)
          local opts = { buffer = bufnr, silent = true }

          -- Enable inlay hints
          if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end

          -- Go-specific keybindings
          vim.keymap.set("n", "<leader>gi", "<cmd>GoImports<cr>", vim.tbl_extend("force", opts, { desc = "Go Imports" }))
          vim.keymap.set("n", "<leader>gf", "<cmd>GoFmt<cr>", vim.tbl_extend("force", opts, { desc = "Go Format" }))
          vim.keymap.set("n", "<leader>gt", "<cmd>GoTest<cr>", vim.tbl_extend("force", opts, { desc = "Go Test" }))
          vim.keymap.set("n", "<leader>gT", "<cmd>GoTestFunc<cr>", vim.tbl_extend("force", opts, { desc = "Go Test Function" }))
          vim.keymap.set("n", "<leader>gtt", "<cmd>GoTestFile<cr>", vim.tbl_extend("force", opts, { desc = "Go Test File" }))
          vim.keymap.set("n", "<leader>gtc", "<cmd>GoCoverage<cr>", vim.tbl_extend("force", opts, { desc = "Go Coverage" }))
          vim.keymap.set("n", "<leader>gr", "<cmd>GoRun<cr>", vim.tbl_extend("force", opts, { desc = "Go Run" }))
          vim.keymap.set("n", "<leader>gb", "<cmd>GoBuild<cr>", vim.tbl_extend("force", opts, { desc = "Go Build" }))
          vim.keymap.set("n", "<leader>gB", "<cmd>GoGenerate<cr>", vim.tbl_extend("force", opts, { desc = "Go Generate" }))
          vim.keymap.set("n", "<leader>gl", "<cmd>GoLint<cr>", vim.tbl_extend("force", opts, { desc = "Go Lint" }))
          vim.keymap.set("n", "<leader>gv", "<cmd>GoVet<cr>", vim.tbl_extend("force", opts, { desc = "Go Vet" }))
          vim.keymap.set("n", "<leader>ge", "<cmd>GoIfErr<cr>", vim.tbl_extend("force", opts, { desc = "Go If Err" }))
          vim.keymap.set("n", "<leader>gfs", "<cmd>GoFillStruct<cr>", vim.tbl_extend("force", opts, { desc = "Go Fill Struct" }))
          vim.keymap.set("n", "<leader>gfw", "<cmd>GoFillSwitch<cr>", vim.tbl_extend("force", opts, { desc = "Go Fill Switch" }))
          vim.keymap.set("n", "<leader>ga", "<cmd>GoAddTag<cr>", vim.tbl_extend("force", opts, { desc = "Go Add Tag" }))
          vim.keymap.set("n", "<leader>gA", "<cmd>GoRmTag<cr>", vim.tbl_extend("force", opts, { desc = "Go Remove Tag" }))
          vim.keymap.set("n", "<leader>gc", "<cmd>GoCmt<cr>", vim.tbl_extend("force", opts, { desc = "Go Comment" }))
          vim.keymap.set("n", "<leader>gd", "<cmd>GoDoc<cr>", vim.tbl_extend("force", opts, { desc = "Go Doc" }))
          vim.keymap.set("n", "<leader>gD", "<cmd>GoDbg<cr>", vim.tbl_extend("force", opts, { desc = "Go Debug" }))
          vim.keymap.set("n", "<leader>gI", "<cmd>GoImpl<cr>", vim.tbl_extend("force", opts, { desc = "Go Impl Interface" }))
          vim.keymap.set("n", "<leader>gm", "<cmd>GoModTidy<cr>", vim.tbl_extend("force", opts, { desc = "Go Mod Tidy" }))
          vim.keymap.set("n", "<leader>gM", "<cmd>GoModInit<cr>", vim.tbl_extend("force", opts, { desc = "Go Mod Init" }))
          vim.keymap.set("n", "<leader>gp", "<cmd>GoTestPkg<cr>", vim.tbl_extend("force", opts, { desc = "Go Test Package" }))
          vim.keymap.set("n", "<leader>gat", "<cmd>GoAddTest<cr>", vim.tbl_extend("force", opts, { desc = "Go Add Test" }))
          vim.keymap.set("n", "<leader>gae", "<cmd>GoAddExpTest<cr>", vim.tbl_extend("force", opts, { desc = "Go Add Example Test" }))
          vim.keymap.set("n", "<leader>gaa", "<cmd>GoAddAllTest<cr>", vim.tbl_extend("force", opts, { desc = "Go Add All Tests" }))
          vim.keymap.set("n", "<leader>gx", "<cmd>GoAlt<cr>", vim.tbl_extend("force", opts, { desc = "Go Alt File" }))
          vim.keymap.set("n", "<leader>gX", "<cmd>GoAltV<cr>", vim.tbl_extend("force", opts, { desc = "Go Alt File (vsplit)" }))

          -- Debugging keymaps
          vim.keymap.set("n", "<leader>gds", "<cmd>GoDebug<cr>", vim.tbl_extend("force", opts, { desc = "Go Debug Start" }))
          vim.keymap.set("n", "<leader>gdt", "<cmd>GoDebug -t<cr>", vim.tbl_extend("force", opts, { desc = "Go Debug Test" }))
          vim.keymap.set("n", "<leader>gdb", "<cmd>GoBreakToggle<cr>", vim.tbl_extend("force", opts, { desc = "Go Toggle Breakpoint" }))
          vim.keymap.set("n", "<leader>gdc", "<cmd>GoBreakCondition<cr>", vim.tbl_extend("force", opts, { desc = "Go Conditional Breakpoint" }))
          vim.keymap.set("n", "<leader>gdq", "<cmd>GoDebug -s<cr>", vim.tbl_extend("force", opts, { desc = "Go Debug Stop" }))
        end,
        -- LSP gofumpt on save
        lsp_gofumpt = true,
        -- LSP codelens
        lsp_codelens = true,
        -- Diagnostic configuration
        diagnostic = {
          hdlr = true,
          underline = true,
          virtual_text = { spacing = 0, prefix = "●" },
          signs = true,
          update_in_insert = false,
        },
        -- Inlay hints
        lsp_inlay_hints = {
          enable = true,
          only_current_line = false,
          only_current_line_autocmd = "CursorHold",
          show_variable_name = true,
          show_parameter_hints = true,
          parameter_hints_prefix = "<- ",
          other_hints_prefix = "=> ",
          max_len_align = false,
          max_len_align_padding = 1,
          right_align = false,
          right_align_padding = 6,
          highlight = "Comment",
        },
        -- gopls command
        gopls_cmd = nil,
        -- gopls remote auto
        gopls_remote_auto = true,
        -- gocoverage sign
        gocoverage_sign = "█",
        -- Sign priority
        sign_priority = 5,
        -- Dap debug
        dap_debug = true,
        -- Dap debug gui
        dap_debug_gui = true,
        -- Dap debug keymap
        dap_debug_keymap = true,
        -- Dap debug vt
        dap_debug_vt = true,
        -- Dap port wait
        dap_port_wait = 5000,
        -- Dap timeout
        dap_timeout = 15,
        -- Dap retries
        dap_retries = 20,
        -- Build tags
        build_tags = "",
        -- Textobjects
        textobjects = true,
        -- Test runner
        test_runner = "go",
        -- Verbose tests
        verbose_tests = true,
        -- Run in floaterm
        run_in_floaterm = false,
        -- Floaterm options
        floaterm = {
          posititon = "auto",
          width = 0.45,
          height = 0.98,
          title_colors = "dracula",
        },
        -- Trouble integration
        trouble = false,
        -- Test env vars
        test_efm = false,
        -- luasnip
        luasnip = false,
      })

      -- Run gofmt/goimports on save
      local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          require("go.format").goimports()
        end,
        group = format_sync_grp,
      })
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod", "gowork", "gotmpl" },
    build = ':lua require("go.install").update_all_sync()',
  },

  -- Additional Go tools and commands
  {
    "nvim-lua/plenary.nvim",
    lazy = false,
    config = function()
      -- Helper function to check if in a Go project
      local function is_go_project()
        return vim.fn.filereadable(vim.fn.getcwd() .. "/go.mod") == 1
      end

      -- Create user commands for Go development

      -- Go build
      vim.api.nvim_create_user_command("GoBuild", function(opts)
        local args = opts.args ~= "" and " " .. opts.args or ""
        vim.cmd("split")
        vim.cmd("terminal go build" .. args .. " ./...")
        vim.cmd("resize 12")
      end, { nargs = "*", desc = "Run go build" })

      -- Go run
      vim.api.nvim_create_user_command("GoRun", function(opts)
        local args = opts.args ~= "" and " " .. opts.args or " ."
        vim.cmd("split")
        vim.cmd("terminal go run" .. args)
        vim.cmd("resize 15")
      end, { nargs = "*", desc = "Run go run" })

      -- Go test
      vim.api.nvim_create_user_command("GoTest", function(opts)
        local args = opts.args ~= "" and " " .. opts.args or " ./..."
        vim.cmd("split")
        vim.cmd("terminal go test -v" .. args)
        vim.cmd("resize 15")
      end, { nargs = "*", desc = "Run go test" })

      -- Go test current function
      vim.api.nvim_create_user_command("GoTestFunc", function()
        -- Get current function name
        local func_name = vim.fn.search("func \\(Test\\|Benchmark\\)", "bcnW")
        if func_name > 0 then
          local line = vim.fn.getline(func_name)
          local name = line:match("func (Test%w+)")
          if name then
            vim.cmd("split")
            vim.cmd("terminal go test -v -run " .. name .. " ./...")
            vim.cmd("resize 15")
          else
            print("No test function found")
          end
        else
          print("No test function found")
        end
      end, { desc = "Run current test function" })

      -- Go test with coverage
      vim.api.nvim_create_user_command("GoCoverage", function()
        vim.cmd("split")
        vim.cmd("terminal go test -coverprofile=coverage.out ./... && go tool cover -html=coverage.out")
        vim.cmd("resize 12")
      end, { desc = "Run go test with coverage" })

      -- Go mod tidy
      vim.api.nvim_create_user_command("GoModTidy", function()
        vim.fn.system("go mod tidy")
        print("Go mod tidy completed")
      end, { desc = "Run go mod tidy" })

      -- Go mod init
      vim.api.nvim_create_user_command("GoModInit", function(opts)
        if opts.args == "" then
          print("Usage: :GoModInit <module_name>")
          return
        end
        vim.fn.system("go mod init " .. opts.args)
        print("Go module initialized: " .. opts.args)
      end, { nargs = "?", desc = "Run go mod init" })

      -- Go get
      vim.api.nvim_create_user_command("GoGet", function(opts)
        if opts.args == "" then
          print("Usage: :GoGet <package>")
          return
        end
        vim.cmd("split")
        vim.cmd("terminal go get " .. opts.args)
        vim.cmd("resize 10")
      end, { nargs = "+", desc = "Run go get" })

      -- Go install
      vim.api.nvim_create_user_command("GoInstall", function(opts)
        local args = opts.args ~= "" and " " .. opts.args or " ./..."
        vim.cmd("split")
        vim.cmd("terminal go install" .. args)
        vim.cmd("resize 10")
      end, { nargs = "*", desc = "Run go install" })

      -- Go clean
      vim.api.nvim_create_user_command("GoClean", function()
        vim.fn.system("go clean")
        print("Go clean completed")
      end, { desc = "Run go clean" })

      -- Go vet
      vim.api.nvim_create_user_command("GoVet", function()
        vim.cmd("split")
        vim.cmd("terminal go vet ./...")
        vim.cmd("resize 12")
      end, { desc = "Run go vet" })

      -- Go fmt
      vim.api.nvim_create_user_command("GoFmt", function()
        vim.cmd("!go fmt ./...")
        vim.cmd("edit")
        print("Go fmt completed")
      end, { desc = "Run go fmt" })

      -- Go imports (goimports)
      vim.api.nvim_create_user_command("GoImports", function()
        if vim.fn.executable("goimports") == 1 then
          vim.cmd("!goimports -w " .. vim.fn.expand("%"))
          vim.cmd("edit")
          print("Goimports completed")
        else
          print("goimports not found. Install with: go install golang.org/x/tools/cmd/goimports@latest")
        end
      end, { desc = "Run goimports" })

      -- Go lint (golangci-lint)
      vim.api.nvim_create_user_command("GoLint", function()
        if vim.fn.executable("golangci-lint") == 1 then
          vim.cmd("split")
          vim.cmd("terminal golangci-lint run ./...")
          vim.cmd("resize 15")
        else
          print("golangci-lint not found. Install from: https://golangci-lint.run/usage/install/")
        end
      end, { desc = "Run golangci-lint" })

      -- Go doc
      vim.api.nvim_create_user_command("GoDoc", function(opts)
        local word = opts.args ~= "" and opts.args or vim.fn.expand("<cword>")
        vim.cmd("split")
        vim.cmd("terminal go doc " .. word)
        vim.cmd("resize 15")
      end, { nargs = "?", desc = "Show go doc" })

      -- Go generate
      vim.api.nvim_create_user_command("GoGenerate", function()
        vim.cmd("split")
        vim.cmd("terminal go generate ./...")
        vim.cmd("resize 12")
      end, { desc = "Run go generate" })

      -- Show Go info
      vim.api.nvim_create_user_command("GoInfo", function()
        print("=== Go Development Info ===")

        -- Check go
        if vim.fn.executable("go") == 1 then
          local version = vim.fn.system("go version"):gsub("\n", "")
          print("go: " .. version)
        else
          print("go: NOT FOUND - Install Go from https://golang.org")
        end

        -- Check gopls
        if vim.fn.executable("gopls") == 1 then
          local version = vim.fn.system("gopls version 2>/dev/null"):gsub("\n.*", "")
          print("gopls: " .. (version ~= "" and version or "installed"))
        else
          print("gopls: NOT FOUND - Install with: go install golang.org/x/tools/gopls@latest")
        end

        -- Check goimports
        if vim.fn.executable("goimports") == 1 then
          print("goimports: installed")
        else
          print("goimports: NOT FOUND - Install with: go install golang.org/x/tools/cmd/goimports@latest")
        end

        -- Check gofumpt
        if vim.fn.executable("gofumpt") == 1 then
          print("gofumpt: installed")
        else
          print("gofumpt: NOT FOUND - Install with: go install mvdan.cc/gofumpt@latest")
        end

        -- Check golangci-lint
        if vim.fn.executable("golangci-lint") == 1 then
          local version = vim.fn.system("golangci-lint --version 2>/dev/null"):match("version ([%d%.]+)")
          print("golangci-lint: " .. (version or "installed"))
        else
          print("golangci-lint: NOT FOUND - Install from: https://golangci-lint.run/usage/install/")
        end

        -- Check delve
        if vim.fn.executable("dlv") == 1 then
          local version = vim.fn.system("dlv version 2>/dev/null"):match("Version: ([%d%.]+)")
          print("delve (dlv): " .. (version or "installed"))
        else
          print("delve (dlv): NOT FOUND - Install with: go install github.com/go-delve/delve/cmd/dlv@latest")
        end

        -- Check gotests
        if vim.fn.executable("gotests") == 1 then
          print("gotests: installed")
        else
          print("gotests: NOT FOUND - Install with: go install github.com/cweill/gotests/gotests@latest")
        end

        -- Check gomodifytags
        if vim.fn.executable("gomodifytags") == 1 then
          print("gomodifytags: installed")
        else
          print("gomodifytags: NOT FOUND - Install with: go install github.com/fatih/gomodifytags@latest")
        end

        -- Check impl
        if vim.fn.executable("impl") == 1 then
          print("impl: installed")
        else
          print("impl: NOT FOUND - Install with: go install github.com/josharian/impl@latest")
        end

        -- Check if in Go project
        if is_go_project() then
          print("Project: go.mod found")
          local mod_name = vim.fn.system("grep '^module' go.mod | head -1"):gsub("\n", "")
          if mod_name ~= "" then
            print("  " .. mod_name)
          end
        else
          print("Project: No go.mod found")
        end

        -- Active LSP
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        for _, client in ipairs(clients) do
          if client.name == "gopls" then
            print("LSP Status: gopls attached")
          end
        end
      end, { desc = "Show Go development info" })

      -- Go fill struct
      vim.api.nvim_create_user_command("GoFillStruct", function()
        vim.lsp.buf.code_action({
          filter = function(action)
            return action.title:match("Fill")
          end,
          apply = true,
        })
      end, { desc = "Fill struct fields" })

      -- Go if err
      vim.api.nvim_create_user_command("GoIfErr", function()
        local pos = vim.api.nvim_win_get_cursor(0)
        local line = pos[1]
        local snippet = [[
if err != nil {
	return err
}]]
        vim.api.nvim_buf_set_lines(0, line, line, false, vim.split(snippet, "\n"))
      end, { desc = "Insert if err != nil block" })

      -- Go alt file (switch between test and implementation)
      vim.api.nvim_create_user_command("GoAlt", function()
        local file = vim.fn.expand("%:t")
        local dir = vim.fn.expand("%:p:h")

        if file:match("_test%.go$") then
          -- Switch to implementation
          local impl_file = file:gsub("_test%.go$", ".go")
          local impl_path = dir .. "/" .. impl_file
          if vim.fn.filereadable(impl_path) == 1 then
            vim.cmd("edit " .. impl_path)
          else
            print("Implementation file not found: " .. impl_file)
          end
        else
          -- Switch to test
          local test_file = file:gsub("%.go$", "_test.go")
          local test_path = dir .. "/" .. test_file
          if vim.fn.filereadable(test_path) == 1 then
            vim.cmd("edit " .. test_path)
          else
            -- Create test file
            local create = vim.fn.input("Test file not found. Create " .. test_file .. "? (y/n): ")
            if create:lower() == "y" then
              vim.cmd("edit " .. test_path)
              local pkg_line = vim.fn.system("grep '^package' " .. dir .. "/" .. file):gsub("\n", "")
              if pkg_line ~= "" then
                vim.api.nvim_buf_set_lines(0, 0, 0, false, { pkg_line, "", "import \"testing\"", "" })
              end
            end
          end
        end
      end, { desc = "Switch between test and implementation file" })

      -- Additional Go-specific keybindings
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "go" },
        callback = function(args)
          local opts = { buffer = args.buf, silent = true }

          -- Quick commands
          vim.keymap.set("n", "<leader>Gb", "<cmd>GoBuild<cr>", vim.tbl_extend("force", opts, { desc = "Go Build" }))
          vim.keymap.set("n", "<leader>Gr", "<cmd>GoRun<cr>", vim.tbl_extend("force", opts, { desc = "Go Run" }))
          vim.keymap.set("n", "<leader>Gt", "<cmd>GoTest<cr>", vim.tbl_extend("force", opts, { desc = "Go Test" }))
          vim.keymap.set("n", "<leader>Gv", "<cmd>GoVet<cr>", vim.tbl_extend("force", opts, { desc = "Go Vet" }))
          vim.keymap.set("n", "<leader>Gl", "<cmd>GoLint<cr>", vim.tbl_extend("force", opts, { desc = "Go Lint" }))
          vim.keymap.set("n", "<leader>Gf", "<cmd>GoFmt<cr>", vim.tbl_extend("force", opts, { desc = "Go Fmt" }))
          vim.keymap.set("n", "<leader>Gi", "<cmd>GoInfo<cr>", vim.tbl_extend("force", opts, { desc = "Go Info" }))
          vim.keymap.set("n", "<leader>Gm", "<cmd>GoModTidy<cr>", vim.tbl_extend("force", opts, { desc = "Go Mod Tidy" }))
        end,
      })

      -- Set up proper indentation for Go
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "go" },
        callback = function()
          vim.bo.tabstop = 4
          vim.bo.shiftwidth = 4
          vim.bo.softtabstop = 4
          vim.bo.expandtab = false -- Go uses tabs
        end,
      })

      -- Force diagnostic refresh after text changes for Go
      vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        pattern = { "*.go" },
        callback = function()
          vim.defer_fn(function()
            vim.diagnostic.show()
          end, 500)
        end,
      })
    end,
  },
}
