return {
  "folke/todo-comments.nvim",
  version = "*",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local todo_comments = require("todo-comments")

    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    keymap.set("n", "]t", function()
      todo_comments.jump_next()
    end, { desc = "Next todo comment" })

    keymap.set("n", "<leader>ft", function()
      require("snacks").picker.todo_comments()
    end, { desc = "Find todo comments" })

    keymap.set("n", "<leader>fT", function()
      require("snacks").picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } })
    end, { desc = "Todo/Fix/Fixme" })

    keymap.set("n", "[t", function()
      todo_comments.jump_prev()
    end, { desc = "Previous todo comment" })

    todo_comments.setup()
  end,
}
