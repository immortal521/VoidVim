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

local color_demo = {
  bg = "#222436",
  bg_dark = "#1e2030",
  bg_dark1 = "#191B29",
  bg_float = "#1e2030",
  bg_highlight = "#2f334d",
  bg_popup = "#1e2030",
  bg_search = "#3e68d7",
  bg_sidebar = "#1e2030",
  bg_statusline = "#1e2030",
  bg_visual = "#2d3f76",
  black = "#1b1d2b",
  blue = "#82aaff",
  blue0 = "#3e68d7",
  blue1 = "#65bcff",
  blue2 = "#0db9d7",
  blue5 = "#89ddff",
  blue6 = "#b4f9f8",
  blue7 = "#394b70",
  border = "#1b1d2b",
  border_highlight = "#589ed7",
  comment = "#636da6",
  cyan = "#86e1fc",
  dark3 = "#545c7e",
  dark5 = "#737aa2",
  diff = {
    add = "#273849",
    change = "#252a3f",
    delete = "#3a273a",
    text = "#394b70",
  },
  error = "#c53b53",
  fg = "#c8d3f5",
  fg_dark = "#828bb8",
  fg_float = "#c8d3f5",
  fg_gutter = "#3b4261",
  fg_sidebar = "#828bb8",
  git = {
    add = "#b8db87",
    change = "#7ca1f2",
    delete = "#e26a75",
    ignore = "#545c7e",
  },
  green = "#c3e88d",
  green1 = "#4fd6be",
  green2 = "#41a6b5",
  hint = "#4fd6be",
  info = "#0db9d7",
  magenta = "#c099ff",
  magenta2 = "#ff007c",
  none = "NONE",
  orange = "#ff966c",
  purple = "#fca7ea",
  rainbow = { "#82aaff", "#ffc777", "#c3e88d", "#4fd6be", "#c099ff", "#fca7ea", "#ff966c", "#ff757f" },
  red = "#ff757f",
  red1 = "#c53b53",
  teal = "#4fd6be",
  terminal = {
    black = "#1b1d2b",
    black_bright = "#444a73",
    blue = "#82aaff",
    blue_bright = "#9ab8ff",
    cyan = "#86e1fc",
    cyan_bright = "#b2ebff",
    green = "#c3e88d",
    green_bright = "#c7fb6d",
    magenta = "#c099ff",
    magenta_bright = "#caabff",
    red = "#ff757f",
    red_bright = "#ff8d94",
    white = "#828bb8",
    white_bright = "#c8d3f5",
    yellow = "#ffc777",
    yellow_bright = "#ffd8ab",
  },
  terminal_black = "#444a73",
  todo = "#82aaff",
  warning = "#ffc777",
  yellow = "#ffc777",
}

local mode_colors = {
  n = palette.blue,
  i = palette.green,
  v = palette.magenta,
  V = palette.magenta,
  ["\22"] = palette.magenta,
  c = palette.yellow,
  s = palette.yellow,
  S = palette.yellow,
  ["\19"] = palette.yellow,
  R = palette.teal,
  r = palette.teal,
  ["!"] = palette.red,
  t = palette.green,
  nt = palette.green,
}

local mode_names = {
  n = "NORMAL",
  v = "VISUAL",
  V = "VISUAL",
  ["\22"] = "\\",
  ["\22s"] = "\\",
  s = "SELECT",
  S = "SELECT",
  ["\19"] = "SELECT",
  i = "INSERT",
  R = "REPLACE",
  c = "COMMAND",
  cv = "Ex",
  r = "...",
  rm = "MORE",
  ["r?"] = "?",
  ["!"] = "!",
  t = "TERMINAL",
}

local get_mode_with_color = function(self)
  self.mode = vim.fn.mode(1)
  self.mode_color = mode_colors[self.mode:sub(1, 1)] or palette.blue
end

local M = {}

M.Spacer = { provider = " " }
M.Fill = { provider = "%=" }
M.Ruler = {
  provider = "%P  %(%l:%c%)",
}

M.Mode = {
  init = get_mode_with_color,
  provider = function(self)
    local mode_name = mode_names[self.mode:sub(1, 1)] or self.mode or "?"
    return " %1(" .. mode_name .. "%) "
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
  init = get_mode_with_color,
  provider = function()
    return "  " .. os.date("%H:%M") .. " " -- 在时间前加个图标
  end,
  hl = function(self)
    return { fg = palette.fg_gutter, bg = self.mode_color, bold = true }
  end,
}

M.Git = {
  condition = function()
    return vim.b.minigit_summary_string ~= nil
  end,
  provider = function()
    return vim.b.minigit_summary_string
  end,
  h1 = { fg = "orange", bold = true },
}

return M
