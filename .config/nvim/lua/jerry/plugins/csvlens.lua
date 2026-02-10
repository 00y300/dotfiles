return {
  "emmanueltouzery/decisive.nvim",
  lazy = true,
  ft = { "csv" },
  config = function()
    local notify = vim.notify

    vim.notify = function(_, _, _) end
    require("decisive").setup({})
    vim.notify = notify
  end,
  keys = {
    {
      "<leader>cca",
      function()
        local notify = vim.notify
        vim.notify = function() end
        require("decisive").align_csv({})
        vim.notify = notify
      end,
      desc = "Align CSV",
      mode = "n",
      silent = true,
    },
    {
      "<leader>ccc",
      function()
        local notify = vim.notify
        vim.notify = function() end
        require("decisive").align_csv_clear({})
        vim.notify = notify
      end,
      desc = "Align CSV clear",
      mode = "n",
      silent = true,
    },
    {
      "[c",
      function()
        local notify = vim.notify
        vim.notify = function() end
        require("decisive").align_csv_prev_col()
        vim.notify = notify
      end,
      desc = "Align CSV prev col",
      mode = "n",
      silent = true,
    },
    {
      "]c",
      function()
        local notify = vim.notify
        vim.notify = function() end
        require("decisive").align_csv_next_col()
        vim.notify = notify
      end,
      desc = "Align CSV next col",
      mode = "n",
      silent = true,
    },
  },
}
