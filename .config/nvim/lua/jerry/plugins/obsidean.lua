return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",
  },

  --KeyMaps
  vim.keymap.set("n", "<leader>ofl", "<cmd>ObsidianFollowLink<CR>", { desc = "Obsidian Follow Link" }),
  opts = {

    workspaces = {
      {
        name = "School",
        path = "~/Documents/School Vault/",
      },

      {
        name = "SB",
        path = "~/Documents/SB",
      },
    },
  },
}
