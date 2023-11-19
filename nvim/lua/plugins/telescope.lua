return {
  "nvim-telescope/telescope.nvim",
  lazy = true,
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local actions = require("telescope.actions")

    require("telescope").setup({
      defaults = {
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
        },
        prompt_prefix = "> ",
        selection_caret = "> ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "descending",
        layout_strategy = "horizontal",
        layout_config = {
          prompt_position = "top",
          preview_cutoff = 1, -- Preview should always show (unless previewer = false)
          horizontal = {
            preview_width = 0.5,
          },
        },
        file_sorter = require("telescope.sorters").get_fuzzy_file,
        file_ignore_patterns = { "node_modules" },
        generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
        winblend = 0,
        border = {},
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        color_devicons = true,
        use_less = false,
        path_display = {},
        set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
        mappings = {
          i = {
            -- close if esc key is pressed in insert mode
            ["<esc>"] = actions.close,
          },
        },
        -- Developer configurations: Not meant for general override
        buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
      },
    })

    local map = vim.api.nvim_set_keymap
    local opts_noremap = { noremap = true }

    map("n", "<leader>fb", ":Telescope buffers<CR>", opts_noremap)
    map("n", "<leader>ff", ":Telescope find_files<CR>", opts_noremap)
    map("n", "<leader>fg", ":Telescope live_grep<CR>", opts_noremap)
    map("n", "<leader>ft", ":Telescope git_status<CR>", opts_noremap)
  end,
  keys = {
    "<leader>fb",
    "<leader>ff",
    "<leader>fg",
    "<leader>ft"
  },
}
