return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "quarto", "codecompanion" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    config = function()
      local render_markdown = require("render-markdown")

      render_markdown.setup({
        render_modes = { "n", "c", "v" },
        file_types = { "markdown", "quarto", "codecompanion" },
        heading = {
          position = "inline",
          icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
          width = "full",
          -- bars render because backgrounds is left at its default
        },
      })

      local function set_markdown_colors()
        local ok, palettes = pcall(require, "catppuccin.palettes")
        if not ok then
          return
        end
        local C = palettes.get_palette()

        -- Blend an accent color toward the background for a subtle bar tint.
        local function blend(fg, bg, alpha)
          local function hex(c)
            return tonumber(c:sub(2), 16)
          end
          local f, b = hex(fg), hex(bg)
          local fr, fg_, fb = math.floor(f / 65536) % 256, math.floor(f / 256) % 256, f % 256
          local br, bg_, bb = math.floor(b / 65536) % 256, math.floor(b / 256) % 256, b % 256
          local r = math.floor(fr * alpha + br * (1 - alpha))
          local g = math.floor(fg_ * alpha + bg_ * (1 - alpha))
          local bl = math.floor(fb * alpha + bb * (1 - alpha))
          return string.format("#%02x%02x%02x", r, g, bl)
        end

        -- H1 -> H6 accent order. Reorder to taste.
        local accents = { C.blue, C.yellow, C.green, C.teal, C.mauve, C.red }

        for i, accent in ipairs(accents) do
          -- Heading text + icon foreground
          vim.api.nvim_set_hl(0, "RenderMarkdownH" .. i, { fg = accent, bold = true })
          vim.api.nvim_set_hl(0, "@markup.heading." .. i .. ".markdown", { fg = accent, bold = true })
          -- Background bar: accent blended ~15% into the editor background
          vim.api.nvim_set_hl(0, "RenderMarkdownH" .. i .. "Bg", { bg = blend(accent, C.base, 0.15) })
        end

        -- Links in lavender
        vim.api.nvim_set_hl(0, "@markup.link.label", { fg = C.lavender })
        vim.api.nvim_set_hl(0, "@markup.link.url", { fg = C.lavender })
        vim.api.nvim_set_hl(0, "RenderMarkdownLink", { fg = C.lavender })
        vim.api.nvim_set_hl(0, "RenderMarkdownWikiLink", { fg = C.lavender })
      end

      set_markdown_colors()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_markdown_colors })

      vim.keymap.set("n", "<leader>mr", function()
        render_markdown.toggle()
      end, { desc = "[M]arkdown [R]ender toggle" })
    end,
  },
  {
    "bullets-vim/bullets.vim",
    ft = { "markdown" },
  },
  {
    "epilande/checkbox-cycle.nvim",
    ft = "markdown",
    opts = {
      states = { "[ ]", "[/]", "[x]", "[~]" },
    },
    keys = {
      {
        "<CR>",
        "<Cmd>CheckboxCycleNext<CR>",
        desc = "Checkbox Next",
        ft = { "markdown" },
        mode = { "n", "v" },
      },
      {
        "<S-CR>",
        "<Cmd>CheckboxCyclePrev<CR>",
        desc = "Checkbox Previous",
        ft = { "markdown" },
        mode = { "n", "v" },
      },
    },
  },
}
