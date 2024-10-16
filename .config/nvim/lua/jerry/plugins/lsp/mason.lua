return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    config = function(_, opts)
      local conf = vim.tbl_deep_extend("keep", opts, {
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })

      -- import mason
      require("mason").setup(conf)

      -- import mason-lspconfig
      require("mason-lspconfig").setup({
        -- list of servers for mason to install
        ensure_installed = {
          "ts_ls",
          "html",
          "cssls",
          "lua_ls",
          "pyright",
          "clangd",
          "neocmake",
          "sqls",
          "jsonls",
        },
      })

      -- import mason-tool-installer
      require("mason-tool-installer").setup({
        ensure_installed = {
          "prettier", -- prettier formatter
          "stylua", -- lua formatter
          "isort", -- python formatter
          "black", -- python formatter
          "pylint",
          "eslint_d",
          "clang-format",
          "trivy",
          "cmakelint", -- CMakeLinter
          "gersemi", -- CMakeFormatter
          "sqlfmt", -- SQL formater
        },
      })
    end,
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
    },
  },
}
