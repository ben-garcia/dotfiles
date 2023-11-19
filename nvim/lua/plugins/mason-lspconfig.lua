return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = "williamboman/mason.nvim",
  event = "BufReadPre",
  opts = {
    ensure_installed = {
      "clangd",
      "cssls",
      "eslint",
      "html",
      "graphql",
      "jsonls",
      "lua_ls",
      "tsserver",
    },
    automatic_installation = true,
  },
}
