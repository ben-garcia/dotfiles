-- formatter
-- -- prevent any conflicts with telescope package
-- by adding the underscore
require("_formatter")

-- language server protocol
require("lsp")

-- statusline
require("_lualine")

-- run packer setup function with all plugins
require("plugins")

-- lspsaga
require("saga")

-- vim settings
require("settings")

-- telescope
-- prevent any conflicts with telescope package
-- by adding the underscore
require("_telescope")
--
-- nvim tree
require("tree")

-- treesitter configuration
require("treesitter")
