-- Just after a yank or deleting command
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.hl.on_yank()
  end,
  desc = 'Briefly highlight yanked text',
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function()
    local options = { noremap = true, silent = true }

    -- keymappings
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>ga', '<cmd>lua vim.lsp.buf.code_action()<cr>', options)
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>gd', '<cmd>lua vim.lsp.buf.definition()<cr>', options)
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>ge', '<cmd>lua vim.lsp.buf.rename()<cr>', options)
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>gf', '<cmd>lua vim.lsp.buf.format()<cr>', options)
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>gg', '<cmd>lua vim.diagnostic.open_float()<cr>', options)
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>gh', '<cmd>lua vim.lsp.buf.hover()<cr>', options)
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', options)
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>gl', '<cmd>lua vim.diagnostic.setloclist()<cr>', options)
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>gq', '<cmd>lua vim.diagnostic.setqflist()<cr>', options)
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>gr', '<cmd>lua vim.lsp.buf.references()<cr>', options)
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', options)
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>gt', '<cmd>lua vim.lsp.buf.type_definition()<cr>', options)
    vim.api.nvim_buf_set_keymap(0, 'n', 'K', ':Man <c-r><c-w><cr>',options)
  end,
  desc = 'After lsp client attaches to a buffer',
})
