return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local is_mac = vim.fn.has("macunix") == 1

		require("lualine").setup({
			options = {
				theme = "ayu_mirage",
			},
			sections = {
				lualine_x = {
					{ "encoding" },
					{
						"fileformat",
						symbols = is_mac and { unix = "" } or nil,
					},
					{ "filetype" },
				},
			},
		})
	end,
}
