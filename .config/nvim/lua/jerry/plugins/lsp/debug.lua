return {
  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy", -- Changed event to "VimEnter" for immediate setup
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticWarn", linehl = "DapStoppedLine" })
      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapLogPoint", { text = ".>", texthl = "DiagnosticInfo" })

      require("dapui").setup() -- Moved dapui.setup outside of the listeners

      require("dap").listeners.before["attach"]["dapui_config"] = function()
        require("dapui").open()
      end
      require("dap").listeners.before["launch"]["dapui_config"] = function()
        require("dapui").open()
      end
      require("dap").listeners.before["event_terminated"]["dapui_config"] = function()
        require("dapui").close()
      end
      require("dap").listeners.before["event_exited"]["dapui_config"] = function()
        require("dapui").close()
      end

      -- Key mappings
      vim.api.nvim_set_keymap(
        "n",
        "<leader>dc",
        "<cmd>DapContinue<CR>",
        { noremap = true, silent = true, desc = "Start or continue debugging" }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<leader>do",
        "<cmd>DapStepOver<CR>",
        { noremap = true, silent = true, desc = "Step over" }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<leader>di",
        "<cmd>DapStepInto<CR>",
        { noremap = true, silent = true, desc = "Step into" }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<leader>dO",
        "<cmd>DapStepOut<CR>",
        { noremap = true, silent = true, desc = "Step out" }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<leader>db",
        "<cmd>DapToggleBreakpoint<CR>",
        { noremap = true, silent = true, desc = "Toggle breakpoint" }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<leader>dx",
        "<cmd>DapTerminate<CR>",
        { noremap = true, silent = true, desc = "Dap Terminate" }
      )

      vim.api.nvim_set_keymap(
        "n",
        "<leader>dr",
        "<cmd>DapReplToggle<CR>",
        { noremap = true, silent = true, desc = "Toggle REPL" }
      )
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy", -- Changed event to "VimEnter" for immediate setup
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("mason").setup()
      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb", "python" },
        automatic_installation = false,
        handlers = {
          function(config)
            -- Keep original functionality
            require("mason-nvim-dap").default_setup(config)
          end,
        },
      })
    end,
  },
}
