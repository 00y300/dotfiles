return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer", -- source for text in buffer
    "hrsh7th/cmp-path", -- source for file system paths
    {
      "L3MON4D3/LuaSnip",
      -- follow latest release.
      version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
      -- install jsregexp (optional!).
      build = "make install_jsregexp",
    },
    "saadparwaiz1/cmp_luasnip", -- for autocompletion
    "rafamadriz/friendly-snippets", -- useful snippets
    "onsails/lspkind.nvim", -- vs-code like pictograms
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")

    -- some shorthands...
    local s = luasnip.snippet
    local t = luasnip.text_node
    local i = luasnip.insert_node

    -- Snippet definitions for markdown and quarto files
    luasnip.add_snippets("markdown", {
      -- Bash code block snippet
      s("bash", {
        t("```bash"),
        t({ "", "" }),
        i(1),
        t({ "", "```" }),
      }),

      -- YAML code block snippet
      s("yaml", {
        t("```yaml"),
        t({ "", "" }),
        i(1),
        t({ "", "```" }),
      }),

      -- Javascript code block snippet
      s("javascript", {
        t("```javascript"),
        t({ "", "" }),
        i(1),
        t({ "", "```" }),
      }),

      -- Go code block snippet
      s("go", {
        t("```go"),
        t({ "", "" }),
        i(1),
        t({ "", "```" }),
      }),

      -- Rust code block snippet
      s("rust", {
        t("```rust"),
        t({ "", "" }),
        i(1),
        t({ "", "```" }),
      }),
      -- python code block snippet
      s("python", {
        t("```python"),
        t({ "", "" }),
        i(1),
        t({ "", "```" }),
      }),

      -- HTML code block snippet
      s("html", {
        t("```html"),
        t({ "", "" }),
        i(1),
        t({ "", "```" }),
      }),

      -- CSS code block snippet
      s("css", {
        t("```css"),
        t({ "", "" }),
        i(1),
        t({ "", "```" }),
      }),

      -- SQL code block snippet
      s("sql", {
        t("```sql"),
        t({ "", "" }),
        i(1),
        t({ "", "```" }),
      }),

      -- Chirpy tip snippet
      s("chirpy", {
        t({ "", "<!-- markdownlint-disable -->", "<!-- prettier-ignore-start -->", "" }),
        t("<!-- tip=green, info=blue, warning=yellow, danger=red -->"),
        t({ "", "> " }),
        i(1),
        t({ "", "{: .prompt-" }),
        i(2),
        t({ " }", "", "<!-- prettier-ignore-end -->", "<!-- markdownlint-restore -->" }),
      }),

      -- Markdownlint disable range snippet
      s("markdownlint", {
        t({ "", "<!-- markdownlint-disable -->", "" }),
        t("> "),
        i(1),
        t({ "", "<!-- markdownlint-restore -->" }),
      }),

      -- Regular link snippet
      s("link", {
        t("["),
        i(1, "text"),
        t("]("),
        i(2, "address"),
        t(")"),
      }),

      -- Link in new tab snippet
      s("linkt", {
        t("["),
        i(1, "link"),
        t("]("),
        i(2, "address"),
        t('){:target="_blank"}'),
      }),

      -- TODO item snippet
      s("todo", {
        t("<!-- TODO: "),
        i(1),
        t(" -->"),
      }),
    }, {
      key = "markdown",
    })

    -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      completion = {
        completeopt = "menu,menuone,preview,noselect",
      },
      snippet = { -- configure how nvim-cmp interacts with snippet engine
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
        ["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
        ["<C-e>"] = cmp.mapping.abort(), -- close completion window
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
      }),
      -- sources for autocompletion
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" }, -- snippets
        { name = "buffer" }, -- text within current buffer
        { name = "path" }, -- file system paths
        { name = "vim-dadbod-completion" }, -- SQL Autocompletion
        { name = "crates" },
        -- require("crates.completion.cmp").setup(),
      }),
      -- configure lspkind for vs-code like pictograms in completion menu
      formatting = {
        format = lspkind.cmp_format({
          maxwidth = 50,
          ellipsis_char = "...",
        }),
      },
    })
  end,
}
