return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("gitsigns").setup({
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]h", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end, { desc = "Next git hunk" })
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[h", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end, { desc = "Previous git hunk" })

        -- Actions
        map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Stage git hunk" })
        map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset git hunk" })
        map("v", "<leader>hs", function()
          gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Stage selected git hunk" })
        map("v", "<leader>hr", function()
          gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Reset selected git hunk" })
        map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Stage entire buffer" })
        map("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "Undo last staged hunk" })
        map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Reset entire buffer" })
        map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Preview git hunk" })
        map("n", "<leader>hb", function()
          gitsigns.blame_line({ full = true })
        end, { desc = "Show git blame for current line" })
        map("n", "<leader>hB", gitsigns.toggle_current_line_blame, { desc = "Toggle current line blame" })
        map("n", "<leader>hd", gitsigns.diffthis, { desc = "Diff current file" })
        map("n", "<leader>hD", function()
          gitsigns.diffthis("~")
        end, { desc = "Diff current file against HEAD" })
        map("n", "<leader>hT", gitsigns.toggle_deleted, { desc = "Toggle showing deleted lines" })

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select git hunk as text object" })
      end,
    })
  end,
}
