return {
  "fredrikaverpil/godoc.nvim",
  version = "*",
  enabled = false,
  dependencies = {
    { "nvim-telescope/telescope.nvim" }, -- optional
    {
      "nvim-treesitter/nvim-treesitter",
      opts = {
        ensure_installed = { "go" },
      },
    },
  },
  build = "go install github.com/lotusirous/gostdsym/stdsym@latest", -- optional
  cmd = { "GoDoc" }, -- optional
  opts = {

    window = {
      type = "vsplit",
    },
  }, -- see further down below for configuration
}
