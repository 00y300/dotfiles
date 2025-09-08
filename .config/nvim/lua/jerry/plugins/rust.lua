return {
  {
    -- This plugin is only for Rust files or directories with Cargo.toml
    "mrcjkb/rustaceanvim",
    version = "^6", -- Recommended
    enabled = false,
    lazy = false, -- This plugin is already lazy
    -- enabled = false,
    ft = { "rust" },
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
