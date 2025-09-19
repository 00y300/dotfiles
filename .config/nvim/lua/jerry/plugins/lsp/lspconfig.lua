-- Updated LSP configuration for Neovim 0.11+
-- Uses the new vim.lsp.enable() approach with blink.cmp integration

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },

  dependencies = {
    "saghen/blink.cmp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },

  config = function()
    -- 1) Reserve a space in the gutter (signcolumn) and define custom diagnostic icons
    vim.opt.signcolumn = "yes"
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.INFO] = " ",
          [vim.diagnostic.severity.HINT] = "󰠠 ",
        },
      },
    })

    -- 2) Get capabilities from blink.cmp instead of cmp_nvim_lsp
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    -- 3) Create an autocmd that runs whenever an LSP is actually attached to a buffer
    vim.api.nvim_create_autocmd("LspAttach", {
      desc = "LSP actions",
      callback = function(event)
        local opts = { buffer = event.buf, silent = true }

        -- Keybindings
        opts.desc = "See available code actions"
        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

        opts.desc = "Smart rename"
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        opts.desc = "Show line diagnostics"
        vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

        opts.desc = "Go to previous diagnostic"
        vim.keymap.set("n", "[d", function()
          vim.diagnostic.jump({ count = -1, float = true })
        end, opts)

        opts.desc = "Go to next diagnostic"
        vim.keymap.set("n", "]d", function()
          vim.diagnostic.jump({ count = 1, float = true })
        end, opts)

        opts.desc = "Show documentation for what is under cursor"
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

        opts.desc = "Restart LSP"
        vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
      end,
    })

    -- 4) Enable language servers using the new vim.lsp.enable() API with blink.cmp capabilities

    -- Nix language server
    vim.lsp.enable("nil_ls", {
      capabilities = capabilities,
    })

    -- Rust language server
    vim.lsp.enable("rust_analyzer")
    vim.lsp.config("rust_analyzer", {
      capabilities = capabilities,
      settings = {
        ["rust-analyzer"] = {
          checkOnSave = {
            allFeatures = true,
            overrideCommand = {
              "cargo",
              "clippy",
              "--workspace",
              "--message-format=json",
              "--all-targets",
              "--all-features",
            },
          },
        },
      },
    })

    -- Python language server
    vim.lsp.enable("pyright", {
      capabilities = capabilities,
    })

    -- Go language server
    vim.lsp.enable("gopls", {
      capabilities = capabilities,
    })

    -- C/C++ language server
    vim.lsp.enable("clangd", {
      capabilities = capabilities,
    })

    -- TypeScript/JavaScript language server

    vim.lsp.enable("ts_ls")
    -- Harper language server for markdown (ONLY for .md files)
    vim.lsp.enable("harper_ls")
    vim.lsp.config("harper_ls", {
      capabilities = capabilities,
      filetypes = { "markdown" },
      root_markers = {}, -- Remove .git root marker
      settings = {
        ["harper-ls"] = {
          userDictPath = "",
          fileDictPath = "",
          linters = {
            SpellCheck = true,
            SpelledNumbers = false,
            AnA = true,
            SentenceCapitalization = true,
            UnclosedQuotes = true,
            WrongQuotes = false,
            LongSentences = true,
            RepeatedWords = true,
            Spaces = true,
            Matcher = true,
            CorrectNumberSuffix = true,
          },
          codeActions = {
            ForceStable = false,
          },
          markdown = {
            IgnoreLinkTitle = false,
          },
          diagnosticSeverity = "hint",
          isolateEnglish = false,
          dialect = "American",
        },
      },
    })

    -- Lua language server
    vim.lsp.enable("lua_ls")
    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      settings = {
        Lua = {
          -- make the language server recognize the `vim` global
          diagnostics = {
            globals = { "vim" },
          },
          completion = {
            callSnippet = "Replace",
          },
        },
      },
    })

    -- TailwindCSS
    vim.lsp.enable("tailwindcss")
  end,
}
