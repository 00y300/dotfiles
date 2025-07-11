return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "quarto" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
    config = function()
      local render_mardown = require("render-markdown")
      render_mardown.setup({
        file_types = { "markdown", "quarto" },
        latex = { enabled = false },
      })
    end,
  },
  {
    "bullets-vim/bullets.vim",
    ft = { "markdown" },
  },
  {
    "epilande/checkbox-cycle.nvim",
    ft = "markdown",
    -- Optional: Configuration
    opts = {
      -- Example: Custom states
      states = { "[ ]", "[/]", "[x]", "[~]" },
    },
    -- Optional: Key mappings
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
