return {
  "Zeioth/compiler.nvim",
  dependencies = {
    {
      "stevearc/overseer.nvim",
      "nvim-telescope/telescope.nvim",
      opts = {
        task_list = { -- Overseer.nvim specific configuration
          direction = "bottom",
          min_height = 25,
          max_height = 25,
          default_detail = 1,
          bindings = {
            ["q"] = function()
              vim.cmd("OverseerClose")
            end,
          },
        },
      },
    },
  },
  cmd = { "CompilerOpen", "CompilerToggleResults" },
  opts = {},
  keys = {
    { "mc", "<cmd>CompilerOpen<cr>", desc = "CompilerOpen" },
    { "mt", "<cmd>CompilerToggleResults<cr>", desc = "CompilerToggleResults" },
  },
}
