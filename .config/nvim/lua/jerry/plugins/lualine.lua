return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local is_mac = vim.fn.has("macunix") == 1

		local virtual_env = function()
			-- show virtual env for Python and Quarto
			if vim.bo.filetype ~= "python" and vim.bo.filetype ~= "quarto" then
				return ""
			end

			local conda_env = os.getenv("CONDA_DEFAULT_ENV")
			local venv_path = os.getenv("VIRTUAL_ENV")

			if venv_path == nil then
				if conda_env == nil then
					return ""
				else
					return string.format("🐍 %s", conda_env)
				end
			else
				local venv_name = vim.fn.fnamemodify(venv_path, ":t")
				return string.format("🐍 %s", venv_name)
			end
		end

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
					{
						virtual_env,
						color = { fg = "#a6e3a1" }, -- Setting the color to green
					},
					{ "filetype" },
				},
			},
		})
	end,
}
