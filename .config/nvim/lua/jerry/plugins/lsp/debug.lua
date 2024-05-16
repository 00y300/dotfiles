return {
	{
		"mfussenegger/nvim-dap",
		event = "VimEnter", -- Changed event to "VimEnter" for immediate setup
		dependencies = { 
			"rcarriga/nvim-dap-ui", 
			"nvim-neotest/nvim-nio" 
		},
		config = function()
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
				"<leader>db",
				"<cmd>DapToggleBreakpoint<CR>",
				{ noremap = true, silent = true, desc = "Add breakpoint at line" }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>dr",
				"<cmd>DapContinue<CR>",
				{ noremap = true, silent = true, desc = "Start or continue the debugger" }
			)
		end,
	},
	{
		"jay-babu/mason-nvim-dap.nvim",
		event = "VimEnter", -- Changed event to "VimEnter" for immediate setup
		dependencies = {
			"williamboman/mason.nvim",
			"mfussenegger/nvim-dap",
		},
		config = function()
			require("mason").setup()
			require("mason-nvim-dap").setup({
				ensure_installed = { "codelldb" },
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
