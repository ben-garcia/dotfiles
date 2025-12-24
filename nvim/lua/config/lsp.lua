vim.lsp.enable({ 'clangd', 'cssls', 'eslint', 'lua_ls', 'stylua', 'stylelint_lsp', 'ts_ls' })

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.HINT] = '',
      [vim.diagnostic.severity.INFO] = '󰋼',
      [vim.diagnostic.severity.WARN] = '',
    },
  },
  virtual_text = {
    source = true,
  },
})
