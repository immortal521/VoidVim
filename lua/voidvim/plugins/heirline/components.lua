local icons = VoidVim.config.icons

local conditions = require("heirline.conditions")
local hUtils = require("heirline.utils")
local palette = require("tokyonight.colors").setup()

local colors = {
  diag_warn = hUtils.get_highlight("DiagnosticWarn").fg,
  diag_error = hUtils.get_highlight("DiagnosticError").fg,
  diag_hint = hUtils.get_highlight("DiagnosticHint").fg,
  diag_info = hUtils.get_highlight("DiagnosticInfo").fg,
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
    return { bg = palette.fg_gutter, fg = self.mode_color }
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
    return " 󰘬 " .. (summary.head_name or "") .. " "
  end,
  hl = function(self)
    return { fg = self.mode_color, bg = palette.fg_gutter, bold = true }
  end,
}

M.GitDiff = {
  condition = function(self)
    self.status_dict = vim.b.minidiff_summary
    return self.status_dict ~= nil
  end,
  {
    condition = function(self)
      return self.status_dict.add > 0 or self.status_dict.change > 0 or self.status_dict.delete > 0
    end,
    {
      { provider = " │ " },
      {
        condition = function(self)
          return self.status_dict.add > 0
        end,
        provider = function(self)
          return " " .. self.status_dict.add .. " "
        end,
        hl = { fg = palette.git.add },
      },
      {
        condition = function(self)
          return self.status_dict.change > 0
        end,
        provider = function(self)
          return " " .. self.status_dict.change .. " "
        end,
        hl = { fg = palette.git.change },
      },
      {
        condition = function(self)
          return self.status_dict.delete > 0
        end,
        provider = function(self)
          return " " .. self.status_dict.delete .. " "
        end,
        hl = { fg = palette.git.delete },
      },
    },
  },
}

M.Diagnostic = {
  condition = conditions.has_diagnostics,
  static = {
    error_icon = icons.diagnostics.Error,
    warn_icon = icons.diagnostics.Warn,
    info_icon = icons.diagnostics.Info,
    hint_icon = icons.diagnostics.Hint,
  },
  init = function(self)
    self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
  end,
  update = { "DiagnosticChanged", "BufEnter" },
  { provider = " " },
  {
    provider = function(self)
      -- 0 is just another output, we can decide to print it or not!
      return self.errors > 0 and (self.error_icon .. self.errors .. " ")
    end,
    hl = { fg = colors.diag_error },
  },
  {
    provider = function(self)
      return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
    end,
    hl = { fg = colors.diag_warn },
  },
  {
    provider = function(self)
      return self.info > 0 and (self.info_icon .. self.info .. " ")
    end,
    hl = { fg = colors.diag_info },
  },
  {
    provider = function(self)
      return self.hints > 0 and (self.hint_icon .. self.hints)
    end,
    hl = { fg = colors.diag_hint },
  },
  { provider = "│" },
}

M.Profile = {
  {
    provider = function()
      return require("noice").api.status.command.get()
    end,
    hl = { fg = palette.magenta },
  },
  { provider = " " },
}

M.StatusLine = {
  init = get_mode_with_color,
  M.Mode,
  M.GitBranch,
  M.Diagnostic,
  M.Fill,
  M.Profile,
  M.GitDiff,
  M.Ruler,
  M.Time,
}
-- local left_angle = ""
-- local right_angle = ""
--
-- M.SurroundedGitBranch = hUtils.surround({ right_angle, "" }, "blue", M.GitBranch)

return M
