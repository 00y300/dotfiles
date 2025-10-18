-- LLM Provider icons
local kind_icons = {
  claude = "󰋦",
  openai = "󱢆",
  codestral = "󱎥",
  gemini = "",
  Groq = "",
  Openrouter = "󱂇",
  Ollama = "󰳆",
  ["Llama.cpp"] = "󰳆",
  Deepseek = "",
}

local source_icons = {
  minuet = "󱗻",
  orgmode = "",
  otter = "󰼁",
  nvim_lsp = "",
  lsp = "",
  buffer = "",
  luasnip = "",
  snippets = "",
  path = "",
  git = "",
  tags = "",
  cmdline = "󰘳",
  latex_symbols = "",
  cmp_nvim_r = "󰟔",
  codeium = "󰩂",
  -- FALLBACK
  fallback = "󰜚",
}

return {
  "saghen/blink.cmp",
  dependencies = {
    "rafamadriz/friendly-snippets",
    "brenoprata10/nvim-highlight-colors", -- Add nvim-highlight-colors dependency
  },
  version = "1.*",
  opts = {
    appearance = {
      use_nvim_cmp_as_default = false,
      nerd_font_variant = "mono",
      kind_icons = kind_icons,
    },

    keymap = {
      preset = "default", -- disable default mappings
      --[[ ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide" },
      ["<C-y"] = { "accept", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      ["<Tab>"] = { "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "snippet_backward", "fallback" }, ]]
      ["<A-y>"] = {
        function(cmp)
          cmp.show({ providers = { "minuet" } })
        end,
      },
    },
    signature = { enabled = true },

    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      accept = {
        auto_brackets = { enabled = true },
      },
      trigger = { prefetch_on_insert = false },
      menu = {
        draw = {
          gap = 2,
          columns = {
            { "label", "label_description", gap = 1 },
            { "kind_icon", "kind" },
            { "source_icon" },
          },
          components = {
            kind_icon = {
              text = function(ctx)
                if require("blink.cmp.sources.lsp.hacks.tailwind").get_hex_color(ctx.item) then
                  return "󱓻 "
                end
                return ctx.kind_icon .. ctx.icon_gap
              end,
            },
            source_icon = {
              ellipsis = false,
              text = function(ctx)
                return source_icons[ctx.source_name:lower()] or source_icons.fallback
              end,
              highlight = "BlinkCmpSource",
            },
          },
        },
      },
    },

    sources = {
      -- default = { "lsp", "path", "snippets", "buffer", "minuet" },
      default = { "lsp", "path", "snippets", "buffer" },
      per_filetype = {
        sql = { "snippets", "dadbod", "buffer" },
      },
      providers = {
        dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
        minuet = {
          name = "minuet",
          module = "minuet.blink",
          async = true,
          timeout_ms = 3000,
          score_offset = 100,
        },
      },
    },

    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },

  config = function(_, opts)
    require("blink.cmp").setup(opts)

    -- nvim-highlight-colors setup
    require("nvim-highlight-colors").setup({
      render = "virtual",
      virtual_symbol = "󱓻",
      virtual_symbol_position = "inline",
      enable_hex = true,
      enable_short_hex = true,
      enable_rgb = true,
      enable_hsl = true,
      enable_ansi = true,
      enable_hsl_without_function = true,
      enable_var_usage = true,
      enable_named_colors = true,
      enable_tailwind = true,
    })
  end,
}
