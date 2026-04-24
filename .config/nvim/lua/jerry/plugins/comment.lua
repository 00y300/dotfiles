return {
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
  config = function()
    -- import comment plugin safely
    local comment = require("Comment")

    local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")

    -- enable comment
    comment.setup({
      -- for commenting tsx, jsx, svelte, html files
      pre_hook = ts_context_commentstring.create_pre_hook(),
    })

    -- ensure cuda filetype is recognized for .cu and .cuh files
    vim.api.nvim_create_autocmd("BufRead", {
      pattern = { "*.cu", "*.cuh" },
      callback = function()
        vim.bo.filetype = "cuda"
      end,
    })
  end,
}
