--1. INSTALL packer: git clone https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
--2. INSTALL lua-language-server https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#sumneko_lua
-- confgiure -  'sumneko_root_path' and 'sumneko_binary'
-- optional - move 'lua-language-server' folder to .config/nvim
return require("packer").startup(function(use)
  -- Packer can manage itself
  use("wbthomason/packer.nvim")

  -- Color theme
  use("joshdick/onedark.vim")

  -- inproved syntax highlighting
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
  })
  use("neovim/nvim-lspconfig")
  -- neovim native lsp UI enhancements
  use("glepnir/lspsaga.nvim")
  -- auto completion
  use("hrsh7th/nvim-compe")
  -- fuzy finder & more
  use({
    "nvim-telescope/telescope.nvim",
    requires = { { "nvim-lua/plenary.nvim" } },
  })
  -- code formatter
  use("mhartington/formatter.nvim")
  -- file explorer
  use({
    "kyazdani42/nvim-tree.lua",
    requires = "kyazdani42/nvim-web-devicons",
  })
  -- statusline
  use({
    "hoob3rt/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons", opt = true },
  })
  -- comment
  use("b3nj5m1n/kommentary")
end)
