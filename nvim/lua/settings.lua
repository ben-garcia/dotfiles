-- vim settings

-- set the colorscheme
vim.cmd([[colorscheme onedark]])

-- global variables
local g = vim.g
local map = vim.api.nvim_set_keymap

-- map leader key to space
g.mapleader = " "
-- provide syntax highlighting
g.markdown_fenced_languages = {
  "html",
  "javascript",
  "typescript",
  "css",
  "scss",
}

-- general options
local opt = vim.opt
opt.backspace = { "indent", "eol", "start" }
opt.clipboard = "unnamedplus"
opt.completeopt = "menuone,noselect"
opt.cursorline = true
opt.encoding = "utf-8" -- Set default encoding to UTF-8
opt.expandtab = true -- Use spaces instead of tabs
opt.foldenable = false
opt.foldmethod = "indent"
opt.formatoptions = "l"
opt.hidden = true -- Enable background buffers
opt.hlsearch = true -- Highlight found searches
opt.ignorecase = true -- Ignore case
opt.inccommand = "split" -- Get a preview of replacements
opt.incsearch = true -- Shows the match while typing
opt.joinspaces = false -- No double spaces with join
opt.linebreak = true -- Stop words being broken on wrap
opt.list = false -- Show some invisible characters
opt.number = true -- Show line numbers
opt.numberwidth = 5 -- Make the gutter wider by default
opt.relativenumber = true
opt.scrolloff = 4 -- Lines of context
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
opt.showmode = false -- Don't display mode
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = "yes:1" -- always show signcolumns
opt.smartcase = true -- Do not ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.spelllang = "en"
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current
opt.tabstop = 2 -- Number of spaces tabs count for
opt.termguicolors = true -- You will have bad experience for diagnostic messages when it's default 4000.
opt.updatetime = 250 -- don't give |ins-completion-menu| messages.
opt.wrap = false

-- mappings

-- move between panes
map("n", "<leader>h", ":wincmd h<cr>", { noremap = true })
map("n", "<leader>j", ":wincmd j<cr>", { noremap = true })
map("n", "<leader>k", ":wincmd k<cr>", { noremap = true })
map("n", "<leader>l", ":wincmd l<cr>", { noremap = true })

-- lspsaga
-- not sure why they don't work in ./lua/saga/init.lua file
map("n", "<Leader>gf", ":Lspsaga lsp_finder<CR>", { silent = true })
map("n", "<leader>ga", ":Lspsaga code_action<CR>", { silent = true })
map("n", "<leader>gh", ":Lspsaga hover_doc<CR>", { silent = true })
map("n", "<leader>gk", '<cmd>lua require("lspsaga.action").smart_scroll_with_saga(1)<CR>', { silent = true })
map("n", "<leader>gj", '<cmd>lua require("lspsaga.action").smart_scroll_with_saga(-1)<CR>', { silent = true })
map("n", "<leader>gs", ":Lspsaga signature_help<CR>", { silent = true })
map("n", "<leader>gi", ":Lspsaga show_line_diagnostics<CR>", { silent = true })
map("n", "<leader>gn", ":Lspsaga diagnostic_jump_next<CR>", { silent = true })
map("n", "<leader>gp", ":Lspsaga diagnostic_jump_prev<CR>", { silent = true })
map("n", "<leader>gr", ":Lspsaga rename<CR>", { silent = true })
map("n", "<leader>gd", ":Lspsaga preview_definition<CR>", { silent = true })
map("n", "<leader>gD", "<cmd>lua vim.lsp.buf.definition()<CR>", { silent = true })
