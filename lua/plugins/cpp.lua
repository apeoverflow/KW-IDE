return {
  -- C/C++ IDE Configuration
  -- Enhanced clangd, debugging, build system integration, and CMake support
  {
    "p00f/clangd_extensions.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    ft = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    config = function()
      require("clangd_extensions").setup({
        inlay_hints = {
          inline = vim.fn.has("nvim-0.10") == 1,
          only_current_line = false,
          only_current_line_autocmd = { "CursorHold" },
          show_parameter_hints = true,
          parameter_hints_prefix = "<- ",
          other_hints_prefix = "=> ",
          max_len_align = false,
          max_len_align_padding = 1,
          right_align = false,
          right_align_padding = 7,
          highlight = "Comment",
          priority = 100,
        },
        ast = {
          role_icons = {
            type = "",
            declaration = "",
            expression = "",
            specifier = "",
            statement = "",
            ["template argument"] = "",
          },
          kind_icons = {
            Compound = "",
            Recovery = "",
            TranslationUnit = "",
            PackExpansion = "",
            TemplateTypeParm = "",
            TemplateTemplateParm = "",
            TemplateParamObject = "",
          },
          highlights = {
            detail = "Comment",
          },
        },
        memory_usage = {
          border = "rounded",
        },
        symbol_info = {
          border = "rounded",
        },
      })
    end,
  },

  -- CMake integration
  {
    "Civitasv/cmake-tools.nvim",
    lazy = true,
    ft = { "c", "cpp", "cmake" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("cmake-tools").setup({
        cmake_command = "cmake",
        ctest_command = "ctest",
        cmake_use_preset = true,
        cmake_regenerate_on_save = true,
        cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
        cmake_build_options = {},
        cmake_build_directory = function()
          return "build/${variant:buildType}"
        end,
        cmake_soft_link_compile_commands = true,
        cmake_compile_commands_from_lsp = false,
        cmake_kits_path = nil,
        cmake_variants_message = {
          short = { show = true },
          long = { show = true, max_length = 40 },
        },
        cmake_dap_configuration = {
          name = "cpp",
          type = "codelldb",
          request = "launch",
          stopOnEntry = false,
          runInTerminal = true,
          console = "integratedTerminal",
        },
        cmake_executor = {
          name = "quickfix",
          opts = {},
          default_opts = {
            quickfix = {
              show = "always",
              position = "belowright",
              size = 10,
              encoding = "utf-8",
              auto_close_when_success = true,
            },
            toggleterm = {
              direction = "float",
              close_on_exit = false,
              auto_scroll = true,
              singleton = true,
            },
            overseer = {
              new_task_opts = {
                strategy = {
                  "toggleterm",
                  direction = "horizontal",
                  autos_scroll = true,
                  quit_on_exit = "success",
                },
              },
              on_new_task = function(task) end,
            },
            terminal = {
              name = "CMake Terminal",
              prefix_name = "[CMakeTools]: ",
              split_direction = "horizontal",
              split_size = 11,
              single_terminal_per_instance = true,
              single_terminal_per_tab = true,
              keep_terminal_static_location = true,
              auto_resize = true,
              start_insert = false,
              focus = false,
              do_not_add_newline = false,
            },
          },
        },
        cmake_runner = {
          name = "terminal",
          opts = {},
          default_opts = {
            quickfix = {
              show = "always",
              position = "belowright",
              size = 10,
              encoding = "utf-8",
              auto_close_when_success = true,
            },
            toggleterm = {
              direction = "float",
              close_on_exit = false,
              auto_scroll = true,
              singleton = true,
            },
            overseer = {
              new_task_opts = {
                strategy = {
                  "toggleterm",
                  direction = "horizontal",
                  autos_scroll = true,
                  quit_on_exit = "success",
                },
              },
              on_new_task = function(task) end,
            },
            terminal = {
              name = "CMake Terminal",
              prefix_name = "[CMakeTools]: ",
              split_direction = "horizontal",
              split_size = 11,
              single_terminal_per_instance = true,
              single_terminal_per_tab = true,
              keep_terminal_static_location = true,
              auto_resize = true,
              start_insert = false,
              focus = false,
              do_not_add_newline = false,
            },
          },
        },
        cmake_notifications = {
          runner = { enabled = true },
          executor = { enabled = true },
          spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
          refresh_rate_ms = 100,
        },
      })
    end,
  },

  -- C/C++ specific functionality and keybindings
  {
    "nvim-lua/plenary.nvim",
    lazy = false,
    config = function()
      -- Helper function to detect build system
      local function detect_build_system()
        local cwd = vim.fn.getcwd()
        if vim.fn.filereadable(cwd .. "/CMakeLists.txt") == 1 then
          return "cmake"
        elseif vim.fn.filereadable(cwd .. "/Makefile") == 1 or vim.fn.filereadable(cwd .. "/makefile") == 1 then
          return "make"
        elseif vim.fn.filereadable(cwd .. "/meson.build") == 1 then
          return "meson"
        elseif vim.fn.filereadable(cwd .. "/BUILD") == 1 or vim.fn.filereadable(cwd .. "/BUILD.bazel") == 1 then
          return "bazel"
        elseif vim.fn.filereadable(cwd .. "/compile_commands.json") == 1 then
          return "compile_commands"
        end
        return nil
      end

      -- Helper function to find compile_commands.json
      local function find_compile_commands()
        local search_dirs = {
          vim.fn.getcwd(),
          vim.fn.getcwd() .. "/build",
          vim.fn.getcwd() .. "/build/debug",
          vim.fn.getcwd() .. "/build/release",
          vim.fn.getcwd() .. "/cmake-build-debug",
          vim.fn.getcwd() .. "/cmake-build-release",
          vim.fn.getcwd() .. "/out/build",
        }
        for _, dir in ipairs(search_dirs) do
          local path = dir .. "/compile_commands.json"
          if vim.fn.filereadable(path) == 1 then
            return path
          end
        end
        return nil
      end

      -- Create user commands for C/C++ development

      -- Build project (auto-detects build system)
      vim.api.nvim_create_user_command("CppBuild", function(opts)
        local build_system = detect_build_system()
        local build_type = opts.args ~= "" and opts.args or "Debug"

        if build_system == "cmake" then
          vim.cmd("CMakeBuild")
        elseif build_system == "make" then
          vim.cmd("split")
          vim.cmd("terminal make -j$(nproc)")
          vim.cmd("resize 12")
        elseif build_system == "meson" then
          vim.cmd("split")
          vim.cmd("terminal meson compile -C builddir")
          vim.cmd("resize 12")
        elseif build_system == "bazel" then
          vim.cmd("split")
          vim.cmd("terminal bazel build //...")
          vim.cmd("resize 12")
        else
          print("No build system detected. Create CMakeLists.txt, Makefile, meson.build, or BUILD file.")
        end
      end, { nargs = "?", desc = "Build C/C++ project" })

      -- Run project
      vim.api.nvim_create_user_command("CppRun", function(opts)
        local build_system = detect_build_system()
        local target = opts.args ~= "" and opts.args or nil

        if build_system == "cmake" then
          vim.cmd("CMakeRun")
        elseif build_system == "make" then
          -- Try to find and run the executable
          local exe = vim.fn.glob(vim.fn.getcwd() .. "/build/*", false, true)
          if #exe > 0 then
            vim.cmd("split")
            vim.cmd("terminal " .. exe[1])
            vim.cmd("resize 15")
          else
            print("No executable found in build directory")
          end
        else
          print("Run not supported for this build system. Use :terminal to run manually.")
        end
      end, { nargs = "?", desc = "Run C/C++ project" })

      -- Clean build
      vim.api.nvim_create_user_command("CppClean", function()
        local build_system = detect_build_system()

        if build_system == "cmake" then
          vim.cmd("CMakeClean")
        elseif build_system == "make" then
          vim.fn.system("make clean")
          print("Make clean completed")
        elseif build_system == "meson" then
          vim.fn.system("meson compile --clean -C builddir")
          print("Meson clean completed")
        elseif build_system == "bazel" then
          vim.fn.system("bazel clean")
          print("Bazel clean completed")
        else
          print("No build system detected")
        end
      end, { desc = "Clean C/C++ build" })

      -- Generate compile_commands.json
      vim.api.nvim_create_user_command("CppGenerateCompileCommands", function()
        local build_system = detect_build_system()

        if build_system == "cmake" then
          vim.cmd("CMakeGenerate")
          print("CMake will generate compile_commands.json")
        elseif build_system == "make" then
          print("For Makefiles, use bear: bear -- make")
          vim.cmd("split")
          vim.cmd("terminal bear -- make")
          vim.cmd("resize 12")
        elseif build_system == "meson" then
          vim.fn.system("meson setup builddir --backend=ninja")
          print("Meson generated compile_commands.json in builddir")
        elseif build_system == "bazel" then
          print("For Bazel, use bazel-compilation-database tool")
        else
          print("No build system detected. Create CMakeLists.txt first.")
        end
      end, { desc = "Generate compile_commands.json" })

      -- Show clangd status and info
      vim.api.nvim_create_user_command("CppInfo", function()
        print("=== C/C++ Development Info ===")

        -- Check clangd
        if vim.fn.executable("clangd") == 1 then
          local version = vim.fn.system("clangd --version"):gsub("\n.*", "")
          print("clangd: " .. version)
        else
          print("clangd: NOT FOUND - Install with: brew install llvm")
        end

        -- Check cmake
        if vim.fn.executable("cmake") == 1 then
          local version = vim.fn.system("cmake --version"):match("cmake version ([^\n]+)")
          print("CMake: " .. (version or "installed"))
        else
          print("CMake: NOT FOUND - Install with: brew install cmake")
        end

        -- Check make
        if vim.fn.executable("make") == 1 then
          print("Make: installed")
        else
          print("Make: NOT FOUND")
        end

        -- Check ninja
        if vim.fn.executable("ninja") == 1 then
          print("Ninja: installed")
        else
          print("Ninja: NOT FOUND - Install with: brew install ninja")
        end

        -- Check debugger
        if vim.fn.executable("lldb") == 1 then
          print("LLDB: installed")
        elseif vim.fn.executable("gdb") == 1 then
          print("GDB: installed")
        else
          print("Debugger: NOT FOUND - Install LLDB or GDB")
        end

        -- Check codelldb
        local codelldb_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb"
        if vim.fn.filereadable(codelldb_path) == 1 then
          print("CodeLLDB (DAP): installed via Mason")
        else
          print("CodeLLDB (DAP): NOT FOUND - Install via :Mason")
        end

        -- Build system detection
        local build_system = detect_build_system()
        print("Build System: " .. (build_system or "none detected"))

        -- compile_commands.json
        local cc_path = find_compile_commands()
        if cc_path then
          print("compile_commands.json: " .. cc_path)
        else
          print("compile_commands.json: NOT FOUND (run :CppGenerateCompileCommands)")
        end

        -- Active LSP
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients > 0 then
          for _, client in ipairs(clients) do
            if client.name == "clangd" then
              print("LSP Status: clangd attached")
            end
          end
        else
          print("LSP Status: No active LSP")
        end
      end, { desc = "Show C/C++ development info" })

      -- Switch between header and source file
      vim.api.nvim_create_user_command("CppSwitchHeaderSource", function()
        local clients = vim.lsp.get_clients({ bufnr = 0, name = "clangd" })
        if #clients > 0 then
          vim.cmd("ClangdSwitchSourceHeader")
        else
          -- Fallback manual switch
          local file = vim.fn.expand("%:t")
          local ext = vim.fn.expand("%:e")
          local name = vim.fn.expand("%:t:r")
          local dir = vim.fn.expand("%:p:h")

          local pairs = {
            c = { "h" },
            cpp = { "hpp", "h", "hxx" },
            cxx = { "hpp", "h", "hxx" },
            cc = { "hpp", "h", "hxx" },
            h = { "c", "cpp", "cxx", "cc" },
            hpp = { "cpp", "cxx", "cc" },
            hxx = { "cpp", "cxx", "cc" },
          }

          local targets = pairs[ext]
          if targets then
            for _, target_ext in ipairs(targets) do
              local target = dir .. "/" .. name .. "." .. target_ext
              if vim.fn.filereadable(target) == 1 then
                vim.cmd("edit " .. target)
                return
              end
              -- Also check include/ and src/ directories
              local alt_target = target:gsub("/src/", "/include/"):gsub("/include/", "/src/")
              if vim.fn.filereadable(alt_target) == 1 then
                vim.cmd("edit " .. alt_target)
                return
              end
            end
          end
          print("No matching header/source file found")
        end
      end, { desc = "Switch between header and source" })

      -- Show AST (requires clangd_extensions)
      vim.api.nvim_create_user_command("CppShowAST", function()
        if pcall(require, "clangd_extensions") then
          require("clangd_extensions.ast").show_ast()
        else
          print("clangd_extensions not available")
        end
      end, { desc = "Show AST for current file" })

      -- Show type hierarchy
      vim.api.nvim_create_user_command("CppTypeHierarchy", function()
        if pcall(require, "clangd_extensions") then
          require("clangd_extensions.type_hierarchy").show_type_hierarchy()
        else
          print("clangd_extensions not available")
        end
      end, { desc = "Show type hierarchy" })

      -- Show symbol info
      vim.api.nvim_create_user_command("CppSymbolInfo", function()
        if pcall(require, "clangd_extensions") then
          require("clangd_extensions.symbol_info").show_symbol_info()
        else
          print("clangd_extensions not available")
        end
      end, { desc = "Show symbol info" })

      -- Show memory usage
      vim.api.nvim_create_user_command("CppMemoryUsage", function()
        if pcall(require, "clangd_extensions") then
          require("clangd_extensions.memory_usage").show_memory_usage()
        else
          print("clangd_extensions not available")
        end
      end, { desc = "Show clangd memory usage" })

      -- Create new C++ class (header + source)
      vim.api.nvim_create_user_command("CppNewClass", function(opts)
        local class_name = opts.args
        if class_name == "" then
          class_name = vim.fn.input("Class name: ")
        end
        if class_name == "" then
          print("Class name required")
          return
        end

        local cwd = vim.fn.getcwd()
        local header_dir = cwd
        local source_dir = cwd

        -- Check for common directory structures
        if vim.fn.isdirectory(cwd .. "/include") == 1 then
          header_dir = cwd .. "/include"
        end
        if vim.fn.isdirectory(cwd .. "/src") == 1 then
          source_dir = cwd .. "/src"
        end

        local header_file = header_dir .. "/" .. class_name .. ".hpp"
        local source_file = source_dir .. "/" .. class_name .. ".cpp"

        -- Header content
        local header_guard = class_name:upper() .. "_HPP"
        local header_content = string.format(
          [[#ifndef %s
#define %s

class %s {
public:
    %s();
    ~%s();

private:
};

#endif // %s
]],
          header_guard,
          header_guard,
          class_name,
          class_name,
          class_name,
          header_guard
        )

        -- Source content
        local include_path = class_name .. ".hpp"
        if header_dir ~= source_dir then
          include_path = header_file:gsub(cwd .. "/", ""):gsub("^include/", "")
        end
        local source_content = string.format(
          [[#include "%s"

%s::%s() {
}

%s::~%s() {
}
]],
          include_path,
          class_name,
          class_name,
          class_name,
          class_name
        )

        -- Write files
        local h = io.open(header_file, "w")
        if h then
          h:write(header_content)
          h:close()
          print("Created: " .. header_file)
        end

        local s = io.open(source_file, "w")
        if s then
          s:write(source_content)
          s:close()
          print("Created: " .. source_file)
        end

        -- Open header file
        vim.cmd("edit " .. header_file)
      end, { nargs = "?", desc = "Create new C++ class (header + source)" })

      -- C/C++ specific keybindings (buffer-local when opening C/C++ files)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp", "objc", "objcpp", "cuda" },
        callback = function(args)
          local opts = { buffer = args.buf, silent = true }

          -- Build & Run
          vim.keymap.set("n", "<leader>cb", "<cmd>CppBuild<cr>", vim.tbl_extend("force", opts, { desc = "C++ Build" }))
          vim.keymap.set("n", "<leader>cr", "<cmd>CppRun<cr>", vim.tbl_extend("force", opts, { desc = "C++ Run" }))
          vim.keymap.set("n", "<leader>cc", "<cmd>CppClean<cr>", vim.tbl_extend("force", opts, { desc = "C++ Clean" }))
          vim.keymap.set(
            "n",
            "<leader>cg",
            "<cmd>CppGenerateCompileCommands<cr>",
            vim.tbl_extend("force", opts, { desc = "Generate compile_commands.json" })
          )

          -- Navigation
          vim.keymap.set(
            "n",
            "<leader>ch",
            "<cmd>CppSwitchHeaderSource<cr>",
            vim.tbl_extend("force", opts, { desc = "Switch Header/Source" })
          )
          vim.keymap.set(
            "n",
            "<A-o>",
            "<cmd>CppSwitchHeaderSource<cr>",
            vim.tbl_extend("force", opts, { desc = "Switch Header/Source" })
          )

          -- Clangd extensions
          vim.keymap.set("n", "<leader>ct", "<cmd>CppTypeHierarchy<cr>", vim.tbl_extend("force", opts, { desc = "Type Hierarchy" }))
          vim.keymap.set("n", "<leader>cs", "<cmd>CppSymbolInfo<cr>", vim.tbl_extend("force", opts, { desc = "Symbol Info" }))
          vim.keymap.set("n", "<leader>ca", "<cmd>CppShowAST<cr>", vim.tbl_extend("force", opts, { desc = "Show AST" }))
          vim.keymap.set("n", "<leader>ci", "<cmd>CppInfo<cr>", vim.tbl_extend("force", opts, { desc = "C++ Dev Info" }))

          -- CMake specific (if CMake project)
          if vim.fn.filereadable(vim.fn.getcwd() .. "/CMakeLists.txt") == 1 then
            vim.keymap.set("n", "<leader>cmc", "<cmd>CMakeGenerate<cr>", vim.tbl_extend("force", opts, { desc = "CMake Configure" }))
            vim.keymap.set("n", "<leader>cmb", "<cmd>CMakeBuild<cr>", vim.tbl_extend("force", opts, { desc = "CMake Build" }))
            vim.keymap.set("n", "<leader>cmr", "<cmd>CMakeRun<cr>", vim.tbl_extend("force", opts, { desc = "CMake Run" }))
            vim.keymap.set("n", "<leader>cmd", "<cmd>CMakeDebug<cr>", vim.tbl_extend("force", opts, { desc = "CMake Debug" }))
            vim.keymap.set("n", "<leader>cms", "<cmd>CMakeSelectBuildType<cr>", vim.tbl_extend("force", opts, { desc = "CMake Select Build Type" }))
            vim.keymap.set("n", "<leader>cmt", "<cmd>CMakeSelectLaunchTarget<cr>", vim.tbl_extend("force", opts, { desc = "CMake Select Target" }))
          end

          -- Compile current file only
          vim.keymap.set("n", "<leader>cf", function()
            local file = vim.fn.expand("%")
            local output = vim.fn.expand("%:r")
            local compiler = vim.bo.filetype == "c" and "clang" or "clang++"
            local cmd = compiler .. " -g -Wall -Wextra -o " .. output .. " " .. file
            vim.cmd("split")
            vim.cmd("terminal " .. cmd)
            vim.cmd("resize 8")
          end, vim.tbl_extend("force", opts, { desc = "Compile Current File" }))

          -- Run compiled file
          vim.keymap.set("n", "<leader>cx", function()
            local output = vim.fn.expand("%:r")
            if vim.fn.executable(output) == 1 then
              vim.cmd("split")
              vim.cmd("terminal ./" .. output)
              vim.cmd("resize 15")
            else
              print("Executable not found. Compile first with <leader>cf")
            end
          end, vim.tbl_extend("force", opts, { desc = "Run Compiled File" }))
        end,
      })

      -- Auto-format C/C++ files on save (if clang-format is available)
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.c", "*.cpp", "*.h", "*.hpp", "*.cc", "*.cxx", "*.hxx" },
        callback = function()
          -- Only format if LSP is attached and supports formatting
          local clients = vim.lsp.get_clients({ bufnr = 0, name = "clangd" })
          if #clients > 0 then
            vim.lsp.buf.format({ async = false, timeout_ms = 3000 })
          end
        end,
        desc = "Auto-format C/C++ files on save",
      })

      -- Set up proper indentation for C/C++
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp", "objc", "objcpp" },
        callback = function()
          vim.bo.tabstop = 4
          vim.bo.shiftwidth = 4
          vim.bo.softtabstop = 4
          vim.bo.expandtab = true
          vim.bo.cinoptions = "g0,N-s,E-s,t0,(0,W4"
        end,
      })
    end,
  },
}
