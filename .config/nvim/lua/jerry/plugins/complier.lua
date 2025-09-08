return {
  "stevearc/overseer.nvim",
  config = function()
    require("overseer").setup({
      dap = true,
    })
    -- Add keybinding for OverseerRun
    vim.keymap.set("n", "<leader>or", "<cmd>OverseerRun<CR>", { desc = "Run task" })
  end,
}
