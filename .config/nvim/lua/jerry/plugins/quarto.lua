-- Quarto and Otter setup
return {
	{
		"quarto-dev/quarto-nvim",
		opt = {},
		dependencies = {
			{
				"jmbuhr/otter.nvim",
				dev = false,
				dependencies = {
					-- "neovim/nvim-lspconfig",
					-- "nvim-treesitter/nvim-treesitter",
					-- "hrsh7th/nvim-cmp",
				},
				opts = {
					buffers = {
						set_filetype = true,
						write_to_disk = false,
					},
					handle_leading_whitespace = true,
				},
			},
		},
		config = function()
			vim.keymap.set(
				{ "n", "i" },
				"<leader>ci",
				"<esc>i```{python}<cr>```<esc>o",
				{ desc = "[i]nsert code chunk" }
			)
		end,
	},
}
