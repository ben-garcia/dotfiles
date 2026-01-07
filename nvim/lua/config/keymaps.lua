vim.keymap.set('n', '<leader>n', function() vim.cmd('Explore') end, { desc = 'Open the netrw browser' })
vim.keymap.set('n', '<leader>n', '<cmd>nohlsearch<cr>', { desc = 'Stop highlighting previous pattern match' })
vim.keymap.set('n', '<leader>r', '<cmd>RunLinter<cr>', { desc = 'Run Linter without blocking user interaction' })
vim.keymap.set('n', '<leader>q', '<cmd>close<cr>', { desc = 'Close the buffer' })

-- move between windows
vim.keymap.set('n', '<leader>h', '<c-w>h', { desc = 'Move focus to the window on the left' })
vim.keymap.set('n', '<leader>j', '<c-w>j', { desc = 'Move focus to the window on the bottom' })
vim.keymap.set('n', '<leader>k', '<c-w>k', { desc = 'Move focus to the window on the top' })
vim.keymap.set('n', '<leader>l', '<c-w>l', { desc = 'Move focus to the window on the right' })

-- move focused windows around
vim.keymap.set('n', '<leader>H', '<c-w>H', { desc = 'Move focused window to the left' })
vim.keymap.set('n', '<leader>J', '<c-w>J', { desc = 'Move focused window to the bottom' })
vim.keymap.set('n', '<leader>K', '<c-w>K', { desc = 'Move focused window to the top' })
vim.keymap.set('n', '<leader>L', '<c-w>L', { desc = 'Move focused window to the right' })

-- quickfix list
vim.keymap.set('n', '<leader>co', '<cmd>copen<cr>', { desc = 'Open the quickfix list' })
vim.keymap.set('n', '<leader>cc', '<cmd>cclose<cr>', { desc = 'Close the quickfix list' })
vim.keymap.set('n', '<leader>cp', '<cmd>colder<cr>', { desc = 'Go to the older quickfix list' })
vim.keymap.set('n', '<leader>cn', '<cmd>cnewer<cr>', { desc = 'Go to the newer quickfix list' })

-- location list
vim.keymap.set('n', '<leader>lo', '<cmd>lopen<cr>', { desc = 'Open the location list' })
vim.keymap.set('n', '<leader>lc', '<cmd>lclose<cr>', { desc = 'Close the location list' })
vim.keymap.set('n', '<leader>lp', '<cmd>lolder<cr>', { desc = 'Go to the older location list' })
vim.keymap.set('n', '<leader>ln', '<cmd>lnewer<cr>', { desc = 'Go to the newer location list' })
