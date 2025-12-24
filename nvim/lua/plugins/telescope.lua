return {
  'nvim-telescope/telescope.nvim',
  config = function()
    local actions = require('telescope.actions')
    local builtin = require('telescope.builtin')

    require('telescope').setup({
      defaults = {
        layout_config = {
          height = 0.9,
          preview_cutoff = 80,
          prompt_position = 'top',
          horizontal = {
            preview_width = 0.5,
          },
        },
        mappings = {
          i = {
            ['<esc>'] = actions.close, -- close if esc key is pressed in insert mode
            ['<c-w>'] = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },
        sorting_strategy = 'ascending', -- as results filter out, list stays at the top
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
        },
      },
    })

    vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
  end,
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    '<leader>ff',
    '<leader>fg',
    '<leader>fb',
    '<leader>fh',
    '<leader>fs',
  },
  tag = 'v0.2.0',
}
