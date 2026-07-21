return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  branch = "main",
  build = ":TSUpdate",
  config = function()
    vim.filetype.add({
      extension = { qmd = "quarto" },
    })
    vim.treesitter.language.register("markdown", "quarto")

    require("nvim-treesitter").setup()

    local ensure = {
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
    }
    require("nvim-treesitter").install(ensure)

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(event)
        local ok = pcall(vim.treesitter.start, event.buf)
        if ok then
          vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
