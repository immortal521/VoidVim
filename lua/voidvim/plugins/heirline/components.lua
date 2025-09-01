local icons = VoidVim.config.icons

local conditions = require("heirline.conditions")
local hUtils = require("heirline.utils")
local palette = require("tokyonight.colors").setup()

local colors = {
  diag_warn = hUtils.get_highlight("DiagnosticWarn").fg,
  diag_error = hUtils.get_highlight("DiagnosticError").fg,
  diag_hint = hUtils.get_highlight("DiagnosticHint").fg,
  diag_info = hUtils.get_highlight("DiagnosticInfo").fg,
  git_del = hUtils.get_highlight("diffDeleted").fg,
  git_add = hUtils.get_highlight("diffAdded").fg,
  git_change = hUtils.get_highlight("diffChanged").fg,
}

local modes = {
  n = { name = "NORMAL", color = palette.blue },
  v = { name = "VISUAL", color = palette.magenta },
  V = { name = "VISUAL", color = palette.magenta },
  ["\22"] = { name = "\\", color = palette.magenta },
  ["\22s"] = { name = "\\", color = palette.magenta },
  s = { name = "SELECT", color = palette.yellow },
  S = { name = "SELECT", color = palette.yellow },
  ["\19"] = { name = "SELECT", color = palette.yellow },
  i = { name = "INSERT", color = palette.green },
  R = { name = "REPLACE", color = palette.teal },
  c = { name = "COMMAND", color = palette.yellow },
  cv = { name = "Ex", color = palette.yellow },
  r = { name = "...", color = palette.teal },
  rm = { name = "MORE", color = palette.teal },
  ["r?"] = { name = "?", color = palette.teal },
  ["!"] = { name = "!", color = palette.red },
  t = { name = "TERMINAL", color = palette.green },
}

local get_mode_with_color = function(self)
  local m = vim.fn.mode(1):sub(1, 1)
  local mode = modes[m] or { name = m, color = palette.blue }
  self.mode_name, self.mode_color = mode.name, mode.color
end

local M = {}

M.Spacer = { provider = " " }
M.Fill = { provider = "%=" }
M.Ruler = {
  provider = " %P  %(%l:%c%) ",
  hl = function(self)
    return { bg = palette.fg_gutter, fg = self.mode_color, bold = true }
  end,
}

M.Mode = {
  provider = function(self)
    return " %1(" .. self.mode_name .. "%) "
  end,
  hl = function(self)
    return { fg = palette.fg_gutter, bg = self.mode_color, bold = true }
  end,
  update = {
    "ModeChanged",
    pattern = "*:*",
    callback = vim.schedule_wrap(function()
      pcall(vim.cmd, "redrawstatus")
    end),
  },
}

M.Time = {
  provider = function()
    return "  " .. os.date("%H:%M") .. " " -- 在时间前加个图标
  end,
  hl = function(self)
    return { fg = palette.fg_gutter, bg = self.mode_color, bold = true }
  end,
}

M.GitBranch = {
  condition = function()
    return vim.b.minigit_summary ~= nil
  end,
  provider = function()
    local summary = vim.b.minigit_summary or {}
    return "  " .. (summary.head_name or "") .. " "
  end,
  hl = function(self)
    return { fg = self.mode_color, bg = palette.fg_gutter, bold = true }
  end,
}

M.StatusLine = {
  init = get_mode_with_color,
  M.Mode,
  M.GitBranch,
  M.Fill,
  M.Ruler, 
  M.Time,
}
-- local left_angle = ""
-- local right_angle = ""
--
-- M.SurroundedGitBranch = hUtils.surround({ right_angle, "" }, "blue", M.GitBranch)

return M
