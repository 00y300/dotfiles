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
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Start or continue debugging",
      },
      {
        "<leader>dC",
        function()
          require("dap").clear_breakpoints()
        end,
        desc = "Clear all Breakpoints",
      },
      {
        "<leader>do",
        function()
          require("dap").step_over()
        end,
        desc = "Step over",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Step into",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_out()
        end,
        desc = "Step out",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle breakpoint",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Set conditional breakpoint",
      },
      {
        "<leader>dx",
        function()
          require("dap").terminate()
          require("dapui").close()
          require("nvim-dap-virtual-text").refresh()
        end,
        desc = "Terminate debugging session",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "Toggle REPL",
      },
      {
        "<leader>de",
        function()
          require("dapui").eval()
        end,
        desc = "Evaluate Expression",
      },
      {
        "<leader>dE",
        function()
          local dap = require("dap")
          local configs = dap.configurations.cpp or {}
          for _, c in ipairs(configs) do
            if c.name:match("ESP32") then
              dap.run(c)
              return
            end
          end
          vim.notify("No ESP32 debug config found", vim.log.levels.WARN)
        end,
        desc = "Debug ESP32 (quick launch)",
      },
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

      -- ══════════════════════════════════════════════════════════
      -- ESP32-S3 adapter (OpenOCD + xtensa-gdb DAP mode)
      -- ══════════════════════════════════════════════════════════
      local function find_xtensa_gdb()
        local known_path = vim.fn.expand(
          "$HOME/.espressif/tools/xtensa-esp-elf-gdb/16.3_20250913/xtensa-esp-elf-gdb/bin/xtensa-esp32s3-elf-gdb"
        )
        if vim.fn.executable(known_path) == 1 then
          return known_path
        end
        local glob = vim.fn.glob(
          vim.fn.expand("$HOME/.espressif/tools/xtensa-esp-elf-gdb/*/xtensa-esp-elf-gdb/bin/xtensa-esp32s3-elf-gdb"),
          false,
          true
        )
        if type(glob) == "table" and #glob > 0 then
          return glob[#glob]
        end
        local from_path = vim.fn.exepath("xtensa-esp32s3-elf-gdb")
        if from_path ~= "" then
          return from_path
        end
        return nil
      end

      local function find_elf()
        local candidates = {
          cwd .. "/build/app.elf",
          cwd .. "/build/" .. vim.fn.fnamemodify(cwd, ":t") .. ".elf",
        }
        for _, path in ipairs(candidates) do
          if vim.fn.filereadable(path) == 1 then
            return path
          end
        end
        local elfs = vim.fn.glob(cwd .. "/build/*.elf", false, true)
        if type(elfs) == "table" and #elfs > 0 then
          return elfs[1]
        end
        return vim.fn.input("Path to ELF: ", cwd .. "/build/", "file")
      end

      local function setup_esp32s3()
        local gdb_path = find_xtensa_gdb()
        if not gdb_path then
          vim.notify("xtensa-esp32s3-elf-gdb not found. Is ESP-IDF installed?", vim.log.levels.ERROR)
          return false
        end

        local elf_path = find_elf()

        -- Pass ELF on command line so symbols load before DAP handshake
        dap.adapters.esp32s3 = {
          type = "executable",
          command = gdb_path,
          args = { "-i", "dap", elf_path },
        }

        dap.configurations.cpp = dap.configurations.cpp or {}
        dap.configurations.c = dap.configurations.c or {}
        -- The sequence that works in manual GDB:
        --   1. file app.elf           (done via args above)
        --   2. target remote :3333    (initCommands)
        --   3. monitor reset halt     (initCommands)
        --   4. break app.cpp:12       (nvim-dap sends setBreakpoints)
        --   5. continue               (nvim-dap sends after configurationDone)
        --
        -- Key insight from the DAP log: with request="launch", GDB DAP
        -- reloads the ELF after configurationDone but never sends a
        -- "stopped" event and never runs "continue". The target just sits.
        --
        -- With request="attach", nvim-dap expects the process already
        -- exists and will send "continue" after configurationDone,
        -- which makes execution resume and hit breakpoints.

        local esp_configs = {
          {
            name = "ESP32-S3: Debug (reset + halt + run)",
            type = "esp32s3",
            request = "attach",
            program = elf_path,
            cwd = cwd,
            stopAtBeginningOfMainSubprogram = true,
            target = "localhost:3333", -- ← add this
            initCommands = {
              "set remote hardware-watchpoint-limit 2",
              "set remotetimeout 10",
              "set mem inaccessible-by-default off",
              -- same here, remove "target remote :3333"
              "maintenance flush register-cache",
            },
          },
          {
            name = "ESP32-S3: Attach (no reset, just connect)",
            type = "esp32s3",
            request = "attach",
            program = elf_path,
            cwd = cwd,
            stopAtBeginningOfMainSubprogram = false,
            target = "localhost:3333", -- ← add this
            initCommands = {
              "set remote hardware-watchpoint-limit 2",
              "set remotetimeout 10",
              "set mem inaccessible-by-default off",
              "set scheduler-locking off", -- ← let all threads run
              "monitor reset halt",
              "maintenance flush register-cache",
              "thread 1", -- ← auto-select main thread
            },
          },
        }

        for i = #esp_configs, 1, -1 do
          table.insert(dap.configurations.cpp, 1, esp_configs[i])
        end
        dap.configurations.c = dap.configurations.cpp

        vim.notify("ESP32-S3 debug configured: " .. elf_path, vim.log.levels.INFO)
        return true
      end

      -- ══════════════════════════════════════════════════════════
      -- ESP-IDF project detection
      -- ══════════════════════════════════════════════════════════
      local function is_esp_idf_project()
        if vim.fn.filereadable(cwd .. "/sdkconfig") == 1 then
          return true
        end
        if vim.fn.filereadable(cwd .. "/sdkconfig.defaults") == 1 then
          return true
        end
        local cmake = cwd .. "/CMakeLists.txt"
        if vim.fn.filereadable(cmake) == 1 then
          local lines = vim.fn.readfile(cmake)
          for _, line in ipairs(lines) do
            if line:match("idf_component_register") or line:match("project%(") then
              return true
            end
          end
        end
        return false
      end

      -- ══════════════════════════════════════════════════════════
      -- Probe-rs adapter (embedded Rust: ESP32, STM32, nRF, RP2040)
      -- ══════════════════════════════════════════════════════════
      local function setup_probe_rs()
        local probe_rs = vim.fn.exepath("probe-rs")
        if probe_rs == "" then
          vim.notify("probe-rs not found in PATH", vim.log.levels.ERROR)
          return false
        end

        dap.adapters["probe-rs-debug"] = {
          type = "server",
          port = "${port}",
          executable = {
            command = probe_rs,
            args = { "dap-server", "--port", "${port}" },
          },
        }

        require("dap.ext.vscode").type_to_filetypes["probe-rs-debug"] = { "rust" }

        dap.listeners.before["event_probe-rs-rtt-channel-config"]["probe-rs"] = function(session, body)
          local utils = require("dap.utils")
          utils.notify(
            string.format('probe-rs: Opening RTT channel %d with name "%s"!', body.channelNumber, body.channelName)
          )
          local file = io.open("probe-rs.log", "a")
          if file then
            file:write(
              string.format(
                '%s: Opening RTT channel %d with name "%s"!\n',
                os.date("%Y-%m-%d-T%H:%M:%S"),
                body.channelNumber,
                body.channelName
              )
            )
            file:close()
          end
          session:request("rttWindowOpened", { body.channelNumber, true })
        end

        dap.listeners.before["event_probe-rs-rtt-data"]["probe-rs"] = function(_, body)
          local message =
            string.format("%s: RTT-Channel %d - %s", os.date("%Y-%m-%d-T%H:%M:%S"), body.channelNumber, body.data)
          require("dap.repl").append(message)
          local file = io.open("probe-rs.log", "a")
          if file then
            file:write(message .. "\n")
            file:close()
          end
        end

        dap.listeners.before["event_probe-rs-show-message"]["probe-rs"] = function(_, body)
          local message = string.format("%s: probe-rs: %s", os.date("%Y-%m-%d-T%H:%M:%S"), body.message)
          require("dap.repl").append(message)
          local file = io.open("probe-rs.log", "a")
          if file then
            file:write(message .. "\n")
            file:close()
          end
        end

        return true
      end

      -- ══════════════════════════════════════════════════════════
      -- Codelldb (Nix)
      -- ══════════════════════════════════════════════════════════
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

      -- ══════════════════════════════════════════════════════════
      -- Python adapter (Nix)
      -- ══════════════════════════════════════════════════════════
      local function setup_python_adapter()
        local python_cmd = vim.fn.exepath("python3") or vim.fn.exepath("python") or "python3"

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

      -- ══════════════════════════════════════════════════════════
      -- Firefox adapter (Nix)
      -- ══════════════════════════════════════════════════════════
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
            dap.adapters.firefox = {
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

      -- ══════════════════════════════════════════════════════════
      -- JS/TS debug adapters (Node + Chrome + Firefox)
      -- ══════════════════════════════════════════════════════════
      local function setup_js_adapters()
        local ok, js_debug_path =
          pcall(vim.fn.trim, vim.fn.system("nix eval --raw nixpkgs#vscode-js-debug 2>/dev/null"))
        if not ok or js_debug_path == "" then
          vim.notify("vscode-js-debug not found via nix", vim.log.levels.ERROR)
          return
        end

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
            firefoxExecutable = vim.fn.trim(vim.fn.system("readlink -e $(which firefox) 2>/dev/null || echo ''")),
          })
        end

        dap.configurations.javascript = js_configs
        dap.configurations.typescript = js_configs
        dap.configurations.javascriptreact = js_configs
        dap.configurations.typescriptreact = js_configs
        dap.configurations.vue = js_configs
      end

      -- ══════════════════════════════════════════════════════════
      -- Python configs
      -- ══════════════════════════════════════════════════════════
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

      -- ══════════════════════════════════════════════════════════
      -- Go configs
      -- ══════════════════════════════════════════════════════════
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

      -- ══════════════════════════════════════════════════════════
      -- C/C++ configs
      -- ══════════════════════════════════════════════════════════
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
        return configs
      end

      -- ══════════════════════════════════════════════════════════
      -- Embedded Rust project detection
      -- ══════════════════════════════════════════════════════════
      local function is_embedded_rust_project()
        local cargo_toml = cwd .. "/Cargo.toml"
        if vim.fn.filereadable(cargo_toml) ~= 1 then
          return false
        end
        local lines = vim.fn.readfile(cargo_toml)
        for _, line in ipairs(lines) do
          if
            line:match("esp%-hal")
            or line:match("esp%-idf")
            or line:match("cortex%-m")
            or line:match("embassy%-")
            or line:match("probe%-rs")
            or line:match("nrf%-hal")
            or line:match("stm32")
            or line:match("rp2040")
          then
            return true
          end
        end
        local cargo_config = cwd .. "/.cargo/config.toml"
        if vim.fn.filereadable(cargo_config) == 1 then
          local config_lines = vim.fn.readfile(cargo_config)
          for _, line in ipairs(config_lines) do
            if line:match("xtensa%-") or line:match("thumbv[67]") or line:match("riscv32") then
              return true
            end
          end
        end
        return false
      end

      -- ══════════════════════════════════════════════════════════
      -- Lazy language config setup
      -- ══════════════════════════════════════════════════════════
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
        elseif ft == "rust" and is_embedded_rust_project() then
          if not dap.adapters["probe-rs-debug"] then
            setup_probe_rs()
          end
        elseif vim.tbl_contains({ "c", "cpp" }, ft) and is_esp_idf_project() then
          if not dap.adapters.esp32s3 then
            setup_esp32s3()
          end
        elseif vim.tbl_contains({ "c", "cpp", "rust" }, ft) then
          if not dap.configurations[ft] then
            local cpp_configs = get_cpp_configs()
            dap.configurations.cpp = cpp_configs
            dap.configurations.c = cpp_configs
            if not dap.configurations.rust then
              dap.configurations.rust = cpp_configs
            end
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
