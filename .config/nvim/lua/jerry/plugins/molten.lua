return {
  {
    "benlubas/molten-nvim",
    ft = { "markdown", "quarto", "latex", "ipynb" },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = "snacks.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_use_border_highlights = true
      vim.g.molten_wrap_output = true
      vim.g.molten_output_show_exec_time = true
      vim.g.molten_virt_text_output = true
      vim.g.python3_host_prog = vim.fn.expand("~/.virtualenvs/neovim/bin/python3")
    end,
    config = function()
      vim.keymap.set("n", "mi", ":MoltenInit<CR>", { silent = true, desc = "Initialize the plugin" })
      vim.keymap.set("n", "mj", ":MoltenNext<CR>", { silent = true, desc = "Molten Next" })
      vim.keymap.set("n", "mk", ":MoltenPrev<CR>", { silent = true, desc = "Molten Previous" })

      vim.keymap.set(
        "n",
        "<leader>mo",
        ":noautocmd MoltenEnterOutput<CR>:noautocmd MoltenEnterOutput<CR>",
        { silent = true, desc = "show/enter output" }
      )
    end,
  },

  -- Define the NewNotebook command globally
  {
    "nvim-lua/plenary.nvim", -- Dummy plugin to anchor the global command
    lazy = false, -- always load
    config = function()
      local default_notebook = [[
  {
    "cells": [
     {
      "cell_type": "markdown",
      "metadata": {},
      "source": [
        ""
      ]
     }
    ],
    "metadata": {
     "kernelspec": {
      "display_name": "Python 3",
      "language": "python",
      "name": "python3"
     },
     "language_info": {
      "codemirror_mode": {
        "name": "ipython"
      },
      "file_extension": ".py",
      "mimetype": "text/x-python",
      "name": "python",
      "nbconvert_exporter": "python",
      "pygments_lexer": "ipython3"
     }
    },
    "nbformat": 4,
    "nbformat_minor": 5
  }
]]

      local function new_notebook(filename)
        local path = filename .. ".ipynb"
        local file = io.open(path, "w")
        if file then
          file:write(default_notebook)
          file:close()
          vim.cmd("edit " .. path)
        else
          print("Error: Could not open new notebook file for writing.")
        end
      end

      vim.api.nvim_create_user_command("NewNotebook", function(opts)
        new_notebook(opts.args)
      end, {
        nargs = 1,
        complete = "file",
      })
    end,
  },
}
