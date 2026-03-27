return {
  "philosofonusus/ecolog.nvim",
  branch = "v1",
  event = "VeryLazy",
  keys = {
    { "<leader>vv", "<cmd>EcologShelterToggle<cr>", desc = "Toggle shelter" },
    { "<leader>vp", "<cmd>EcologShelterLinePeek<cr>", desc = "Peek line value" },
    { "<leader>ve", "<cmd>EcologSnacks<cr>", desc = "Browse env vars" },
    { "<leader>vk", "<cmd>EcologPeek<cr>", desc = "Peek var under cursor" },
    { "<leader>vy", "<cmd>EcologCopy<cr>", desc = "Copy var value" },
    { "<leader>vg", "<cmd>EcologGotoVar<cr>", desc = "Goto var definition" },
    { "<leader>vs", "<cmd>EcologSelect<cr>", desc = "Switch env file" },
  },
  opts = {
    shelter = {
      configuration = {
        mask_char = "*",
        partial_mode = false,
      },
      modules = {
        files = true,
        snacks_previewer = true,
        snacks = true, -- hides values in the picker list itself
        cmp = true,

        peek = true, -- hides values in the peek window
      },
    },
    integrations = {
      blink_cmp = true,

      snacks = {
        shelter = { mask_on_copy = true },
        keys = {
          copy_value = "<C-y>",
          copy_name = "<C-u>",
          append_value = "<C-a>",
          append_name = "<CR>",
          edit_var = "<C-e>",
        },
        layout = {
          preset = "dropdown",
          preview = false,
        },
      },
    },
    path = vim.fn.getcwd(),
  },
}
