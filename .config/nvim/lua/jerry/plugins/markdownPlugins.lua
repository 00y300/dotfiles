return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "quarto", "codecompanion" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      render_modes = { "n", "c", "v" },
      file_types = { "markdown", "quarto", "codecompanion" },
      overrides = {
        filetype = {
          -- codecompanion = {
          --   heading = {
          --     icons = { "󰚩 ", "󰭹 ", "🧠 ", "󰮊 ", "󰮊 ", "󰮊 " },
          --   },
          -- },
        },
      },
    },
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
