return require("packer").startup(function(use)
	use("wbthomason/packer.nvim") -- package manager

	use("kyazdani42/nvim-web-devicons") -- icons
	use("norcalli/nvim-colorizer.lua") -- color preview
	use("nvim-lualine/lualine.nvim")
	use("kyazdani42/nvim-tree.lua")
	use("lukas-reineke/indent-blankline.nvim")
	use("nvim-lua/plenary.nvim")
	use("nvim-telescope/telescope.nvim")
	use("numToStr/Comment.nvim") -- comment magic
	use("windwp/nvim-autopairs")

	-- colorschemes
	use("navarasu/onedark.nvim")

	-- treesitter
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })

	-- lsp
	use("neovim/nvim-lspconfig")
	use("jose-elias-alvarez/null-ls.nvim")
	use("williamboman/nvim-lsp-installer")
	use("tami5/lspsaga.nvim")
	use("onsails/lspkind-nvim")
	use("hrsh7th/nvim-cmp")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-nvim-lsp-signature-help")
	use("saadparwaiz1/cmp_luasnip")
	use("L3MON4D3/LuaSnip")
end)
