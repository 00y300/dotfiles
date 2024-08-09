-- Set the map leader key
vim.g.mapleader = " "

-- Create a local variable for keymap for conciseness
local keymap = vim.keymap

-- Insert mode mappings
keymap.set("i", "<C-h>", "<Left>", { desc = "Move left in insert mode" })
keymap.set("i", "<C-j>", "<Down>", { desc = "Move down in insert mode" })
keymap.set("i", "<C-k>", "<Up>", { desc = "Move up in insert mode" })
keymap.set("i", "<C-l>", "<Right>", { desc = "Move right in insert mode" })
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- Command mode mappings
keymap.set("c", "<C-h>", "<Left>", { desc = "Move left in command mode" })
keymap.set("c", "<C-j>", "<Down>", { desc = "Move down in command mode" })
keymap.set("c", "<C-k>", "<Up>", { desc = "Move up in command mode" })
keymap.set("c", "<C-l>", "<Right>", { desc = "Move right in command mode" })

-- Normal mode mappings
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- Window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Tab management
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })
