local LazyUtil = require("lazy.core.util")

---@class voidvim.util: LazyUtilCore
---@field config VoidVimConfig
---@field ui voidvim.util.ui
---@field plugin voidvim.util.plugin
---@field lsp voidvim.util.lsp
---@field root voidvim.util.root
---@field cmp voidvim.util.cmp
local M = {}

setmetatable(M, {
  __index = function(t, k)
    if LazyUtil[k] then
      return LazyUtil[k]
    end
    -- if k == "lazygit" or k == "toggle" then
    --   return M.deprecated[k]()
    -- end
    t[k] = require("voidvim.util." .. k)
    return t[k]
  end,
})

function M.is_win()
  return vim.uv.os_uname().sysname:find("Windows") ~= nil
end

---@param name string
function M.get_plugin(name)
  return require("lazy.core.config").spec.plugins[name]
end

---@param name string
---@param path string?
function M.get_plugin_path(name, path)
  local plugin = M.get_plugin(name)
  path = path and "/" .. path or ""
  return plugin and (plugin.dir .. path)
end

---@param plugin string
function M.has(plugin)
  return M.get_plugin(plugin) ~= nil
end

---@param fn fun()
function M.on_very_lazy(fn)
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      fn()
    end,
  })
end

--- 这个函数用于在表中，通过一个用点号分隔的字符串键，
--- 扩展（追加）一个深层嵌套的列表。
--- 如果对应的嵌套列表不存在，会自动创建。
---@generic T
---@param t T[]
---@param key string
---@param values T[]
---@return T[]?
function M.extend(t, key, values)
  local keys = vim.split(key, ".", { plain = true })
  for i = 1, #keys do
    local k = keys[i]
    t[k] = t[k] or {}
    if type(t) ~= "table" then
      return
    end
    t = t[k]
  end
  return vim.list_extend(t, values)
end

---@param name string
function M.opts(name)
  local plugin = M.get_plugin(name)
  if not plugin then
    return {}
  end
  local Plugin = require("lazy.core.plugin")
  return Plugin.values(plugin, "opts", false)
end

function M.deprecate(old, new)
  M.warn(("`%s` is deprecated. Please use `%s` instead"):format(old, new), {
    title = "Warning",
    once = true,
    stacktrace = true,
    stacklevel = 6,
  })
end

--- 延迟通知 直到 vim.notify 被替换 或 500ms 以后
function M.lazy_notify()
  local notifies = {}
  -- 定义一个临时函数 temp，用来收集消息/通知
  -- ... 表示可变参数，可以传任意数量的值
  local function temp(...)
    -- vim.F.pack_len(...) 会把参数打包成一个特殊的 table
    -- 例如: vim.F.pack_len("a", "b", "c")
    -- 结果是 { n = 3, "a", "b", "c" }
    -- 这样即使参数里有 nil 也不会丢失，因为 n 记录了参数个数
    table.insert(notifies, vim.F.pack_len(...))
  end

  local origin_notify = vim.notify
  vim.notify = temp

  local timer = vim.uv.new_timer()
  local check = assert(vim.uv.new_check())

  local function replay()
    timer:stop()
    check:stop()
    if vim.notify == temp then
      vim.notify = origin_notify
    end
    vim.schedule(function()
      --- @diagnostic disable-next-line: no-unknown
      for _, notify in ipairs(notifies) do
        vim.notify(vim.F.unpack_len(notify))
      end
    end)
  end

  check:start(function()
    if vim.notify ~= temp then
      replay()
    end
  end)

  timer:start(500, 0, replay)
end

function M.is_loaded(name)
  local Config = require("lazy.core.config")
  return Config.plugins[name] and Config.plugins[name]._.loaded
end

---@param name string
---@param fn fun(name:string)
function M.on_load(name, fn)
  if M.is_loaded(name) then
    fn(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          fn(name)
          return true
        end
      end,
    })
  end
end

-- 封装了 vim.keymap.set，只有当没有lazy keys handler 存在时才会创建一个新的键位映射。
-- 同时默认将 `silent` 设置为 true。
function M.safe_keymap_set(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  local modes = type(mode) == "string" and { mode } or mode

  ---@param m string
  -- 过滤出没有被 lazy keys handler 占用的模式
  modes = vim.tbl_filter(function(m)
    return not (keys.have and keys:have(lhs, m))
  end, modes)

  -- do not create the keymap if a lazy keys handler exists
  if #modes > 0 then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      ---@diagnostic disable-next-line: no-unknown
      opts.remap = nil
    end
    vim.keymap.set(modes, lhs, rhs, opts)
  end
end

---@generic T
---@param list T[]
---@return T[]
--- 去重
function M.dedup(list)
  local ret = {}
  local seen = {}
  for _, v in ipairs(list) do
    if not seen[v] then
      table.insert(ret, v)
      seen[v] = true
    end
  end
  return ret
end

-- 创建一个表示撤销操作的按键序列
M.CREATE_UNDO = vim.api.nvim_replace_termcodes("<c-G>u", true, true, true)

--- 创建一个撤销操作的函数
function M.create_undo()
  -- 判断当前是否在插入模式
  if vim.api.nvim_get_mode().mode == "i" then
    -- 如果是插入模式，模拟按下 <c-G>u 来触发撤销操作
    vim.api.nvim_feedkeys(M.CREATE_UNDO, "n", false)
  end
end

---@param pkg string
---@param path? string
---@param opts? { warn?: boolean }
function M.get_pkg_path(pkg, path, opts)
  pcall(require, "mason") -- make sure Mason is loaded. Will fail when generating docs
  local root = vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")
  opts = opts or {}
  opts.warn = opts.warn == nil and true or opts.warn
  path = path or ""
  local ret = vim.fs.normalize(root .. "/packages/" .. pkg .. "/" .. path)
  if opts.warn then
    vim.schedule(function()
      if not require("lazy.core.config").headless() and not vim.loop.fs_stat(ret) then
        M.warn(
          ("Mason package path not found for **%s**:\n- `%s`\nYou may need to force update the package."):format(
            pkg,
            path
          )
        )
      end
    end)
  end
  return ret
end

for _, level in ipairs({ "info", "warn", "error" }) do
  M[level] = function(msg, opts)
    opts = opts or {}
    opts.title = opts.title or "LazyVim"
    return LazyUtil[level](msg, opts)
  end
end

local cache = {} ---@type table<(fun()), table<string, any>>
---@generic T: fun()
---@param fn T
---@return T
function M.memoize(fn)
  return function(...)
    local key = vim.inspect({ ... })
    cache[fn] = cache[fn] or {}
    if cache[fn][key] == nil then
      cache[fn][key] = fn(...)
    end
    return cache[fn][key]
  end
end

return M
