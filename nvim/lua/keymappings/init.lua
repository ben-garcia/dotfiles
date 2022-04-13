local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
local opts_noremap = { noremap = true }
local opts_silent = { silent = true }

vim.g.mapleader = " "

--- nvim tree
map("n", "<leader>w", ":NvimTreeToggle<CR>", opts)

-- open the 'shada' file
-- this file is used to store, among other things, marks
map("n", "<leader>ss", "<cmd>e ~/.local/share/nvim/shada/main.shada<CR>", opts_noremap)

-- split horizontal
map("n", "<leader>sh", ":split<CR>", opts_noremap)

-- split vertical
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

-- lspconfig
map("n", "<Leader>gf", ":Lspsaga lsp_finder<CR>", opts_silent)
map("n", "<leader>ga", ":Lspsaga code_action<CR>", opts_silent)
map("n", "<leader>gh", ":Lspsaga hover_doc<CR>", opts_silent)
map("n", "<leader>gk", '<cmd>lua require("lspsaga.action").smart_scroll_with_saga(1)<CR>', opts_silent)
map("n", "<leader>gj", '<cmd>lua require("lspsaga.action").smart_scroll_with_saga(-1)<CR>', opts_silent)
map("n", "<leader>gs", ":Lspsaga signature_help<CR>", opts_silent)
map("n", "<leader>gi", ":Lspsaga show_line_diagnostics<CR>", opts_silent)
map("n", "<leader>gn", ":Lspsaga diagnostic_jump_next<CR>", opts_silent)
map("n", "<leader>gp", ":Lspsaga diagnostic_jump_prev<CR>", opts_silent)
map("n", "<leader>gr", ":Lspsaga rename<CR>", opts_silent)
map("n", "<leader>gd", ":Lspsaga preview_definition<CR>", opts_silent)
map("n", "<leader>gD", "<cmd>lua vim.lsp.buf.definition()<CR>", opts_silent)

-- formatting
map("n", "<leader>z", "<cmd>lua vim.lsp.buf.formatting_sync()<CR>", opts_silent)

--- telescope
map("n", "<leader>ff", ":Telescope find_files<CR>", opts_noremap)
map("n", "<leader>fb", ":Telescope buffers<CR>", opts_noremap)
