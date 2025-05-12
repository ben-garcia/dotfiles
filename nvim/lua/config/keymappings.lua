local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
local opts_noremap = { noremap = true }
local opts_silent = { silent = true }

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- copy & paste from system clipboard
map("v", "<leader>c", '"+y', opts)
map("n", "<leader>v", '"+p', opts)

-- splits
map("n", "<leader>sh", ":split<CR>", opts_noremap)
map("n", "<leader>sv", ":vsplit<CR>", opts_noremap)

-- horizontal resize
map("n", "<up>", ":resize +2<CR>", opts_noremap)
map("n", "<down>", ":resize -2<CR>", opts_noremap)

-- vertical resize
map("n", "<left>", ":vertical resize -2<CR>", opts_noremap)
map("n", "<right>", ":vertical resize +2<CR>", opts_noremap)

-- reset windows sizes
map("n", "<leader>=", "<C-w>=", opts_noremap)

-- move between panes
map("n", "<leader>h", ":wincmd h<cr>", opts_noremap)
map("n", "<leader>j", ":wincmd j<cr>", opts_noremap)
map("n", "<leader>k", ":wincmd k<cr>", opts_noremap)
map("n", "<leader>l", ":wincmd l<cr>", opts_noremap)

-- remove highlighted results
map("n", "<leader>a", ":nohl<cr>", opts_noremap)

-- formatting
map("n", "<leader>z", "<cmd>lua vim.lsp.buf.format()<CR>", opts_silent)

-- nvim tree
-- keymap is here because it's lazy loaded.
map("n", "<leader>w", ":NvimTreeToggle<CR>", opts)

-- lazy
map("n", "<leader>x", ":Lazy<CR>", opts)

-- mason
map("n", "<leader>m", ":Mason<CR>", opts)
