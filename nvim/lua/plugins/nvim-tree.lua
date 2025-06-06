return {
  "nvim-tree/nvim-tree.lua",
  config = function()
    vim.cmd([[hi NvimTreeNormal guibg=NONE ctermbg=None]])
    require("nvim-tree").setup({
      filters = {
        -- show hidden files
        dotfiles = false,
      },
      diagnostics = {
        enable = true,
      },
    })
  end,
  cmd = "NvimTreeToggle",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = true,
}
