return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  lazy = false, -- Keep false to ensure loading for Neo-tree
  main = 'nvim-treesitter.configs', -- Lazy handles the require logic here
  branch = 'master', -- Explicitly force the stable branch
  opts = {
    auto_install = true, -- automatically install missing parsers
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    disable = function(_, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
    ensure_installed = {
      'c',
      'css',
      'go',
      'html',
      'javascript',
      'json',
      'lua',
      'scss',
      'typescript',
    },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false, -- disable regex highlight
    },
    indent = {
      enable = true,
    },
    sync_install = false,
  },
  -- Fallback config to handle edge cases
  config = function(_, opts)
    -- Protective call: If treesitter fails to load, don't crash neovim
    local status_ok, configs = pcall(require, 'nvim-treesitter.configs')
    if not status_ok then
      return
    end
    configs.setup(opts)
  end,
}
