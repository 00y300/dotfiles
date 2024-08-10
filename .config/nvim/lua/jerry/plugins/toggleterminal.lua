return {
  {
    "akinsho/toggleterm.nvim",
    keys = {
      { "<leader>t",  "<cmd>ToggleTerm<CR>",              desc = "Toggle the terminal" },
      { "<leader>tx", ":lua send_exit_to_terminal()<CR>", desc = "Send exit to the terminal" },
    },
    config = function()
      local toggleterm = require("toggleterm")
      toggleterm.setup({
        size = 12,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true, -- allow mappings in insert mode
        persist_size = true,
        direction = "horizontal",
        close_on_exit = true, -- ensures that the terminal is closed when you exit Neovim
        shell = vim.o.shell,
        on_open = function(term)
          vim.api.nvim_buf_set_keymap(term.bufnr, "t", "jk", "<C-\\><C-n>", { noremap = true, silent = true })
        end,
      })

      -- Define the function to send 'exit' command to the terminal
      function send_exit_to_terminal()
        local found_terminal = false
        -- Iterate through all buffers to find a terminal buffer
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[bufnr].buftype == "terminal" then
            found_terminal = true
            -- Send the 'exit' command followed by Enter to the terminal
            vim.api.nvim_chan_send(vim.b[bufnr].terminal_job_id, "exit\r")
            print("Sent exit command to terminal.")
            break
          end
        end
        if not found_terminal then
          vim.notify("No terminal available.", vim.log.levels.ERROR)
        end
      end
    end,
  },
  {
    "numToStr/FTerm.nvim",
    config = function()
      local fterm = require("FTerm")
      fterm.setup({
        border = "double",
        dimensions = {
          height = 0.45,
          width = 0.45,
        },
      })
      vim.keymap.set('n', '<A-i>', '<CMD>lua require("FTerm").toggle()<CR>', { desc = 'Toggle ON/OFF Floating Terminal' })
      vim.keymap.set('t', '<A-i>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>',
        { desc = 'Toggle ON/OFF Floating Terminal' })
      vim.keymap.set('t', '<A-x>', '<C-\\><C-n><CMD>lua require("FTerm").exit()<CR>', { desc = 'Kill Floating Terminal' })
    end,
  },
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>-",
        -- 👇 in this section, choose your own keymappings!
        desc = "Open yazi at the current file",
      },
      {
        -- Open in the current working directory
        "<leader>cw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      },
      {
        -- NOTE: this requires a version of yazi that includes
        -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
        "<c-up>",
        "<cmd>Yazi toggle<cr>",
        desc = "Resume the last yazi session",
      },
    },
  },
}
