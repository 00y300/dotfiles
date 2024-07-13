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
			-- vim.keymap.set(
			-- 	"n",
			-- 	"<leader>e",
			-- 	":MoltenEvaluateOperator<CR>",
			-- 	{ silent = true, desc = "run operator selection" }
			-- )
			-- vim.keymap.set("n", "<leader>rl", ":MoltenEvaluateLine<CR>", { silent = true, desc = "evaluate line" })
			-- vim.keymap.set(
			-- 	"n",
			-- 	"<leader>rr",
			-- 	":MoltenReevaluateCell<CR>",
			-- 	{ silent = true, desc = "re-evaluate cell" }
			-- )
			-- vim.keymap.set(
			-- 	"v",
			-- 	"<leader>r",
			-- 	":<C-u>MoltenEvaluateVisual<CR>gv",
			-- 	{ silent = true, desc = "evaluate visual selection" }
			-- )
			-- vim.keymap.set("n", "<leader>rd", ":MoltenDelete<CR>", { silent = true, desc = "molten delete cell" })
			vim.keymap.set("n", "<leader>mh", ":MoltenHideOutput<CR>", { silent = true, desc = "hide output" })
			-- vim.keymap.set(
			-- 	"n",
			-- 	"<leader>os",
			-- 	":noautocmd MoltenEnterOutput<CR>",
			-- 	{ silent = true, desc = "show/enter output" }
			-- )
		end,
	},
}
