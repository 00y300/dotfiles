return {
  {
    "mfussenegger/nvim-dap",
    -- event = "VeryLazy",
    dependencies = {
      "rcarriga/nvim-dap-ui",
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
    },
    config = function()
      local dap = require("dap")

      -- Set custom icons
      vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticWarn", linehl = "DapStoppedLine" })
      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapLogPoint", { text = ".>", texthl = "DiagnosticInfo" })

      -- Setup dap-vscode-js
      require("dap-vscode-js").setup({
        debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
        adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost", "firefox" },
      })

      -- Configure DAP for JavaScript, TypeScript, etc.
      local js_based_languages = {
        "typescript",
        "javascript",
        "typescriptreact",
        "javascriptreact",
        "vue",
      }

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
            firefoxExecutable = "/opt/homebrew/bin/firefox",
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

      -- DAP UI Setup
      require("dapui").setup()
      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open({ reset = true })
      end
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"] = dapui.close
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("mason").setup()
      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb", "cppdbg", "python", "js", "chrome", "firefox" },
        automatic_installation = false,
        handlers = {
          function(config)
            require("mason-nvim-dap").default_setup(config)
          end,
        },
      })
    end,
  },
}
