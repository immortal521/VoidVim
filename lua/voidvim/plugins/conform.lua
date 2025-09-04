vim.api.nvim_create_user_command("ConformDisable", function(args)
  if args.bang then
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = "Disable autoformat-on-save",
  bang = true,
})
vim.api.nvim_create_user_command("ConformEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = "Re-enable autoformat-on-save",
})

return {
  "stevearc/conform.nvim",
  init = function()
    vim.g.disable_autoformat = true
    vim.keymap.set("n", "<leader>ctf", function()
      if vim.g.disable_autoformat then
        vim.g.disable_autoformat = false
        vim.notify("Autoformat is enabled", vim.log.levels.INFO)
      else
        vim.g.disable_autoformat = true
        vim.notify("Autoformat is disabled", vim.log.levels.WARN)
      end
    end, { desc = "Toggle autoformatting" })
  end,
  event = { "BufWritePre", "InsertEnter" },
  cmd = { "ConformInfo", "FormatEnable", "FormatDisable" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      desc = "Format buffer",
    },
  },
  opts = {
    notify_on_error = true,
    format_after_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      return {
        timeout_ms = 5000,
        lsp_format = "fallback",
      }
    end,
    formatters_by_ft = {
      c = { "clang-format" },
      lua = { "stylua" },
      css = { "prettier" },
      go = { "goimports" },
      html = { "prettier" },
      java = { "google-java-format" },
      javascript = { "prettier" },
      json = { "prettier" },
      less = { "prettier" },
      nu = { "shfmt" },
      jsx = { "prettier" },
      cpp = function()
        if vim.fn.executable("lcg-clang-format-8.0.0") == 1 then
          return { "lcg_clang_format" }
        else
          return { "clang-format" }
        end
      end,
      python = { "yapf", "isort" },
      sh = { "shfmt" },
      snakemake = { "snakefmt" },
      markdown = { "prettierd", "cbfmt" },
      typst = { "typstyle" },
      nix = { "nixfmt" },
      toml = { "taplo" },
      tex = { "tex-fmt" },
      rust = { "rustfmt", lsp_format = "fallback" },
      scss = { "prettier" },
      svg = { "xmlformatter" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      vue = { "prettier" },
      xml = { "xmlformatter" },
      yml = { "prettier" },
      yaml = { "prettier" },
    },
    formatters = {
      injected = { options = { ignore_errors = true } },
      xmlformatter = {
        args = {
          "--indent",
          "2", -- 指定缩进
          "--infile",
          "$FILENAME", -- 输入文件名
        },
      },
      -- cbfmt = { command = 'cbfmt', args = { '-w', '--config', vim.fn.expand '~' .. '/.config/cbfmt.toml', '$FILENAME' } },
      -- taplo = { command = 'taplo', args = { 'fmt', '--option', 'indent_tables=false', '-' } },
      -- ruff_fix = {
      --   command = 'ruff',
      --   args = { 'check', '--select', 'I', '--fix', '--stdin-filename', '$FILENAME', '-' },
      --   stdin = true,
      -- },
      -- lcg_clang_format = { command = 'lcg-clang-format-8.0.0', args = { '$FILENAME' } }
    },
  },
}
