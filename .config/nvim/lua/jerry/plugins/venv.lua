return {
  "linux-cultist/venv-selector.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "nvim-telescope/telescope.nvim",
  },
  ft = { "quarto", "python" }, -- Activate for Python files
  branch = "regexp", -- This is the regexp branch, use this for the new version
  keys = {
    -- Keymap to open VenvSelector to pick a venv.
    { "<leader>vs", "<cmd>VenvSelect<cr>" },
    -- Keymap to retrieve the venv from a cache (the one previously used for the same project directory).
    { "<leader>vc", "<cmd>VenvSelectCached<cr>" },
  },
  config = function()
    require("venv-selector").setup({
      settings = {
        search = {
          -- Conda paths for macOS
          miniconda_base_mac = {
            command = "fd '/python$' /opt/homebrew/Caskroom/miniconda/base/bin --full-path --color never -E /proc",
            type = "Miniconda Base (macOS)",
          },
          miniconda_envs_mac = {
            command = "fd 'bin/python$' /opt/homebrew/Caskroom/miniconda/base/ --full-path --color never | grep '/envs/'",
            type = "Miniconda Envs (macOS)",
          },
          -- Conda paths for Arch Linux
          miniconda_base_arch = {
            command = "fd '/python$' /opt/miniconda3/bin --full-path --color never -E /proc",
            type = "Miniconda Base (Arch)",
          },
          miniconda_envs_arch = {
            command = "fd 'bin/python$' /opt/miniconda3/ --full-path --color never | grep '/envs/'",
            type = "Miniconda Envs (Arch)",
          },
        },
      },
    })
  end,
}
