return {
  {
    -- This plugin is only for Rust files or directories with Cargo.toml
    "mrcjkb/rustaceanvim",
    version = "^6", -- Recommended
    -- enabled = false,
    lazy = false, -- This plugin is already lazy
    -- enabled = false,
    -- ft = { "rust" },
    config = function()
      vim.g.rustaceanvim = function()
        -- Try to get codelldb and liblldb from Nix store
        local ok, lldb_path = pcall(
          vim.fn.trim,
          vim.fn.system("nix eval --raw nixpkgs#vscode-extensions.vadimcn.vscode-lldb.outPath 2>/dev/null")
        )
        local extension_path, codelldb_path, liblldb_path
        local this_os = vim.uv.os_uname().sysname
        if ok and lldb_path ~= "" then
          extension_path = lldb_path .. "/share/vscode/extensions/vadimcn.vscode-lldb/"
          codelldb_path = extension_path .. "adapter/codelldb"
          liblldb_path = extension_path .. "lldb/lib/liblldb"
        else
          -- Fallback to ~/.vscode if nix path not found
          extension_path = vim.env.HOME .. "/.vscode/extensions/vadimcn.vscode-lldb-1.10.0/"
          codelldb_path = extension_path .. "adapter/codelldb"
          liblldb_path = extension_path .. "lldb/lib/liblldb"
        end
        -- Adjust paths depending on OS
        if this_os:find("Windows") then
          codelldb_path = extension_path .. "adapter\\codelldb.exe"
          liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
        else
          liblldb_path = liblldb_path .. (this_os == "Linux" and ".so" or ".dylib")
        end
        local cfg = require("rustaceanvim.config")
        return {
          dap = {
            adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
          },

          server = {
            on_attach = function(client, bufnr)
              -- Enable inlay hints for rust-analyzer
              if client.server_capabilities.inlayHintProvider then
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
              end

              -- Set inlay hint color to hsl(266deg, 85%, 58%)
              vim.api.nvim_set_hl(0, "LspInlayHint", {
                fg = "#ea76cb", -- Converted from
                italic = true,
              })
              -- you can also put other keymaps in here
            end,
            default_settings = {
              -- rust-analyzer language server configuration
              ["rust-analyzer"] = {
                cargo = {
                  allTargets = false,
                  buildScripts = { enable = true },
                  features = "all",
                },
                lru = {
                  capacity = 64,
                },
                procMacro = { enable = true },
                completion = {
                  autoimport = { enable = true },
                  autoself = { enable = true },
                  addSemicolonToUnit = true,
                  autoAwait = { enable = true },
                  autoIter = { enable = true },
                  callable = { snippets = "fill_arguments" },
                  postfix = { enable = true },
                },
                checkOnSave = {
                  enable = true,
                  command = "check",
                  allTargets = false,
                },
                inlayHints = {
                  typeHints = { enable = true },
                  parameterHints = { enable = true },
                  chainingHints = { enable = true },
                  closingBraceHints = { enable = true, minLines = 25 },
                  maxLength = 25,
                },
                hover = {
                  documentation = { enable = true },
                  links = { enable = true },
                  actions = { enable = true },
                },
                lens = {
                  enable = true,
                  implementations = { enable = true },
                  run = { enable = true },
                  updateTest = { enable = true },
                },
                diagnostics = {
                  enable = true,
                },
                rustfmt = {
                  extraArgs = { "--edition=2021" },
                },
              },
            },
          },
        }
      end
    end,
  },
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    config = function()
      require("crates").setup({
        lsp = {
          enabled = true,
          on_attach = function(client, bufnr)
            -- the same on_attach function as for your other lsp's
          end,
          actions = true,
          completion = true,
          hover = true,
        },
        -- completion = {
        --   cmp = {
        --     enabled = true,
        --   },
        -- },
      })
    end,
  },
}
