return {
  "nvimdev/lspsaga.nvim",
  event = "LspAttach",
  opts = {
    debug = false,
    use_saga_diagnostic_sign = true,
    -- diagnostic sign
    error_sign = "",
    warn_sign = "",
    hint_sign = "",
    infor_sign = "",
    diagnostic_header_icon = "   ",
    -- code action title icon
    code_action_icon = " ",
    code_action_prompt = {
      enable = true,
      sign = true,
      sign_priority = 40,
      virtual_text = true,
    },
    finder_definition_icon = "  ",
    finder_reference_icon = "  ",
    max_preview_lines = 10,
    finder_action_keys = {
      open = "o",
      vsplit = "s",
      split = "i",
      quit = "q",
      scroll_down = "<C-f>",
      scroll_up = "<C-b>",
    },
    code_action_keys = {
      quit = "q",
      exec = "<CR>",
    },
    rename_action_keys = {
      quit = "<C-c>",
      exec = "<CR>",
    },
    definition_preview_icon = "  ",
    border_style = "single",
    rename_prompt_prefix = "➤",
    server_filetype_map = {},
    diagnostic_prefix_format = "%d. ",
  },
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  keys = function()
    local map = vim.api.nvim_set_keymap
    local opts = { silent = true }

    map("n", "<Leader>gf", ":Lspsaga finder<CR>", opts)
    map("n", "<Leader>go", ":Lspsaga outline<CR>", opts)
    map("n", "<leader>ga", ":Lspsaga code_action<CR>", opts)
    map("n", "<leader>gh", ":Lspsaga hover_doc<CR>", opts)
    map("n", "<leader>gi", ":Lspsaga show_line_diagnostics<CR>", opts)
    map("n", "<leader>gb", ":Lspsaga show_buf_diagnostics<CR>", opts)
    map("n", "<leader>gr", ":Lspsaga rename<CR>", opts)
    map("n", "<leader>gd", ":Lspsaga peek_definition<CR>", opts)
    map("n", "<leader>gD", ":Lspsaga goto_definition<CR>", opts)
  end,
}
