return {
  'saghen/blink.cmp',
  event = 'InsertEnter',
  dependencies = {
    {
      'folke/lazydev.nvim',
      ft = 'lua', -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        },
      },
    },
  },
  version = '1.*',
  opts = {
    appearance = {
      nerd_font_variant = 'mono',
    },
    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
      },
      ghost_text = { enabled = true },
    },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
    keymap = {
      preset = 'default',
      ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
    },
    signature = { enabled = true },
    sources = {
      default = { 'lsp', 'path', 'buffer' },
    },
  },
  opts_extend = { 'sources.default' },
}
