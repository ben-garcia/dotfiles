require("mason").setup({
  ensure_installed = {
    "clangd",
    "cssls",
    "eslint",
    "graphql",
    "jsonls",
    "html",
    "lua_ls",
    "tsserver"
  },
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

require("mason-lspconfig").setup()

local lspconfig = require('lspconfig')
lspconfig.clangd.setup {}
lspconfig.lua_ls.setup {}
lspconfig.tsserver.setup {}
