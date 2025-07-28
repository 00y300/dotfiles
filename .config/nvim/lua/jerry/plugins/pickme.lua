return {
  "2KAbhishek/pickme.nvim",
  cmd = "PickMe",
  enabled = false,
  event = "VeryLazy",
  dependencies = {
    -- Include at least one of these pickers:
    "folke/snacks.nvim", -- For snacks.picker
    "nvim-telescope/telescope.nvim", -- For telescope
    -- 'ibhagwan/fzf-lua', -- For fzf-lua
  },
  opts = {
    picker_provider = "snacks", -- Default provider
    -- Auto-detect available picker providers (default: true)
    -- If the specified picker_provider is not available, will try to use one from provider_priority list
    detect_provider = true,

    -- Add default keybindings (default: true)
    -- See Keybindings section below for the full list of default keybindings
    add_default_keybindings = false,
  },
}
