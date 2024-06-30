local wezterm = require("wezterm")
local config = {}
-- Theme
config.color_scheme = "Catppuccin Mocha"
-- Font Sizes
config.font = wezterm.font("Hurmit Nerd Font Mono")
config.font_size = 18
-- Setting the Image Protocol
config.enable_kitty_graphics = true
return config
