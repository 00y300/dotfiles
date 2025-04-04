vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.relativenumber = true
opt.number = true

-- tabs & indentation
local tabsize = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = tabsize
vim.opt.tabstop = tabsize

opt.wrap = false

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

opt.cursorline = true

-- turn on termguicolors for tokyonight colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false

-- Make the default terminal emulator for kitty
vim.g.terminal_emulator = "kitty"
vim.cmd('let $TERMINFO="/usr/share/terminfo"')

vim.keymap.set("n", "<c-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>")
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>")

-- Map Ctrl + h/j/k/l to navigate between splits in terminal mode
vim.api.nvim_set_keymap("t", "<C-h>", [[<C-\><C-n><C-w>h]], { noremap = true })
vim.api.nvim_set_keymap("t", "<C-j>", [[<C-\><C-n><C-w>j]], { noremap = true })
vim.api.nvim_set_keymap("t", "<C-k>", [[<C-\><C-n><C-w>k]], { noremap = true })
vim.api.nvim_set_keymap("t", "<C-l>", [[<C-\><C-n><C-w>l]], { noremap = true })

-- Obsidean Plugin Options
opt.conceallevel = 2

-- Spelling
opt.spelllang = "en_us"
opt.spell = false

-- Keybinding to toggle spell check on/off with F5, with a notification
vim.keymap.set("n", "<F5>", function()
  vim.opt.spell = not vim.opt.spell:get() -- toggle spell option
  if vim.opt.spell:get() then
    vim.notify("Spell Check: ON", vim.log.levels.INFO)
  else
    vim.notify("Spell Check: OFF", vim.log.levels.INFO)
  end
end)

-- Markdown-specific settings (wrap, linebreak, etc.)
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "markdown",
--   callback = function()
--     vim.opt_local.wrap = true
--     vim.opt_local.textwidth = 0
--     vim.opt_local.linebreak = true
--     vim.opt_local.breakat = [[\ \t!@*-+;:,./?]]
--   end,
-- })
