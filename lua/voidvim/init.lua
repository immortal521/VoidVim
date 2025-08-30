vim.uv = vim.uv or vim.loop

local M = {}

function M.setup(opts)
  require("voidvim.config").setup(opts)
end

return M
