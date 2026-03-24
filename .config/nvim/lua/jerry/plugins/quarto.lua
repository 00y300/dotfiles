return {
  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto", "markdown" },
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
      { "<leader>qc", "<cmd>QuartoSend<CR>", desc = "Quarto send cell" },
      { "<leader>qA", "<cmd>QuartoSendAbove<CR>", desc = "Quarto send cell and above" },
      { "<leader>qB", "<cmd>QuartoSendBelow<CR>", desc = "Quarto send below" },
      { "<leader>qa", "<cmd>QuartoSendAll<CR>", desc = "Quarto send all cells" },
      { "<leader>qp", "<cmd>QuartoPreview<CR>", desc = "Quarto Preview" },
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
