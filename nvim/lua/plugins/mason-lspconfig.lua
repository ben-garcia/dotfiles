return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = "williamboman/mason.nvim",
  event = "BufReadPre",
  opts = {
    ensure_installed = {
      "clangd",
      "cssls",
      "stylelint_lsp",
      "eslint",
      "html",
      "graphql",
      "jsonls",
      "lua_ls",
      "ts_ls",
    },
    automatic_installation = true,
  },
}
