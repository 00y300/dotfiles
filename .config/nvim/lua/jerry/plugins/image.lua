return {
	{
		"vhyrro/luarocks.nvim",
		priority = 1000, -- this plugin needs to run before anything else
		opts = {
			rocks = { "magick" },
		},
	},
	{ -- show images in nvim!
		"3rd/image.nvim",
		enabled = true,
		dev = false,
		ft = { "markdown", "quarto", "vimwiki" },
		dependencies = {
			{
				"vhyrro/luarocks.nvim",
				priority = 1001, -- this plugin needs to run before anything else
				opts = {
					rocks = { "magick" },
				},
			},
		},
		config = function()
			local image = require("image")
			image.setup({
				backend = "kitty",
				integrations = {
					markdown = {
						enabled = true,
						clear_in_insert_mode = false,
						only_render_image_at_cursor = true,
						filetypes = { "markdown", "vimwiki", "quarto" },
					},
					html = {
						enabled = false,
					},
					css = {
						enabled = false,
					},
				},
				max_width = 300,
				max_height = 300,
				max_width_window_percentage = 55,
				max_height_window_percentage = 55,
				window_overlap_clear_enabled = false, -- toggles images when windows are overlapped
				window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
				editor_only_render_when_focused = true, -- auto show/hide images when the editor gains/looses focus
				tmux_show_only_in_active_window = false, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
				hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" }, -- render image files as images when opened
			})
		end,
	},
}
