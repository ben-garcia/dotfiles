require("nvim-treesitter.configs").setup({
	-- parsers
	ensure_installed = {
		"css",
		"html",
		"javascript",
		"json",
		"lua",
		"graphql",
		"scss",
		"tsx",
		"typescript",
	},
	sync_install = false,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	indent = {
		enable = true,
	},
})
