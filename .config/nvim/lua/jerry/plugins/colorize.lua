return {
  -- "norcalli/nvim-colorizer.lua",
  "NvChad/nvim-colorizer.lua",
  -- ft = { "javascript", "css" },
  event = "BufReadPre",
  config = function()
    require("colorizer").setup({
      filetypes = { "javascript", "css", "html" },
      user_default_options = {
        names = false, -- Disable "name" codes like Blue or Gray
        RGB = true, -- Enable #RGB hex codes
        RRGGBB = true, -- Enable #RRGGBB hex codes
        RRGGBBAA = false, -- Disable #RRGGBBAA hex codes
        AARRGGBB = false, -- Disable 0xAARRGGBB hex codes
        rgb_fn = true, -- Enable CSS rgb() and rgba() functions
        hsl_fn = false, -- Disable CSS hsl() and hsla() functions
        css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = false, -- Disable all CSS *functions*: rgb_fn, hsl_fn
        mode = "background", -- Set the display mode to 'background'
        tailwind = true, -- Enable Tailwind CSS colors
        sass = { enable = false, parsers = { "css" } }, -- Disable Sass colors
        virtualtext = "■", -- Virtualtext character
        virtualtext_inline = false, -- Disable inline virtualtext
        virtualtext_mode = "foreground", -- Virtualtext highlight mode
        always_update = false, -- Disable updates when buffer is not focused
      },
      -- buftypes = {
      --   -- Apply options to all buffer types
      -- },
      user_commands = true, -- Enable all user commands
    })
  end,
}
