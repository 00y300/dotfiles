return {
  {
    "akinsho/toggleterm.nvim",
    enabled = false,
    keys = {
      { "<leader>t", "<cmd>ToggleTerm<CR>", desc = "Toggle the terminal" },
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
    "mikavilpas/yazi.nvim",
    -- event = "VeryLazy",
    keys = {
      {
        -- Open in the current working directory
        "<leader>ty",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      },
    },
  },
}
