return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",
  },

  -- Replace the previous `ft` or `config` with this event key

  opts = {
    workspaces = {
      {
        name = "School",
        path = "~/Documents/School Vault/",
      },

      {
        name = "ZK",
        path = "~/Documents/ZK/",
        overrides = {
          disable_frontmatter = true,
          templates = {
            folder = "/Templates/",
            date_format = "%m-%d-%Y", -- MM-DD-YYYY format
            time_format = "%I:%M %p", -- 12-hour format with AM/PM
          },
          daily_notes = {
            folder = "/Journal",
            date_format = "%m-%d-%Y", -- MM-DD-YYYY format
            alias_format = "%B %-d, %Y",
          },
          new_notes_location = "/Inbox",
        },
      },

      {
        name = "SB",
        path = "~/Documents/SB",
      },
    },
  },

  keys = {

    { "<leader>o", "", desc = "+test" },
    { "<leader>ol", "<cmd>ObsidianLink<CR>", desc = "Create Link (Obsidian)" },
    { "<leader>of", "<cmd>ObsidianFollowLink<CR>", desc = "Follow Link (Obsidian)" },
    { "<leader>on", "<cmd>ObsidianNew<CR>", desc = "Create New Note (Obsidian)" },
    { "<leader>ot", "<cmd>ObsidianToday<CR>", desc = "Open Today’s Note (Obsidian)" },
    { "<leader>oy", "<cmd>ObsidianYesterday<CR>", desc = "Open Yesterday’s Note (Obsidian)" },
    { "<leader>os", "<cmd>ObsidianSearch<CR>", desc = "Search Notes (Obsidian)" },
    { "<leader>ob", "<cmd>ObsidianBacklinks<CR>", desc = "Show Backlinks (Obsidian)" },
    { "<leader>om", "<cmd>ObsidianMarkdown<CR>", desc = "Insert Markdown Link (Obsidian)" },
    { "<leader>ow", "<cmd>ObsidianWorkspace<CR>", desc = "Switch Workspace (Obsidian)" },
    { "<leader>od", "<cmd>ObsidianDelete<CR>", desc = "Delete Note (Obsidian)" },
  },
}
