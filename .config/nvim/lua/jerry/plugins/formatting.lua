return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				lua = { "stylua" },
				python = { "isort", "black" }, -- Define the formatter for python
				cpp = { "clang-format" },
				cmake = { "gersemi" },
				-- quarto = { "injected" }, -- Use injected formatter for Quarto files
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			},
		})

		-- Injected language formatting setup
		conform.formatters.injected = {
			options = {
				ignore_errors = false,
				lang_to_ext = {
					python = "py",
				},
				lang_to_formatters = {
					-- python = { "isort", "black" }, -- Define the formatter for python
				},
			},
		}

		-- Set keymap for formatting file or range in visual mode
		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
