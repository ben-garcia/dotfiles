return {
  "neovim/nvim-lspconfig",
  config = function()
    local lsp = vim.lsp

    lsp.config('lua_ls', {
      settings = {
        Lua = {
          diagnostics = {
            -- get the language server to recognize the `vim` global
            globals = { 'vim' },
          },
        },
      },
    })

    lsp.enable('clangd')
    lsp.enable('cssls')
    lsp.enable('eslint')
    lsp.enable('graphql')
    lsp.enable('html')
    lsp.enable('jsonls')
    lsp.enable('lua_ls')
    lsp.enable('stylelint_lsp')
    lsp.enable('ts_ls')
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
