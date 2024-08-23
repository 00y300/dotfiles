return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = {},
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
  config = function()
    local render_mardown = require("render-markdown")
    render_mardown.setup({
      file_types = { "markdown", "quatro" },
    })
  end,
}
