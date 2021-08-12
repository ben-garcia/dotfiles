local prettier = function()
  return {
    exe = "prettier",
    args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0), "--single-quote" },
    stdin = true,
  }
end

local USER = vim.fn.expand("$USER")

-- see https://github.com/johnnymorganz/stylua
local stylua = function()
  return {
    exe = "stylua",
    args = { "--config-path", "/home/" .. USER .. "/.config/stylua/stylua.toml" },
    stdin = false,
  }
end

require("formatter").setup({
  logging = false,
  filetype = {
    css = { prettier },
    html = { prettier },
    javascript = { prettier },
    lua = { stylua },
    markdown = { prettier },
    scss = { prettier },
    typescript = { prettier },
    typescriptreact = { prettier },
  },
})

vim.api.nvim_exec(
  [[
augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost *.css,*.scss,*.js,*.lua,*.md,*.ts,*.tsx FormatWrite
augroup END
]],
  true
)
