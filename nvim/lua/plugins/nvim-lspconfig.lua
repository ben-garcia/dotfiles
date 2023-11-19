return {
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require("lspconfig")

    lspconfig.lua_ls.setup({
      settings = {
        Lua = {
          diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = { 'vim' },
          },
        },
      },
    })
    lspconfig.cssls.setup({})
    lspconfig.html.setup({})
    lspconfig.graphql.setup({})
    lspconfig.eslint.setup({})
    lspconfig.clangd.setup({})
    lspconfig.tsserver.setup({})
  end,
  event = "InsertEnter",
  dependencies = {
    "williamboman/mason.nvim",
    "onsails/lspkind-nvim",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "saadparwaiz1/cmp_luasnip",
    "L3MON4D3/LuaSnip",
  },
}
