local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

local plugins = {
  "kyazdani42/nvim-web-devicons", -- icons
  "norcalli/nvim-colorizer.lua",  -- color preview
  "nvim-lualine/lualine.nvim",
  "kyazdani42/nvim-tree.lua",
  "lukas-reineke/indent-blankline.nvim",
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  "numToStr/Comment.nvim", -- comment magic
  "windwp/nvim-autopairs",

  -- colorschemes
  "navarasu/onedark.nvim",
  "ellisonleao/gruvbox.nvim",

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate"
  },

  -- lsp
  "neovim/nvim-lspconfig",
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",

  "tami5/lspsaga.nvim",
  "onsails/lspkind-nvim",
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-nvim-lsp-signature-help",
  "saadparwaiz1/cmp_luasnip",
  "L3MON4D3/LuaSnip",

  -- UI
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    }
  }
}

local options = {}

require("lazy").setup(plugins, options)
