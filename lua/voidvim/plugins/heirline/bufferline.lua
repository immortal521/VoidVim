local components = require("voidvim.plugins.heirline.components")
local hUtils = require("heirline.utils")
local palette = require("tokyonight.colors").setup()

local BufferCloseButton = {
  condition = function(self)
    return not vim.api.nvim_get_option_value("modified", { buf = self.bufnr })
  end,
  { provider = " " },
  {
    provider = "✗ ",
    hl = function(self)
      return {
        fg = self.is_active and palette.blue or palette.comment,
        bold = self.is_active or self.is_visible,
        italic = self.is_active,
      }
    end,
    on_click = {
      callback = function(_, minwid)
        vim.schedule(function()
          vim.api.nvim_buf_delete(minwid, { force = false })
          vim.cmd.redrawtabline()
        end)
      end,
      minwid = function(self)
        return self.bufnr
      end,
      name = "heirline_tabline_close_buffer_callback",
    },
  },
}

local TablineBufferLeftIndicator = {
  provider = "┃ ",
  hl = function(self)
    if self.is_active then
      return { fg = palette.blue, bold = true }
    else
      return { fg = palette.bg_dark1, bold = false }
    end
  end,
}

local TablineFileNameBlock = vim.tbl_extend("force", components.FileNameBlock, {
  on_click = {
    callback = function(_, minwid, _, button)
      if button == "m" then -- close on mouse middle click
        vim.schedule(function()
          vim.api.nvim_buf_delete(minwid, { force = false })
        end)
      else
        vim.api.nvim_win_set_buf(0, minwid)
      end
    end,
    minwid = function(self)
      return self.bufnr
    end,
    name = "heirline_tabline_buffer_callback",
  },
})

local TablineBufferBlock = { TablineBufferLeftIndicator, TablineFileNameBlock, BufferCloseButton }

local BufferLine = hUtils.make_buflist(
  TablineBufferBlock,
  { provider = " ", hl = { fg = "gray" } }, -- left truncation, optional (defaults to "<")
  { provider = " ", hl = { fg = "gray" } } -- right trunctation, also optional (defaults to ...... yep, ">")
  -- by the way, open a lot of buffers and try clicking them ;)
)

local get_bufs = function()
  return vim.tbl_filter(function(bufnr)
    return vim.api.nvim_get_option_value("buflisted", { buf = bufnr })
  end, vim.api.nvim_list_bufs())
end

local buflist_cache = {}

vim.api.nvim_create_autocmd({ "UIEnter", "BufAdd", "BufDelete" }, {
  callback = function()
    vim.schedule(function()
      local buffers = get_bufs()
      for i, v in ipairs(buffers) do
        buflist_cache[i] = v
      end
      for i = #buffers + 1, #buflist_cache do
        buflist_cache[i] = nil
      end

      -- check how many buffers we have and set showtabline accordingly
      if #buflist_cache > 1 then
        vim.o.showtabline = 2 -- always
      elseif vim.o.showtabline ~= 1 then -- don't reset the option if it's already at default value
        vim.o.showtabline = 1 -- only when #tabpages > 1
      end
    end)
  end,
})

local TabLineOffset = {
  condition = function(self)
    local win = vim.api.nvim_tabpage_list_wins(0)[1]
    local bufnr = vim.api.nvim_win_get_buf(win)
    self.winid = win

    if vim.bo[bufnr].filetype == "neo-tree" then
      self.title = ""
      self.hl = { bg = palette.base }
      return true
      -- elseif vim.bo[bufnr].filetype == "TagBar" then
      --     ...
    end
  end,
  provider = function(self)
    local title = self.title
    local width = vim.api.nvim_win_get_width(self.winid)
    local pad = math.ceil((width - #title) / 2)
    return string.rep(" ", pad) .. title .. string.rep(" ", pad)
  end,

  hl = function(self)
    if vim.api.nvim_get_current_win() == self.winid then
      return "TablineSel"
    else
      return "Tabline"
    end
  end,
}

local Tabpage = {
  provider = function(self)
    return "%" .. self.tabnr .. "T " .. self.tabpage .. " %T"
  end,
  hl = function(self)
    if not self.is_active then
      return "TabLine"
    else
      return "TabLineSel"
    end
  end,
}

local TabpageClose = {
  provider = "%999X ✗ %X",
  hl = "TabLine",
}

local TabPages = {
  -- only show this component if there's 2 or more tabpages
  condition = function()
    return #vim.api.nvim_list_tabpages() >= 2
  end,
  { provider = "%=" },
  hUtils.make_tablist(Tabpage),
  TabpageClose,
}

return { TabLineOffset, BufferLine, TabPages }
