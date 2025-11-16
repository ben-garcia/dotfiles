return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = true,
  event = {
    "BufReadPre", -- edit a new buffer.
    "BufNewFile"  -- edit a file that doesn't exist.
  },
  opts = {
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
    },
    ensure_installed = {
      "c",
      "css",
      "html",
      "javascript",
      "json",
      "lua",
      "scss",
      "tsx",
      "typescript",
    },
    sync_install = false,
  },
}
