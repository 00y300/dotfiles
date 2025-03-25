return {
  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
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
    },
    keys = {
      { "<leader>dc", "<cmd>DapContinue<CR>", desc = "Start or continue debugging" },
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

      -- Define custom icons
      vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticWarn", linehl = "DapStoppedLine" })
      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapLogPoint", { text = ".>", texthl = "DiagnosticInfo" })

      -- Setup for JavaScript/TypeScript debugging using vscode-js-debug
      require("dap-vscode-js").setup({
        debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
        adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost", "firefox" },
      })

      -- Dynamically build the Firefox adapter path
      -- This is done within Nix
      local firefoxAdapterPath = vim.fn.trim(
        vim.fn.system("nix eval --raw nixpkgs#vscode-extensions.firefox-devtools.vscode-firefox-debug.outPath")
      ) .. "/share/vscode/extensions/firefox-devtools.vscode-firefox-debug/dist/adapter.bundle.js"

      -- Add Firefox adapter definition using the computed path
      dap.adapters.firefox = {
        type = "executable",
        command = "node",
        args = { firefoxAdapterPath },
      }

      -- Configure DAP for JavaScript-based languages
      local js_based_languages = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }
      for _, language in ipairs(js_based_languages) do
        dap.configurations[language] = {
          {
            type = "firefox",
            name = "Launch Firefox to debug 󰈹",
            request = "launch",
            reAttach = true,
            url = function()
              local co = coroutine.running()
              return coroutine.create(function()
                vim.ui.input({
                  prompt = "Enter URL: ",
                  default = "http://localhost:3000",
                }, function(url)
                  if url == nil or url == "" then
                    return
                  else
                    coroutine.resume(co, url)
                  end
                end)
              end)
            end,
            webRoot = vim.fn.getcwd(),
            firefoxExecutable = vim.fn.trim(vim.fn.system("readlink -e $(which firefox)")),
          },
          {
            type = "pwa-chrome",
            request = "launch",
            name = "Launch & Debug Chrome ",
            url = function()
              local co = coroutine.running()
              return coroutine.create(function()
                vim.ui.input({
                  prompt = "Enter URL: ",
                  default = "http://localhost:3000",
                }, function(url)
                  if url == nil or url == "" then
                    return
                  else
                    coroutine.resume(co, url)
                  end
                end)
              end)
            end,
            webRoot = vim.fn.getcwd(),
            protocol = "inspector",
            sourceMaps = true,
            userDataDir = false,
          },
        }
      end

      -- GDB Adapter and Configurations
      dap.adapters.gdb = {
        type = "executable",
        command = vim.fn.trim(vim.fn.system("readlink -e $(which gdb)")),
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
      }

      dap.configurations.c = {
        {
          name = "Launch",
          type = "gdb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
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
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          pid = function()
            local name = vim.fn.input("Executable name (filter): ")
            return require("dap.utils").pick_process({ filter = name })
          end,
          cwd = "${workspaceFolder}",
        },
        {
          name = "Attach to gdbserver :1234",
          type = "gdb",
          request = "attach",
          target = "localhost:1234",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
        },
      }

      dap.configurations.cpp = dap.configurations.c
      dap.configurations.rust = dap.configurations.c

      -- DAP UI Setup
      require("dapui").setup()
      require("dap-go").setup()
      local dapui = require("dapui")
      dap.listeners.after.event_initialized["dapui_config"] = dapui.open
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"] = dapui.close

      vim.api.nvim_set_keymap("v", "<M-k>", "<cmd>lua require('dapui').eval()<CR>", { noremap = true, silent = true })
    end,
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
}
