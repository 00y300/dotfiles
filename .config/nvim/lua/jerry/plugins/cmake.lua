return {
	"Civitasv/cmake-tools.nvim",
	config = function()
		require("cmake-tools").setup({})

		-- Key mappings
		local map = vim.api.nvim_set_keymap
		local options = { noremap = true, silent = true }
		map("n", "<leader>cc", ":CMakeSelectCwd<CR>", options)
		map("n", "<leader>cb", ":CMakeSelectBuildDir<CR>", options)
		map("n", "<leader>cB", ":CMakeBuild<CR>", options)
		map("n", "<leader>cb", ":CMakeBuildCurrentFile<CR>", options)
		map("n", "<leader>cD", ":CMakeDebug<CR>", options)
		map("n", "<leader>cd", ":CMakeDebugCurrentFile<CR>", options)
	end,
}
