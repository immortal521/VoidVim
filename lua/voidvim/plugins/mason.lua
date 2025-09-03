return {
  {
    "mason-org/mason.nvim",
    opts = {
      max_concurrent_installers = 8,
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
        border = "single",
        width = 0.7,
        height = 0.7,
        backdrop = 80,
      },
    },
  },
}
