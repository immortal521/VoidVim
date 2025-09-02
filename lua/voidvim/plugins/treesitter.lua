return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  lazy = false,
  build = ":TSUpdate",
  opts = {
    highlight = {
      enable = true,
    },
    auto_install = true,
    ensure_installed = {
      "lua",
    },
  },
}
