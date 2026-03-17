return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  branch = "main",
  build = ":TSUpdate",
  config = function()
    vim.filetype.add({
      extension = {
        qmd = "quarto",
      },
    })
    vim.treesitter.language.register("markdown", "quarto")

    require("nvim-treesitter").setup({
      ensure_installed = {
        "json",
        "javascript",
        "typescript",
        "tsx",
        "yaml",
        "html",
        "css",
        "prisma",
        "markdown",
        "markdown_inline",
        "bash",
        "lua",
        "vim",
        "dockerfile",
        "gitignore",
        "query",
        "vimdoc",
        "nix",
        "c",
        "python",
        "latex",
        "java",
        "sql",
        "rust",
        "go",
        "elixir",
        "heex",
        "toml",
      },
      auto_install = true,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function(event)
        pcall(vim.treesitter.start, event.buf)
        vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
