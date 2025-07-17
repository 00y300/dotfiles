return {
  "goolord/alpha-nvim",
  enabled = false,
  event = "VimEnter",
  config = function()
    -- Define custom highlight groups
    vim.cmd([[
      highlight AlphaNeovimLogoBlue guifg=#5fafd7
      highlight AlphaNeovimLogoGreen guifg=#87af5f
      highlight AlphaNeovimLogoGreenFBlueB guifg=#87af5f guibg=#5fafd7
    ]])

    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Set new header
    local logo = {
      [[ ███       ███ ]],
      [[████      ████]],
      [[██████     █████]],
      [[███████    █████]],
      [[████████   █████]],
      [[█████████  █████]],
      [[█████ ████ █████]],
      [[█████  █████████]],
      [[█████   ████████]],
      [[█████    ███████]],
      [[█████     ██████]],
      [[████      ████]],
      [[ ███       ███ ]],
      [[                  ]],
      [[ N  E  O  V  I  M ]],
    }
    dashboard.section.header.val = logo
    dashboard.section.header.opts.hl = {
      {
        { "AlphaNeovimLogoBlue", 0, 0 },
        { "AlphaNeovimLogoGreen", 1, 14 },
        { "AlphaNeovimLogoBlue", 23, 34 },
      },
      {
        { "AlphaNeovimLogoBlue", 0, 2 },
        { "AlphaNeovimLogoGreenFBlueB", 2, 4 },
        { "AlphaNeovimLogoGreen", 4, 19 },
        { "AlphaNeovimLogoBlue", 27, 40 },
      },
      {
        { "AlphaNeovimLogoBlue", 0, 4 },
        { "AlphaNeovimLogoGreenFBlueB", 4, 7 },
        { "AlphaNeovimLogoGreen", 7, 22 },
        { "AlphaNeovimLogoBlue", 29, 42 },
      },
      {
        { "AlphaNeovimLogoBlue", 0, 8 },
        { "AlphaNeovimLogoGreenFBlueB", 8, 10 },
        { "AlphaNeovimLogoGreen", 10, 25 },
        { "AlphaNeovimLogoBlue", 31, 44 },
      },
      {
        { "AlphaNeovimLogoBlue", 0, 10 },
        { "AlphaNeovimLogoGreenFBlueB", 10, 13 },
        { "AlphaNeovimLogoGreen", 13, 28 },
        { "AlphaNeovimLogoBlue", 33, 46 },
      },
      {
        { "AlphaNeovimLogoBlue", 0, 13 },
        { "AlphaNeovimLogoGreen", 14, 31 },
        { "AlphaNeovimLogoBlue", 35, 49 },
      },
      {
        { "AlphaNeovimLogoBlue", 0, 13 },
        { "AlphaNeovimLogoGreen", 16, 32 },
        { "AlphaNeovimLogoBlue", 35, 49 },
      },
      {
        { "AlphaNeovimLogoBlue", 0, 13 },
        { "AlphaNeovimLogoGreen", 17, 33 },
        { "AlphaNeovimLogoBlue", 35, 49 },
      },
      {
        { "AlphaNeovimLogoBlue", 0, 13 },
        { "AlphaNeovimLogoGreen", 18, 34 },
        { "AlphaNeovimLogoGreenFBlueB", 33, 35 },
        { "AlphaNeovimLogoBlue", 35, 49 },
      },
      {
        { "AlphaNeovimLogoBlue", 0, 13 },
        { "AlphaNeovimLogoGreen", 19, 35 },
        { "AlphaNeovimLogoGreenFBlueB", 34, 35 },
        { "AlphaNeovimLogoBlue", 35, 49 },
      },
      {
        { "AlphaNeovimLogoBlue", 0, 13 },
        { "AlphaNeovimLogoGreen", 20, 36 },
        { "AlphaNeovimLogoGreenFBlueB", 35, 37 },
        { "AlphaNeovimLogoBlue", 37, 49 },
      },
      {
        { "AlphaNeovimLogoBlue", 0, 13 },
        { "AlphaNeovimLogoGreen", 21, 37 },
        { "AlphaNeovimLogoGreenFBlueB", 36, 37 },
        { "AlphaNeovimLogoBlue", 37, 49 },
      },
      {
        { "AlphaNeovimLogoBlue", 1, 13 },
        { "AlphaNeovimLogoGreen", 20, 35 },
        { "AlphaNeovimLogoBlue", 37, 48 },
      },
      {},
      { { "AlphaNeovimLogoGreen", 0, 9 }, { "AlphaNeovimLogoBlue", 9, 18 } },
    }

    -- Set menu
    dashboard.section.buttons.val = {
      dashboard.button("e", "  > New File", "<cmd>ene<CR>"),
      dashboard.button("SPC ee", "  > Toggle file explorer", "<cmd>NvimTreeToggle<CR>"),
      dashboard.button("SPC ff", "󰱼  > Find File", "<cmd>Telescope find_files<CR>"),
      dashboard.button("SPC fs", "  > Find Word", "<cmd>Telescope live_grep<CR>"),
      dashboard.button("SPC wr", "󰁯  > Restore Session For Current Directory", "<cmd>SessionRestore<CR>"),
      dashboard.button("q", "  > Quit NVIM", "<cmd>qa<CR>"),
    }

    -- Send config to alpha
    alpha.setup(dashboard.opts)

    -- Disable folding on alpha buffer
    vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
  end,
}
