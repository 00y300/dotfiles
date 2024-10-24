return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "quarto" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
    config = function()
      local render_mardown = require("render-markdown")
      render_mardown.setup({
        file_types = { "markdown", "quarto" },
      })
    end,
  },
  {
    "bullets-vim/bullets.vim",
    ft = { "markdown" },
  },
}
