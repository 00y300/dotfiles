return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod", lazy = true },
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true }, -- Optional
  },
  cmd = {
    "DBUI",
    "DBUIToggle",
    "DBUIAddConnection",
    "DBUIFindBuffer",
  },
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1
    -- Register key mappings for db Tools
    vim.keymap.set("n", "<leader>du", ":DBUIToggle<CR>", { desc = "DB UI Toggle", silent = true })
    vim.keymap.set("n", "<leader>df", ":DBUIFindBuffer<CR>", { desc = "DB UI Find buffer", silent = true })
    vim.keymap.set("n", "<leader>dr", ":DBUIRenameBuffer<CR>", { desc = "DB UI Rename buffer", silent = true })
    vim.keymap.set("n", "<leader>dl", ":DBUILastQueryInfo<CR>", { desc = "DB UI Last query infos", silent = true })
  end,
}
