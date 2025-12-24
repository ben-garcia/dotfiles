vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.completeopt = 'fuzzy,menu,noselect,popup'
vim.o.expandtab = true -- use the appropriate number of spaces to insert a <Tab>
vim.o.mouse = '' -- disable the mouse
vim.o.mousescroll = 'ver:0,hor:0' -- disable mouse scrolling
vim.o.number = true -- line numbers
vim.o.relativenumber = true -- show line number relative with the cursor
vim.o.shada = "'0,/0,:0,<0,@0,f0,s0" -- save the least
vim.o.splitbelow = true -- split a new window on the bottom
vim.o.splitright = true -- vsplit a new window on the right
vim.o.shiftwidth = 2 -- number of spaces to use for each step of indent (<<, >>)
vim.o.softtabstop = 2 -- number of spaces that a <Tab> counts while performing editing like inserting
vim.o.tabstop = 2 -- number of spaces that a <Tab> in the file counts for
vim.o.textwidth = 80 -- maximum length of each line. Excess is placed in new line
vim.o.wrap = false -- don't wrap long lines
