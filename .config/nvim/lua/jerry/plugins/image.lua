return {
  {
    "vhyrro/luarocks.nvim",
    enabled = false, -- Set to true if you need to install 'magick' via luarocks
    priority = 1000,
    opts = {
      rocks = { "magick" },
    },
  },

  { -- show images in nvim!
    "3rd/image.nvim",
    enabled = false, -- Changed to true so you can actually see the images
    dev = false,
    ft = { "markdown", "quarto", "vimwiki", "codecompanion" },
    config = function()
      local image = require("image")
      image.setup({
        backend = "kitty",
        integrations = {
          markdown = {
            enabled = true,
            only_render_image_at_cursor = true,
            filetypes = { "markdown", "vimwiki", "quarto", "codecompanion" },
          },
        },
        editor_only_render_when_focused = false,
        window_overlap_clear_enabled = true,
        tmux_show_only_in_active_window = true,
        window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "scrollview", "scrollview_sign" },
        max_height_window_percentage = 30,
        kitty_method = "normal",
      })

      -- Keybinding to clear images
      vim.keymap.set("n", "<leader>ic", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local images = image.get_images({ buffer = bufnr })
        for _, img in ipairs(images) do
          img:clear()
        end
      end, { desc = "image [c]lear" })
    end,
  },

  { -- paste an image from the clipboard
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      default = {
        dir_path = "img",
        extension = "webp", -- Default for standard markdown
      },
      filetypes = {
        codecompanion = {
          extension = "png", -- Forces PNG for CodeCompanion
          prompt_for_file_name = false,
          process_cmd = "convert - png:-", -- Ensures conversion to PNG
          template = "[Image]($FILE_PATH)",
          use_absolute_path = true,
        },
        markdown = {
          url_encode_path = true,
          template = "![$CURSOR]($FILE_PATH)",
          drag_and_drop = {
            download_images = false,
          },
          process_cmd = "convert - -quality 75 webp:-",
        },
        quarto = {
          url_encode_path = true,
          template = "![$CURSOR]($FILE_PATH)",
          drag_and_drop = {
            download_images = false,
          },
          process_cmd = "convert - -quality 75 webp:-",
        },
      },
    },
    config = function(_, opts)
      require("img-clip").setup(opts)
      vim.keymap.set("n", "<leader>ip", ":PasteImage<cr>", { desc = "insert [i]mage from clipboard" })
    end,
  },
}
