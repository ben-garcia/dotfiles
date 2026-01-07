vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ruler  - bottom section that shows filename, etc
-- rulerformat - determines the content of the ruler
-- statusline
-- scrolloff - minimum amount of screen lines above and below the cursor
-- eventignore - list(,) of events to ignore when executing autocmds
vim.o.number = true -- line numbers
vim.o.relativenumber = true -- show line number relative with the cursor
vim.o.wrap = false -- don't wrap long lines
vim.o.splitright = true -- vsplit a new window on the right
vim.o.splitbelow = true -- split a new window on the bottom
vim.o.shiftwidth = 2 -- number of spaces to use for each step of indent (<<, >>)
vim.o.textwidth = 80 -- maximum length of each line. Excess is placed in new line
-- same as vim.opt.shada = { '\'0', '/0', ':0', '<0', '@0', 'f0', 's0' }
vim.o.shada = "'0,/0,:0,<0,@0,f0,s0" -- save the least
vim.o.completeopt = 'fuzzy,menu,noselect,popup'
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.autoindent = true
vim.o.mouse = '' -- disable the mouse
vim.o.mousescroll = 'ver:0,hor:0' -- disable mouse scrolling
