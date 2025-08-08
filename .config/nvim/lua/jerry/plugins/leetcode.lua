return {
  "kawre/leetcode.nvim",
  build = ":TSUpdate html",
  cmd = "Leet",
  -- enabled = true,
  dependencies = {

    "MunifTanjim/nui.nvim",

    -- optional
    "nvim-treesitter/nvim-treesitter",
    "rcarriga/nvim-notify",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    -- configuration goes here
    lang = "python3",
    image_support = false,
    -- logging = true,
    -- picker = { provider = "snacks" },
  },
}
