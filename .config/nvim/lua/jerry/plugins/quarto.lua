-- Quarto and Otter setup
-- Neoovim Plugin Configuration
return {

  { -- requires plugins in lua/plugins/treesitter.lua and lua/plugins/lsp.lua
    -- for complete functionality (language features)
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
        default_method = "molten", -- Set molten as the default method
        ft_runners = { python = "molten" }, -- filetype to runner, ie. `{ python = "molten" }`
        never_run = { "yaml" }, -- filetypes which are never sent to a code runner
      },
    },
    dependencies = {
      "jmbuhr/otter.nvim",
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
      },
      -- "nvim-treesitter/nvim-treesitter",
    },

    vim.keymap.set("n", "<leader>oa", ":lua require'otter'.activate()<CR>", { desc = "Activate Otter", silent = true }),
    vim.keymap.set(
      "n",
      "<leader>ipc",
      "i```{python}<CR>```<esc>O",
      { desc = "Insert Python Code Chunk", silent = true }
    ),
    vim.keymap.set("n", "<leader>rc", ":QuartoSend<CR>", { desc = "Quarto send cell", silent = true }),
    vim.keymap.set("n", "<leader>rA", ":QuartoSendAbove<CR>", { desc = "Quarto send cell and above", silent = true }),
    vim.keymap.set("n", "<leader>rB", ":QuartoSendBelow<CR>", { desc = "Quarto send below", silent = true }),
    vim.keymap.set("n", "<leader>ra", ":QuartoSendAll<CR>", { desc = "Quarto send all cells", silent = true }),
    vim.keymap.set("n", "<leader>rp", ":QuartoPreview<CR>", { desc = "Quarto Preview", silent = true }),
  },

  { -- directly open ipynb files as quarto documents
    -- and convert back behind the scenes
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

  { -- paste an image from the clipboard or drag-and-drop
    "HakonHarnes/img-clip.nvim",
    event = "BufEnter",
    ft = { "markdown", "quarto", "latex" },
    opts = {
      default = {
        dir_path = "img",
        -- extension = "avif",
        -- process_cmd = "convert - -quality 75 avif:-", --@type string

        extension = "webp", ---@type string
        process_cmd = "convert - -quality 75 webp:-", ---@type string

        -- extension = "png", ---@type string
        -- process_cmd = "convert - -quality 75 png:-", ---@type string

        -- extension = "jpg", ---@type string
        -- process_cmd = "convert - -quality 75 jpg:-", ---@type string
      },
      filetypes = {
        markdown = {
          url_encode_path = true,
          template = "![$CURSOR]($FILE_PATH)",
          drag_and_drop = {
            download_images = false,
          },
        },
        quarto = {
          url_encode_path = true,
          template = "![$CURSOR]($FILE_PATH)",
          drag_and_drop = {
            download_images = false,
          },
        },
      },
    },
    config = function(_, opts)
      require("img-clip").setup(opts)
      vim.keymap.set("n", "<leader>ii", ":PasteImage<cr>", { desc = "insert [i]mage from clipboard" })
    end,
  },

  { -- preview equations
    "jbyuki/nabla.nvim",
    keys = {
      { "<leader>qm", ':lua require"nabla".toggle_virt()<cr>', desc = "toggle [m]ath equations" },
    },
  },
}
