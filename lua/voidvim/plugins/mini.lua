return {
  { "nvim-mini/mini-git", version = false, main = "mini.git", opts = {} },
  { "nvim-mini/mini.move", version = false, opts = {} },
  { "nvim-mini/mini.ai", version = false, opts = {} },
  {
    "nvim-mini/mini.diff",
    event = "VeryLazy",
    version = false,
    keys = {
      {
        "<leader>go",
        function()
          require("mini.diff").toggle_overlay(0)
        end,
        desc = "Toggle mini.diff overlay",
      },
    },
    opts = {
      view = {
        style = "sign",
        signs = {
          add = "▎",
          change = "▎",
          delete = "",
        },
      },
    },
  },
  { "nvim-mini/mini.pairs", version = false, opts = {} },
  {
    "nvim-mini/mini.surround",
    version = false,
    opts = {
      mappings = {
        add = "gsa", -- Add surrounding in Normal and Visual modes
        delete = "gsd", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "gsh", -- Highlight surrounding
        replace = "gsr", -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`

        suffix_last = "l", -- Suffix to search with "prev" method
        suffix_next = "n", -- Suffix to search with "next" method
      },
    },
  },
  {
    "nvim-mini/mini.icons",
    version = false,
    opts = {
      style = "glyph",

      file = {
        README = { glyph = "󰆈", hl = "MiniIconsYellow" },
        ["README.md"] = { glyph = "󰆈", hl = "MiniIconsYellow" },
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
      },
      filetype = {
        bash = { glyph = "󱆃", hl = "MiniIconsGreen" },
        sh = { glyph = "󱆃", hl = "MiniIconsGrey" },
        toml = { glyph = "󱄽", hl = "MiniIconsOrange" },
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
}
