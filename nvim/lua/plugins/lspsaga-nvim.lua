return {
  "tami5/lspsaga.nvim",
  event = "InsertEnter",
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
    "nvim-treesitter/nvim-treesitter",
  },
  keys = function()
    local map = vim.api.nvim_set_keymap
    local opts_silent = { silent = true }

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
  end,
}
