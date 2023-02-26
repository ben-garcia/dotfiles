local opt = vim.opt

opt.backspace = { "indent", "eol", "start" }
opt.colorcolumn = "80" -- vertical line to indicate 80 characters
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
opt.laststatus = 3  -- enable global statusline
opt.linebreak = true -- Stop words being broken on wrap
opt.list = false -- Show some invisible characters
opt.number = true -- Show line numbers
opt.numberwidth = 4 -- Make the gutter wider by default
opt.relativenumber = true
opt.scrolloff = 4 -- scroll up or down when there are 4 lines
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
-- opt.shada = "" -- delete marks after restart
opt.showmode = false -- Don't display mode (lualine)
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
