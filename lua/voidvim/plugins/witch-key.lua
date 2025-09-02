return {
  "folke/which-key.nvim",
  event = "VimEnter",
  opts_extend = { "spec" },
  opts = {
    preset = "helix",
    defaults = {},
    spec = {
      { "<leader>o", group = "Overseer", icon = "" },
      { "<leader>a", mode = "nxv", group = "Ai", icon = "" },
      { "<leader>c", group = "Code" },
      { "<leader>g", group = "Git" },
      { "<leader>f", group = "File or Find" },
      { "<leader>s", group = "Search" },
      { "<leader>q", group = "Quit or Session" },
      { "<leader><tab>", group = "Tabs" },
      { "<leader>x", group = "Diagnostics or Quickfix", icon = { icon = "󱖫 ", color = "green" } },
      { "<leader>t", mode = "n", group = "Terminal", icon = "" },
      { "[", group = "prev" },
      { "]", group = "next" },
      { "g", group = "goto" },
      { "gs", group = "surround" },
      { "z", group = "fold" },
      {
        "<leader>b",
        group = "Buffer",
        expand = function()
          return require("which-key.extras").expand.buf()
        end,
      },
      {
        "<leader>w",
        group = "windows",
        proxy = "<c-w>",
        expand = function()
          return require("which-key.extras").expand.win()
        end,
      },
      -- better descriptions
      { "gx", desc = "Open with system app" },
    },
    show_help = false,
  },
}
