return {
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "leoluz/nvim-dap-go",
      "mxsdev/nvim-dap-vscode-js",
      {
        "microsoft/vscode-js-debug",
        version = "1.*",
        build = "npm i && npm run compile vsDebugServerBundle && mv dist out",
        lazy = true,
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        lazy = true,
        opts = {
          enabled = true,
          enabled_commands = true,
          highlight_changed_variables = true,
          highlight_new_as_changed = false,
          show_stop_reason = true,
          commented = false,
          only_first_definition = true,
          all_references = false,
          clear_on_continue = false,
        },
      },
      {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        lazy = true,
        config = function()
          local python_path = vim.fn.trim(vim.fn.system("which python"))
          if vim.fn.executable(python_path) == 0 then
            vim.notify("Python with debugpy not found: " .. python_path, vim.log.levels.ERROR)
            return
          end
          require("dap-python").setup(python_path)
        end,
      },
    },
    keys = {
      { "<leader>dc", "<cmd>DapContinue<CR>", desc = "Start or continue debugging" },
      { "<leader>dC", "<cmd>DapClearBreakpoints<CR>", desc = "Clear all Breakpoints" },
      { "<leader>do", "<cmd>DapStepOver<CR>", desc = "Step over" },
      { "<leader>di", "<cmd>DapStepInto<CR>", desc = "Step into" },
      { "<leader>dO", "<cmd>DapStepOut<CR>", desc = "Step out" },
      { "<leader>db", "<cmd>DapToggleBreakpoint<CR>", desc = "Toggle breakpoint" },
      {
        "<leader>dx",
        function()
          require("dap").terminate()
          require("dapui").close()
          require("nvim-dap-virtual-text").refresh()
        end,
        desc = "Terminate debugging session",
      },
      { "<leader>dr", "<cmd>DapReplToggle<CR>", desc = "Toggle REPL" },
      { "<leader>de", "<cmd>lua require('dapui').eval()<CR>", desc = "Evaluate Expression" },
    },
    cmd = {
      "DapContinue",
      "DapToggleBreakpoint",
      "DapStepOver",
      "DapStepInto",
      "DapStepOut",
      "DapClearBreakpoints",
      "DapTerminate",
      "DapReplToggle",
    },
    config = function()
      local dap = require("dap")

      -- Cache expensive operations
      local cwd = vim.fn.getcwd()
      local data_path = vim.fn.stdpath("data")

      -- Setup signs efficiently
      local icons = {

        Stopped = { "", "DiagnosticWarn", "DapStoppedLine" },
        Breakpoint = { "", "DiagnosticInfo" },
        BreakpointRejected = { "", "DiagnosticError" },
        BreakpointCondition = { "", "DiagnosticInfo" },
        LogPoint = { ".>", "DiagnosticInfo" },
      }

      for name, sign in pairs(icons) do
        vim.fn.sign_define("Dap" .. name, {
          text = sign[1],
          texthl = sign[2],
          linehl = sign[3],
          numhl = sign[3],
        })
      end

      -- Get C++ debug adapter path from Nix
      local function get_cpp_debug_adapter_path()
        local ok, cpp_debug_path = pcall(
          vim.fn.trim,
          vim.fn.system(
            "NIXPKGS_ALLOW_UNFREE=1 nix eval --impure --raw nixpkgs#vscode-extensions.ms-vscode.cpptools.outPath 2>/dev/null"
          )
        )

        if ok and cpp_debug_path ~= "" then
          local full_path = cpp_debug_path
            .. "/share/vscode/extensions/ms-vscode.cpptools/debugAdapters/bin/OpenDebugAD7"
          -- Verify the binary exists
          if vim.fn.executable(full_path) == 1 then
            return full_path
          end
        end

        return nil
      end

      -- Lazy setup for language-specific configurations
      local function setup_js_debug()
        require("dap-vscode-js").setup({
          debugger_path = data_path .. "/lazy/vscode-js-debug",
          adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost", "firefox" },
        })
      end

      local function setup_firefox_adapter()
        local ok, firefox_path = pcall(
          vim.fn.trim,
          vim.fn.system(
            "nix eval --raw nixpkgs#vscode-extensions.firefox-devtools.vscode-firefox-debug.outPath 2>/dev/null"
          )
        )

        if ok and firefox_path ~= "" then
          dap.adapters.firefox = {
            type = "executable",
            command = "node",
            args = {
              firefox_path .. "/share/vscode/extensions/firefox-devtools.vscode-firefox-debug/dist/adapter.bundle.js",
            },
          }
        end
      end

      local function prompt_url(default)
        return coroutine.wrap(function()
          local co = coroutine.running()
          vim.ui.input({ prompt = "Enter URL: ", default = default }, function(url)
            coroutine.resume(co, url or default)
          end)
          return coroutine.yield()
        end)
      end

      -- Language-specific configuration functions
      local function get_js_configs()
        local configs = {
          {
            type = "pwa-chrome",
            request = "launch",
            name = "Launch & Debug Chrome ",
            url = function()
              return prompt_url("http://localhost:3000")
            end,
            webRoot = cwd,
            protocol = "inspector",
            sourceMaps = true,
            userDataDir = false,
          },
        }

        -- Only add Firefox config if adapter is available
        if dap.adapters.firefox then
          table.insert(configs, 1, {
            type = "firefox",
            name = "Launch Firefox to debug 󰈹",
            request = "launch",
            reAttach = true,
            url = function()
              return prompt_url("http://localhost:3000")
            end,
            webRoot = cwd,
            firefoxExecutable = vim.fn.trim(vim.fn.system("readlink -e $(which firefox) 2>/dev/null || echo ''")),
          })
        end

        return configs
      end

      local function get_go_configs()
        return {
          {
            type = "go",
            name = "Debug current file",
            request = "launch",
            program = "${file}",
          },
          {
            type = "go",
            name = "Debug current file (with args)",
            request = "launch",
            program = "${file}",
            args = require("dap-go").get_arguments,
          },
        }
      end

      local function get_gdb_configs()
        return {
          {
            name = "Launch (GDB)",
            type = "gdb",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", cwd .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            stopAtBeginningOfMainSubprogram = false,
          },
          {
            name = "Select and attach to process (GDB)",
            type = "gdb",
            request = "attach",
            program = function()
              return vim.fn.input("Path to executable: ", cwd .. "/", "file")
            end,
            pid = function()
              local filter = vim.fn.input("Executable name (filter): ")
              return require("dap.utils").pick_process({ filter = filter })
            end,
            cwd = "${workspaceFolder}",
          },
          {
            name = "Attach to gdbserver :1234 (GDB)",
            type = "gdb",
            request = "attach",
            target = "localhost:1234",
            program = function()
              return vim.fn.input("Path to executable: ", cwd .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
          },
        }
      end

      local function get_cpp_configs()
        local configs = {}

        -- Add cppdbg configurations if available
        local cpp_debug_path = get_cpp_debug_adapter_path()
        if cpp_debug_path then
          -- Setup cppdbg adapter
          dap.adapters.cppdbg = {
            id = "cppdbg",
            type = "executable",
            command = cpp_debug_path,
          }

          local cpp_configs = {
            {
              name = "Launch (cppdbg)",
              type = "cppdbg",
              request = "launch",
              program = function()
                return vim.fn.input("Path to executable: ", cwd .. "/", "file")
              end,
              cwd = "${workspaceFolder}",
              stopAtEntry = false,
              setupCommands = {
                {
                  text = "-enable-pretty-printing",
                  description = "enable pretty printing",
                  ignoreFailures = false,
                },
                {
                  text = "-gdb-set print object on",
                  description = "enable object printing",
                  ignoreFailures = true,
                },
                {
                  text = "-gdb-set print static-members on",
                  description = "enable static member printing",
                  ignoreFailures = true,
                },
                {
                  text = "-gdb-set print vtbl on",
                  description = "enable vtable printing",
                  ignoreFailures = true,
                },
                {
                  text = "-gdb-set print demangle on",
                  description = "enable symbol demangling",
                  ignoreFailures = true,
                },
                {
                  text = "-gdb-set print sevenbit-strings off",
                  description = "enable non-ASCII character printing",
                  ignoreFailures = true,
                },
                {
                  text = "-gdb-set charset UTF-8",
                  description = "set charset to UTF-8",
                  ignoreFailures = true,
                },
                {
                  text = "-gdb-set auto-solib-add on",
                  description = "automatically load shared library symbols",
                  ignoreFailures = true,
                },
              },
            },
            {
              name = "Attach to process (cppdbg)",
              type = "cppdbg",
              request = "attach",
              program = function()
                return vim.fn.input("Path to executable: ", cwd .. "/", "file")
              end,
              processId = function()
                return require("dap.utils").pick_process()
              end,
              cwd = "${workspaceFolder}",
            },
          }

          configs = vim.list_extend(configs, cpp_configs)
        end

        -- Add GDB configurations as fallback
        local gdb_configs = get_gdb_configs()
        configs = vim.list_extend(configs, gdb_configs)

        return configs
      end

      -- Lazy configuration setup based on filetype
      local function setup_language_configs()
        local ft = vim.bo.filetype

        if vim.tbl_contains({ "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }, ft) then
          if not dap.configurations[ft] then
            setup_js_debug()
            setup_firefox_adapter()
            local js_configs = get_js_configs()
            for _, lang in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }) do
              dap.configurations[lang] = js_configs
            end
          end
        elseif ft == "go" then
          if not dap.configurations.go then
            dap.configurations.go = get_go_configs()
          end
        elseif vim.tbl_contains({ "c", "cpp", "rust" }, ft) then
          if not dap.configurations.cpp then
            -- Setup GDB adapter
            if not dap.adapters.gdb then
              dap.adapters.gdb = {
                type = "executable",
                command = vim.fn.trim(vim.fn.system("readlink -e $(which gdb) 2>/dev/null || echo 'gdb'")),
                args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
              }
            end

            local cpp_configs = get_cpp_configs()
            dap.configurations.cpp = cpp_configs
            dap.configurations.c = dap.configurations.cpp
            dap.configurations.rust = dap.configurations.cpp
          end
        end
      end

      -- Setup language configs on first debug command
      local original_continue = dap.continue
      dap.continue = function()
        setup_language_configs()
        dap.continue = original_continue -- Restore original function
        return dap.continue()
      end

      -- Setup UI and Go plugin
      require("dapui").setup()
      require("dap-go").setup()

      -- UI event handlers
      local dapui = require("dapui")
      dap.listeners.after.event_initialized["dapui_config"] = dapui.open
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
        require("nvim-dap-virtual-text").refresh()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
        require("nvim-dap-virtual-text").refresh()
      end
    end,
  },
}
