return {
	"linux-cultist/venv-selector.nvim",
	dependencies = {
		"neovim/nvim-lspconfig",
		"nvim-telescope/telescope.nvim",
	},
	ft = "python", -- Activate for Python files
	branch = "regexp", -- This is the regexp branch, use this for the new version
	keys = {
		-- Keymap to open VenvSelector to pick a venv.
		{ "<leader>vs", "<cmd>VenvSelect<cr>" },
		-- Keymap to retrieve the venv from a cache (the one previously used for the same project directory).
		{ "<leader>vc", "<cmd>VenvSelectCached<cr>" },
	},
	config = function()
		require("venv-selector").setup({
			anaconda_base_path = "/Users/jerrynava/miniconda3/",
			anaconda_envs_path = "/Users/jerrynava/miniconda3/envs/",
		})
	end,
}
