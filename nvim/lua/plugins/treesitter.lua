return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  opts = {
     highlight = {
      enable = true,
      additional_vim_regex_highlighting = false, -- disable regex highlight
    },
    indent = {
      enable = true,
    },
    ensure_installed = {
      'c',
      'css',
      'html',
      'javascript',
      'json',
      'lua',
      'scss',
      'typescript',
    },
    sync_install = false,
    auto_install = true -- automatically install missing parsers
  }
}
