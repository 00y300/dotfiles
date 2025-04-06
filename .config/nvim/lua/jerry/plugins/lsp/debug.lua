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
      },
      {
        "theHamsta/nvim-dap-virtual-text",

        config = function()
          require("nvim-dap-virtual-text").setup({
            enabled = true, -- enable this plugin (the default)
            enabled_commands = true, -- create commands for toggling and refreshing
            highlight_changed_variables = true,
            highlight_new_as_changed = false,
            show_stop_reason = true, -- show stop reason when exceptions occur
            commented = false, -- do not prefix virtual text with comment string
            only_first_definition = true, -- show text only at the first variable definition
            all_references = false,
            clear_on_continue = false, -- avoid flickering on "continue"
          })
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
      { "<leader>dx", "<cmd>DapTerminate<CR>", desc = "Terminate debugging session" },
      { "<leader>dr", "<cmd>DapReplToggle<CR>", desc = "Toggle REPL" },
      { "<leader>de", "<cmd>lua require('dapui').eval()<CR>", desc = "Evaluate Expression" },
    },
    config = function()
      local dap = require("dap")
      local cwd = vim.fn.getcwd()

      -- Define signs for various debugger states.
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

      -- Setup JavaScript/TypeScript debugging via vscode-js-debug using your file path.
      require("dap-vscode-js").setup({
        debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
        adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost", "firefox" },
      })

      -- Setup Firefox adapter using your nix-based path.
      local firefoxAdapterPath = vim.fn.trim(
        vim.fn.system("nix eval --raw nixpkgs#vscode-extensions.firefox-devtools.vscode-firefox-debug.outPath")
      ) .. "/share/vscode/extensions/firefox-devtools.vscode-firefox-debug/dist/adapter.bundle.js"
      dap.adapters.firefox = {
        type = "executable",
        command = "node",
        args = { firefoxAdapterPath },
      }

      -- Helper function to prompt for a URL using a coroutine.
      local function prompt_url(default)
        local co = coroutine.running()
        return coroutine.create(function()
          vim.ui.input({ prompt = "Enter URL: ", default = default }, function(url)
            if url and url ~= "" then
              coroutine.resume(co, url)
            end
          end)
        end)
      end

      -- Configure debugging for JavaScript-based languages.
      local js_configs = {
        {
          type = "firefox",
          name = "Launch Firefox to debug 󰈹",
          request = "launch",
          reAttach = true,
          url = function()
            return prompt_url("http://localhost:3000")
          end,
          webRoot = cwd,
          firefoxExecutable = vim.fn.trim(vim.fn.system("readlink -e $(which firefox)")),
        },
        {
          type = "pwa-chrome",
          request = "launch",
          name = "Launch & Debug Chrome ",
          url = function()
            return prompt_url("http://localhost:3000")
          end,
          webRoot = cwd,
          protocol = "inspector",
          sourceMaps = true,
          userDataDir = false,
        },
      }
      for _, lang in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }) do
        dap.configurations[lang] = js_configs
      end

      dap.configurations.go = {
        {
          type = "go",
          name = "Debug current file",
          request = "launch",
          program = "${file}", -- Tells Delve to debug whatever file is currently open
        },
        {
          type = "go",
          name = "Debug current file (with args)",
          request = "launch",
          program = "${file}",
          args = require("dap-go").get_arguments, -- Prompts you for command-line args
        },
      }
      -- Setup GDB adapter and configurations for C, C++, and Rust.
      dap.adapters.gdb = {
        type = "executable",
        command = vim.fn.trim(vim.fn.system("readlink -e $(which gdb)")),
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
      }
      local gdb_config = {
        {
          name = "Launch",
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
          name = "Select and attach to process",
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
          name = "Attach to gdbserver :1234",
          type = "gdb",
          request = "attach",
          target = "localhost:1234",
          program = function()
            return vim.fn.input("Path to executable: ", cwd .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
        },
      }
      dap.configurations.c = gdb_config
      dap.configurations.cpp = gdb_config
      dap.configurations.rust = gdb_config

      -- Initialize DAP UI and dap-go.
      require("dapui").setup()
      require("dap-go").setup()
      local dapui = require("dapui")
      dap.listeners.after.event_initialized["dapui_config"] = dapui.open
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"] = dapui.close
    end,
  },
}
