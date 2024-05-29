return {
	"Civitasv/cmake-tools.nvim",
	ft = { "cpp", "cmake" }, -- Activate for C++ and CMake files
	keys = {
		-- Key mappings for cmake-tools
		{ "<leader>cc", "<cmd>CMakeSelectCwd<cr>", noremap = true, silent = true },
		{ "<leader>cb", "<cmd>CMakeSelectBuildDir<cr>", noremap = true, silent = true },
		{ "<leader>cB", "<cmd>CMakeBuild<cr>", noremap = true, silent = true },
		{ "<leader>cf", "<cmd>CMakeBuildCurrentFile<cr>", noremap = true, silent = true },
		{ "<leader>cD", "<cmd>CMakeDebug<cr>", noremap = true, silent = true },
		{ "<leader>cd", "<cmd>CMakeDebugCurrentFile<cr>", noremap = true, silent = true },
	},
	config = function()
		require("cmake-tools").setup({})
	end,
}
