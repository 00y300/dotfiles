return {
  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto" },
    dev = false,
    opts = {
      debug = false,
      closePreviewOnExit = true,
      lspFeatures = {
        enabled = true,
        chunks = "curly",
        languages = { "r", "python", "julia", "bash", "html" },
        diagnostics = {
          enabled = true,
          triggers = { "BufWritePost" },
        },
        completion = {
          enabled = true,
        },
      },
      codeRunner = {
        enabled = true,
        default_method = "molten",
        ft_runners = { python = "molten" },
        never_run = { "yaml" },
      },
    },
    dependencies = {
      "jmbuhr/otter.nvim",
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
      },
    },
    keys = {
      {
        "<leader>oa",
        function()
          require("otter").activate()
        end,
        desc = "Activate Otter",
      },
      { "<leader>rc", "<cmd>QuartoSend<CR>", desc = "Quarto send cell" },
      { "<leader>rA", "<cmd>QuartoSendAbove<CR>", desc = "Quarto send cell and above" },
      { "<leader>rB", "<cmd>QuartoSendBelow<CR>", desc = "Quarto send below" },
      { "<leader>ra", "<cmd>QuartoSendAll<CR>", desc = "Quarto send all cells" },
      { "<leader>rp", "<cmd>QuartoPreview<CR>", desc = "Quarto Preview" },
    },
  },
  {
    "GCBallesteros/jupytext.nvim",
    opts = {
      custom_language_formatting = {
        python = {
          extension = "qmd",
          style = "quarto",
          force_ft = "quarto",
        },
        r = {
          extension = "qmd",
          style = "quarto",
          force_ft = "quarto",
        },
      },
    },
  },
}
