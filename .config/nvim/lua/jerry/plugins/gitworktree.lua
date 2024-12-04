return {
  "polarmutex/git-worktree.nvim",
  version = "^2",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  opts = {},
  config = function()
    -- Load Telescope extension for git worktree
    require("telescope").load_extension("git_worktree")

    -- Setup Git Worktree Hooks
    local Hooks = require("git-worktree.hooks")
    Hooks.register(Hooks.type.SWITCH, Hooks.builtins.update_current_buffer_on_switch)
  end,
  -- stylua: ignore
  keys = {
    -- {"<leader>gwm", function() require("telescope").extensions.git_worktree.git_worktrees() end, desc = "Manage Git Worktrees"},
    {"<leader>gwc", function() require("telescope").extensions.git_worktree.create_git_worktree() end, desc = "Create Git Worktree"},
    {"<leader>gwt", "<cmd>Telescope git_worktree<CR>", desc = "Open Git Worktree Telescope"}, -- Added keymap
  },
}
