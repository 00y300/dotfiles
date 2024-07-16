return {
	{
		"benlubas/molten-nvim",
		-- enabled = true,
		ft = { "markdown", "quarto", "latex" },

		build = ":UpdateRemotePlugins",
		init = function()
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_output_win_max_height = 20
			vim.g.molten_auto_open_output = false
			vim.g.molten_wrap_output = true
			vim.g.molten_virt_text_output = true
			-- vim.g.molten_virt_lines_off_by_1 = true
			vim.g.python3_host_prog = vim.fn.expand("~/.virtualenvs/neovim/bin/python3")
		end,
		config = function()
			vim.keymap.set("n", "<leader>mi", ":MoltenInit<CR>", { silent = true, desc = "Initialize the plugin" })
			vim.keymap.set("n", "<leader>mh", ":MoltenHideOutput<CR>", { silent = true, desc = "hide output" })
		end,
	},
}
