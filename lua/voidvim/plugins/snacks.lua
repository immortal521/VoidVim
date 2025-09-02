return {
  "folke/snacks.nvim",
  opts = {
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = false }, -- we set this in options.lua
    toggle = { map = VoidVim.safe_keymap_set },
    words = { enabled = true },
    dashboard = {
      preset = {
        -- pick = function(cmd, opts)
        --   return VoidVim.pick(cmd, opts)()
        -- end,
        header = [[
██╗   ██╗ ██████╗ ██╗██████╗ ██╗   ██╗██╗███╗   ███╗
██║   ██║██╔═══██╗██║██╔══██╗██║   ██║██║████╗ ████║
██║   ██║██║   ██║██║██║  ██║██║   ██║██║██╔████╔██║
╚██╗ ██╔╝██║   ██║██║██║  ██║╚██╗ ██╔╝██║██║╚██╔╝██║
 ╚████╔╝ ╚██████╔╝██║██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═══╝   ╚═════╝ ╚═╝╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]],
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "S", desc = "Select Session", action = ":lua require('persistence').select()" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = "0.5" },
        { section = "startup" },
      },
    },
  },
  keys = {
    {
      "<leader>n",
      function()
        if Snacks.config.picker and Snacks.config.picker.enabled then
          Snacks.picker.notifications()
        else
          Snacks.notifier.show_history()
        end
      end,
      desc = "Notification History",
    },
    {
      "<leader>un",
      function()
        Snacks.notifier.hide()
      end,
      desc = "Dismiss All Notifications",
    },
  },
}
