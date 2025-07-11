return {
  "mrjones2014/smart-splits.nvim",
  lazy = false, -- Don't lazy load for tmux integration
  config = function()
    require("smart-splits").setup({
      -- Ignored buffer types (only while resizing)
      ignored_buftypes = {
        "nofile",
        "quickfix",
        "prompt",
      },
      -- Ignored filetypes (only while resizing)
      ignored_filetypes = { "NvimTree" },
      -- the default number of lines/columns to resize by at a time
      default_amount = 3,
      -- Desired behavior when your cursor is at an edge and you
      -- are moving towards that same edge:
      -- 'wrap' => Wrap to opposite side
      -- 'split' => Create a new split in the desired direction
      -- 'stop' => Do nothing
      at_edge = "edge",
      -- when moving cursor between splits left or right,
      -- place the cursor on the same row of the *screen*
      -- regardless of line numbers. False by default.
      move_cursor_same_row = false,
      -- whether the cursor should follow the buffer when swapping
      cursor_follows_swapped_bufs = false,
      -- enable or disable a multiplexer integration;
      -- automatically determined, unless explicitly disabled or set,
      -- by checking the $TERM_PROGRAM environment variable
      multiplexer_integration = "tmux",
      -- disable multiplexer navigation if current multiplexer pane is zoomed
      disable_multiplexer_nav_when_zoomed = true,
    })

    -- Key mappings
    local keymap = vim.keymap.set

    -- Moving between splits
    keymap("n", "<C-h>", require("smart-splits").move_cursor_left, { desc = "Move to left split" })
    keymap("n", "<C-j>", require("smart-splits").move_cursor_down, { desc = "Move to below split" })
    keymap("n", "<C-k>", require("smart-splits").move_cursor_up, { desc = "Move to above split" })
    keymap("n", "<C-l>", require("smart-splits").move_cursor_right, { desc = "Move to right split" })
    keymap("n", "<C-\\>", require("smart-splits").move_cursor_previous, { desc = "Move to previous split" })

    -- Swapping buffers between windows
    keymap("n", "<leader><leader>h", require("smart-splits").swap_buf_left, { desc = "Swap buffer left" })
    keymap("n", "<leader><leader>j", require("smart-splits").swap_buf_down, { desc = "Swap buffer down" })
    keymap("n", "<leader><leader>k", require("smart-splits").swap_buf_up, { desc = "Swap buffer up" })
    keymap("n", "<leader><leader>l", require("smart-splits").swap_buf_right, { desc = "Swap buffer right" })
  end,
}
