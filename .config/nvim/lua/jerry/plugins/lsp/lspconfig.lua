return {
  -- "dundalek/lazy-lsp.nvim",
  "VonHeikemen/lsp-zero.nvim",
  event = { "BufReadPre", "bufnewfile" },

  dependencies = {
    "neovim/nvim-lspconfig",
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },

  config = function()
    -- NOTE: to make any of this work you need a language server.
    -- If you don't know what that is, watch this 5 min video:
    -- https://www.youtube.com/watch?v=LaS32vctfOY

    -- 1) Reserve a space in the gutter (signcolumn) and define custom diagnostic icons
    vim.opt.signcolumn = "yes"
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- 2) Extend lspconfig’s default capabilities to include cmp_nvim_lsp
    local lspconfig = require("lspconfig")
    local lspconfig_defaults = lspconfig.util.default_config
    lspconfig_defaults.capabilities =
      vim.tbl_deep_extend("force", lspconfig_defaults.capabilities, require("cmp_nvim_lsp").default_capabilities())

    -- Save capabilities into a handy local variable:
    local capabilities = lspconfig_defaults.capabilities

    -- 3) Create an autocmd that runs whenever an LSP is actually attached to a buffer
    vim.api.nvim_create_autocmd("LspAttach", {
      desc = "LSP actions",
      callback = function(event)
        local opts = { buffer = event.buf, silent = true }

        -- Keybindings (converted from your old config):
        opts.desc = "Show LSP references"
        vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

        opts.desc = "Go to declaration"
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

        opts.desc = "Show LSP definitions"
        vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

        opts.desc = "Show LSP implementations"
        vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

        opts.desc = "Show LSP type definitions"
        vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

        opts.desc = "See available code actions"
        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

        opts.desc = "Smart rename"
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        opts.desc = "Show buffer diagnostics"
        vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

        opts.desc = "Show line diagnostics"
        vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

        opts.desc = "Go to previous diagnostic"
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

        opts.desc = "Go to next diagnostic"
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

        opts.desc = "Show documentation for what is under cursor"
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

        opts.desc = "Restart LSP"
        vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
      end,
    })

    -- 4) Example language servers.
    require("lspconfig").nil_ls.setup({})
    require("lspconfig").pyright.setup({})
    require("lspconfig").gopls.setup({})
    require("lspconfig").clangd.setup({})
    require("lspconfig").ts_ls.setup({})

    -- ADD YOUR LUA_LS SNIPPET HERE:
    lspconfig["lua_ls"].setup({
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

    -- 5) Completion (cmp) setup that includes the nvim_lsp source
    -- local cmp = require("cmp")
    -- cmp.setup({
    --   sources = {
    --     { name = "nvim_lsp" },
    --   },
    --   snippet = {
    --     expand = function(args)
    --       -- Requires Neovim v0.10+ for vim.snippet
    --       vim.snippet.expand(args.body)
    --     end,
    --   },
    --   mapping = cmp.mapping.preset.insert({}),
    -- })
  end,
}
--   config = function()
--     -- import lspconfig plugin
--     local lspconfig = require("lspconfig")
--
--     -- import mason_lspconfig plugin
--     -- local mason_lspconfig = require("mason-lspconfig")
--
--     -- import cmp-nvim-lsp plugin
--     local cmp_nvim_lsp = require("cmp_nvim_lsp")
--
--     local keymap = vim.keymap -- for conciseness
--
--     vim.api.nvim_create_autocmd("LspAttach", {
--       group = vim.api.nvim_create_augroup("UserLspConfig", {}),
--       callback = function(ev)
--         -- Buffer local mappings.
--         -- See `:help vim.lsp.*` for documentation on any of the below functions
--         local opts = { buffer = ev.buf, silent = true }
--
--         -- set keybinds
--         opts.desc = "Show LSP references"
--         keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references
--
--         opts.desc = "Go to declaration"
--         keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration
--
--         opts.desc = "Show LSP definitions"
--         keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions
--
--         opts.desc = "Show LSP implementations"
--         keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations
--
--         opts.desc = "Show LSP type definitions"
--         keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions
--
--         opts.desc = "See available code actions"
--         keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection
--
--         opts.desc = "Smart rename"
--         keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename
--
--         opts.desc = "Show buffer diagnostics"
--         keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show diagnostics for file
--
--         opts.desc = "Show line diagnostics"
--         keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line
--
--         opts.desc = "Go to previous diagnostic"
--         keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer
--
--         opts.desc = "Go to next diagnostic"
--         keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer
--
--         opts.desc = "Show documentation for what is under cursor"
--         keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor
--
--         opts.desc = "Restart LSP"
--         keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
--       end,
--     })
--
--     -- used to enable autocompletion (assign to every lsp server config)
--     local capabilities = cmp_nvim_lsp.default_capabilities()
--
--     -- Change the Diagnostic symbols in the sign column (gutter)
--     -- (not in youtube nvim video)
--     local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
--     for type, icon in pairs(signs) do
--       local hl = "DiagnosticSign" .. type
--       vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
--     end
--
--     -- mason_lspconfig.setup_handlers({
--     -- 	-- default handler for installed servers
--     -- 	function(server_name)
--     -- 		lspconfig[server_name].setup({
--     -- 			capabilities = capabilities,
--     -- 		})
--     -- 	end,
--     --
--     --
--
--     -- specific handler for lua_ls server
-- ["lua_ls"] = function()
-- 	lspconfig["lua_ls"].setup({
-- 		capabilities = capabilities,
-- 		settings = {
-- 			Lua = {
-- 				-- make the language server recognize "vim" global
-- 				diagnostics = {
-- 					globals = { "vim" },
-- 				},
-- 				completion = {
-- 					callSnippet = "Replace",
-- 				},
-- 			},
-- 		},
-- 	})
-- end,
--     -- })
--     require("lazy-lsp").setup({
--       -- By default all available servers are set up. Exclude unwanted or misbehaving servers.
--       excluded_servers = {
--         "ccls",
--         "zk",
--       },
--       -- Alternatively specify preferred servers for a filetype (others will be ignored).
--       preferred_servers = {
--         markdown = {},
--         python = { "pyright" },
--       },
--       prefer_local = true, -- Prefer locally installed servers over nix-shell
--       -- Default config passed to all servers to specify on_attach callback and other options.
--       default_config = {
--         flags = {
--           debounce_text_changes = 150,
--         },
--         -- on_attach = on_attach,
--         -- capabilities = capabilities,
--       },
--       -- Override config for specific servers that will passed down to lspconfig setup.
--       -- Note that the default_config will be merged with this specific configuration so you don't need to specify everything twice.
--       configs = {
--         lua_ls = {
--           settings = {
--             Lua = {
--               diagnostics = {
--                 -- Get the language server to recognize the `vim` global
--                 globals = { "vim" },
--               },
--             },
--           },
--         },
--       },
--     })
--   end,
-- }
