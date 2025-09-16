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
      local add = self.status_dict.add or 0
      local change = self.status_dict.change or 0
      local delete = self.status_dict.delete or 0
      return add > 0 or change > 0 or delete > 0
    end,
    {
      { provider = "│ " },
      {
        condition = function(self)
          return (self.status_dict.add or 0) > 0
        end,
        provider = function(self)
          return " " .. (self.status_dict.add or 0) .. " "
        end,
        hl = { fg = palette.git.add },
      },
      {
        condition = function(self)
          return (self.status_dict.change or 0) > 0
        end,
        provider = function(self)
          return " " .. (self.status_dict.change or 0) .. " "
        end,
        hl = { fg = palette.git.change },
      },
      {
        condition = function(self)
          return (self.status_dict.delete or 0) > 0
        end,
        provider = function(self)
          return " " .. (self.status_dict.delete or 0) .. " "
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

M.MacroRecording = {
  condition = conditions.is_active,
  init = function(self)
    self.reg_recording = vim.fn.reg_recording()
    self.status_dict = vim.b.gitsigns_status_dict or { added = 0, removed = 0, changed = 0 }
    self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
  end,
  {
    condition = function(self)
      return self.reg_recording ~= ""
    end,
    {
      provider = "󰻃 ",
      hl = { fg = palette.maroon },
    },
    {
      provider = function(self)
        return self.reg_recording
      end,
      hl = { fg = palette.maroon, italic = false, bold = true },
    },
    hl = { fg = palette.purple },
  },
  update = { "RecordingEnter", "RecordingLeave" },
} -- MacroRecording

M.Profile = {
  {
    provider = function()
      return require("noice").api.status.command.get()
    end,
    hl = { fg = palette.magenta },
  },
  { provider = " " },
}

M.FileIcon = {
  condition = function(self)
    return vim.fn.fnamemodify(self.filename, ":.") ~= ""
  end,
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ":e")
    local icon, hl, _ = require("mini.icons").get("file", "file." .. extension)
    local bt = vim.api.nvim_get_option_value("buftype", { buf = self.bufnr }) or nil
    if bt and bt == "terminal" then
      icon = ""
    end
    self.icon = icon
    self.icon_color = string.format("#%06x", vim.api.nvim_get_hl(0, { name = hl })["fg"])
  end,
  provider = function(self)
    return self.icon and (self.icon .. " ")
  end,
  hl = function(self)
    return { fg = self.icon_color }
  end,
}

M.FileName = {
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ":e")
    local _, hl, _ = require("mini.icons").get("file", "file." .. extension)
    self.icon_color = string.format("#%06x", vim.api.nvim_get_hl(0, { name = hl })["fg"])
  end,
  provider = function(self)
    -- self.filename will be defined later, just keep looking at the example!
    local filename = self.filename
    filename = filename == "" and vim.bo.filetype or vim.fn.fnamemodify(filename, ":t")
    return "" .. filename .. ""
  end,
  hl = function(self)
    return {
      fg = self.is_active and palette.blue or palette.comment,
      bold = self.is_active or self.is_visible,
      italic = self.is_active,
    }
  end,
}

-- we redefine the filename component, as we probably only want the tail and not the relative path
M.FilePath = {
  provider = function(self)
    local filename = vim.fn.fnamemodify(self.filename, ":.")
    if filename == "" then
      return vim.bo.filetype ~= "" and vim.bo.filetype or vim.bo.buftype
    end

    return filename
  end,
  hl = function(self)
    return {
      fg = self.is_active and palette.blue or palette.comment,
      bold = self.is_active or self.is_visible,
      italic = self.is_active,
    }
  end,
}

-- this looks exactly like the FileFlags component that we saw in
-- #crash-course-part-ii-filename-and-friends, but we are indexing the bufnr explicitly
-- also, we are adding a nice icon for terminal buffers.
M.FileFlags = {
  {
    init = function(self)
      local filename = self.filename
      local extension = vim.fn.fnamemodify(filename, ":e")
      local _, hl, _ = require("mini.icons").get("file", "file." .. extension)
      self.icon_color = string.format("#%06x", vim.api.nvim_get_hl(0, { name = hl })["fg"])
    end,
    condition = function(self)
      local ignored_filetypes = {
        "dap-repl",
      }
      local result = vim.fn.fnamemodify(self.filename, ":.") ~= ""
        and vim.api.nvim_get_option_value("modified", { buf = self.bufnr })
      local ft = vim.api.nvim_get_option_value("buftype", { buf = self.bufnr })
      if vim.tbl_contains(ignored_filetypes, ft) then
        result = false
      end
      return result
    end,
    provider = " ",
    hl = function(self)
      return { fg = self.icon_color, bold = self.is_active }
    end,
  },
  {
    condition = function(self)
      return not vim.api.nvim_get_option_value("modifiable", { buf = self.bufnr })
        or vim.api.nvim_get_option_value("readonly", { buf = self.bufnr })
    end,
    provider = function(self)
      if vim.api.nvim_get_option_value("buftype", { buf = self.bufnr }) == "terminal" then
        return ""
      else
        return " "
      end
    end,
    hl = { fg = palette.blue },
  },
}

M.FileNameBlock = {
  init = function(self)
    local bufnr = self.bufnr and self.bufnr or 0
    self.filename = vim.api.nvim_buf_get_name(bufnr)
  end,
  hl = { fg = palette.blue },
  M.FileIcon,
  M.FileName,
  M.FileFlags,
}

M.StatusLineFileNameBlock = {
  { provider = " " },
  M.FileNameBlock,
  { provider = " │" },
}

M.StatusLine = {
  init = get_mode_with_color,
  M.Mode,
  M.GitBranch,
  M.StatusLineFileNameBlock,
  M.Diagnostic,
  M.Fill,
  M.MacroRecording,
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
