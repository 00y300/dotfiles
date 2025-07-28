return {
  "obsidian-nvim/obsidian.nvim",

  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  dependencies = { -- Required.
    -- "nvim-lua/plenary.nvim",
    "folke/snacks.nvim",
  },

  opts = {
    legacy_commands = false,
    picker = {
      name = "snacks.pick",
    },
    workspaces = {
      --[[ {
        name = "School",
        path = "~/Documents/School Vault/",
      }, ]]

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
          notes_subdir = "/Inbox/",
        },
      },
    },
  },

  keys = {

    { "<leader>o", "", desc = "+Obsidian" },
    { "<leader>ol", "<cmd>Obsidian link<CR>", desc = "Create Link (Obsidian)" },
    { "<leader>oO", "<cmd>Obsidian open<CR>", desc = "Open Obsidian" },
    { "<leader>of", "<cmd>Obsidian follow_link<CR>", desc = "Follow Link (Obsidian)" },
    { "<leader>on", "<cmd>Obsidian new<CR>", desc = "Create New Note (Obsidian)" },
    -- { "<leader>ot", "<cmd>Obsidian today<CR>", desc = "Open Today’s Note (Obsidian)" },
    { "<leader>ott", "<cmd>Obsidian template<CR>", desc = "Applies Template to Note" },
    { "<leader>oy", "<cmd>Obsidian yesterday<CR>", desc = "Open Yesterday’s Note (Obsidian)" },
    { "<leader>os", "<cmd>Obsidian search<CR>", desc = "Search Notes (Obsidian)" },
    { "<leader>ob", "<cmd>Obsidian backlinks<CR>", desc = "Show Backlinks (Obsidian)" },
    { "<leader>ow", "<cmd>Obsidian workspace<CR>", desc = "Switch Workspace (Obsidian)" },

    -- Add a keybinding for moving the current file
    {
      "<leader>oz",
      function()
        local filepath = vim.fn.expand("%:p") -- Get the absolute path of the current file
        local filename = vim.fn.expand("%:t") -- Get the filename
        local target_dir = vim.fn.expand("~/Documents/ZK/Zettelkasten/") -- Expand the target directory
        local target_path = target_dir .. filename

        -- Ensure the target directory exists
        if vim.fn.isdirectory(target_dir) == 0 then
          vim.fn.mkdir(target_dir, "p") -- Create directory if it doesn't exist
        end

        -- Check if the file exists
        if vim.fn.filereadable(filepath) == 1 then
          -- Move the file
          local success, err = os.rename(filepath, target_path)
          if success then
            print("Moved " .. filename .. " to " .. target_dir)

            -- Reload the buffer with the new file location
            vim.cmd("edit " .. target_path)
          else
            print("Error moving file: " .. (err or "unknown error"))
          end
        else
          print("Error: File does not exist or is not readable.")
        end
      end,
      desc = "Move current file to ZK folder",
    },
  },
}
