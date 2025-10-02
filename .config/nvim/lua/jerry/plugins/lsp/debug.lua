return {
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "leoluz/nvim-dap-go",
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

      local cwd = vim.fn.getcwd()

      -- Signs
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

      -- Codelldb (Nix)
      local function get_codelldb_adapter()
        local ok, lldb_path = pcall(
          vim.fn.trim,
          vim.fn.system("nix eval --raw nixpkgs#vscode-extensions.vadimcn.vscode-lldb.outPath 2>/dev/null")
        )
        if ok and lldb_path ~= "" then
          local adapter = lldb_path .. "/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb"
          if vim.fn.executable(adapter) == 1 then
            return {
              type = "server",
              port = "${port}",
              executable = {
                command = adapter,
                args = { "--port", "${port}" },
              },
            }
          end
        end
        return nil
      end

      -- Python adapter (Nix)
      local function setup_python_adapter()
        -- Find Python with debugpy
        local python_cmd = vim.fn.exepath("python3") or vim.fn.exepath("python") or "python3"

        -- Check if debugpy is available
        local has_debugpy = vim.fn.system(python_cmd .. " -c 'import debugpy' 2>/dev/null")
        if vim.v.shell_error == 0 then
          dap.adapters.python = {
            type = "executable",
            command = python_cmd,
            args = { "-m", "debugpy.adapter" },
          }
        else
          vim.notify("debugpy module not found. Install with: pip install debugpy", vim.log.levels.ERROR)
        end
      end

      -- Firefox adapter (Nix)
      local function setup_firefox_adapter()
        local ok, firefox_path = pcall(
          vim.fn.trim,
          vim.fn.system(
            "nix eval --raw nixpkgs#vscode-extensions.firefox-devtools.vscode-firefox-debug.outPath 2>/dev/null"
          )
        )

        if ok and firefox_path ~= "" then
          local adapter_js = firefox_path
            .. "/share/vscode/extensions/firefox-devtools.vscode-firefox-debug/dist/adapter.bundle.js"

          if vim.fn.filereadable(adapter_js) == 1 then
            require("dap").adapters.firefox = {
              type = "executable",
              command = "node",
              args = { adapter_js },
            }
          else
            vim.notify("Firefox adapter not found at: " .. adapter_js, vim.log.levels.ERROR)
          end
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

      -- JS/TS debug adapters (Node + Chrome + Firefox)
      local function setup_js_adapters()
        local ok, js_debug_path =
          pcall(vim.fn.trim, vim.fn.system("nix eval --raw nixpkgs#vscode-js-debug 2>/dev/null"))
        if not ok or js_debug_path == "" then
          vim.notify("vscode-js-debug not found via nix", vim.log.levels.ERROR)
          return
        end

        -- Node
        dap.adapters["pwa-node"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "node",
            args = {
              js_debug_path .. "/lib/node_modules/js-debug/dist/src/dapDebugServer.js",
              "${port}",
            },
          },
        }

        -- Chrome
        dap.adapters["pwa-chrome"] = dap.adapters["pwa-node"]

        setup_firefox_adapter()

        local js_configs = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Debug current JS/TS file (Node)",
            program = "${file}",
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
          },
          {
            type = "pwa-chrome",
            request = "launch",
            name = "Launch Chrome to debug ",
            url = function()
              return prompt_url("http://localhost:3000")
            end,
            webRoot = cwd,
            protocol = "inspector",
            sourceMaps = true,
            userDataDir = false,
          },
        }

        if dap.adapters.firefox then
          table.insert(js_configs, {
            type = "firefox",
            name = "Launch Firefox to debug 󰈹",
            request = "launch",
            reAttach = true,
            url = function()
              return vim.fn.input("Enter URL: ", "http://localhost:3000")
            end,
            webRoot = cwd,
            -- webRoot = "${workspaceFolder}/express", -- <== adjust this
            firefoxExecutable = vim.fn.trim(vim.fn.system("readlink -e $(which firefox) 2>/dev/null || echo ''")),
          })
        end

        dap.configurations.javascript = js_configs
        dap.configurations.typescript = js_configs
        dap.configurations.javascriptreact = js_configs
        dap.configurations.typescriptreact = js_configs
        dap.configurations.vue = js_configs
      end

      -- Python configs
      local function get_python_configs()
        return {
          {
            type = "python",
            request = "launch",
            name = "Launch current Python file",
            program = "${file}",
            pythonPath = function()
              local venv = vim.fn.getenv("VIRTUAL_ENV")
              if venv ~= vim.NIL and venv ~= "" then
                return venv .. "/bin/python"
              end
              return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
            end,
          },
          {
            type = "python",
            request = "launch",
            name = "Launch with arguments",
            program = "${file}",
            args = function()
              local args_string = vim.fn.input("Arguments: ")
              return vim.split(args_string, " +")
            end,
            pythonPath = function()
              local venv = vim.fn.getenv("VIRTUAL_ENV")
              if venv ~= vim.NIL and venv ~= "" then
                return venv .. "/bin/python"
              end
              return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
            end,
          },
        }
      end

      -- Go configs
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

      -- GDB configs
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

      -- C/C++ configs
      local function get_cpp_configs()
        local configs = {}
        local codelldb = get_codelldb_adapter()
        if codelldb then
          dap.adapters.codelldb = codelldb
          local cpp_configs = {
            {
              name = "Launch (codelldb)",
              type = "codelldb",
              request = "launch",
              program = function()
                return vim.fn.input("Path to executable: ", cwd .. "/", "file")
              end,
              cwd = "${workspaceFolder}",
              stopOnEntry = false,
              args = {},
            },
            {
              name = "Attach to process (codelldb)",
              type = "codelldb",
              request = "attach",
              pid = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
            },
          }
          configs = vim.list_extend(configs, cpp_configs)
        end
        local gdb_configs = get_gdb_configs()
        configs = vim.list_extend(configs, gdb_configs)
        return configs
      end

      -- Lazy setup
      local function setup_language_configs()
        local ft = vim.bo.filetype
        if vim.tbl_contains({ "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }, ft) then
          if not dap.configurations[ft] then
            setup_js_adapters()
          end
        elseif ft == "go" then
          if not dap.configurations.go then
            dap.configurations.go = get_go_configs()
          end
        elseif ft == "python" then
          if not dap.configurations.python then
            setup_python_adapter()
            if dap.adapters.python then
              dap.configurations.python = get_python_configs()
            end
          end
        elseif vim.tbl_contains({ "c", "cpp", "rust" }, ft) then
          if not dap.configurations.cpp then
            if not dap.adapters.gdb then
              dap.adapters.gdb = {
                type = "executable",
                command = vim.fn.trim(vim.fn.system("readlink -e $(which gdb) 2>/dev/null || echo 'gdb'")),
                args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
              }
            end
            local cpp_configs = get_cpp_configs()
            dap.configurations.cpp = cpp_configs
            dap.configurations.c = cpp_configs
            dap.configurations.rust = cpp_configs
          end
        end
      end

      -- Hook first debug command
      local original_continue = dap.continue
      dap.continue = function()
        setup_language_configs()
        dap.continue = original_continue
        return dap.continue()
      end

      -- UI + Go setup
      require("dapui").setup()
      require("dap-go").setup()

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
