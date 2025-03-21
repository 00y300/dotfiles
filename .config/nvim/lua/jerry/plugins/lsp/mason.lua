return {
  {
    "williamboman/mason.nvim",
    opts = function()
      -- Your custom Mason configuration
      return {
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      }
    end,
  },
}
