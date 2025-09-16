return {
  "rebelot/heirline.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "echasnovski/mini.icons", opts = {} },
  },
  init = function()
    vim.keymap.set("n", "<leader>tt", function()
      vim.o.showtabline = vim.o.showtabline == 0 and 2 or 0
    end, { desc = "Toggle tabline" })
  end,
  config = function()
    vim.opt.cmdheight = 0
    require("heirline").setup({
      statusline = require("voidvim.plugins.heirline.statusline"),
      tabline = require("voidvim.plugins.heirline.bufferline"),
    })
  end,
}
