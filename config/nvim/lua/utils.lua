-- helper functions

local M = {}

-- Checks whether the current working directory is an npm project.
M.is_npm_project = function()
  return vim.fn.filereadable('package.json') == 1
    and vim.fn.isdirectory('node_modules')
    -- both eslint 8 and eslint 9
    and (vim.fn.filereadable('.eslintrc.js') or vim.fn.filereadable('eslint.config.js'))
end

-- Checks whether the cwd is a lua project
M.is_lua_project = function()
  -- enough for neovim's config files
  return vim.fn.isdirectory('lua') and vim.fn.filereadable('init.lua') and vim.fn.filereadable('.luacheck')
end

-- Check whether the cwd is a c project
M.is_c_project = function()
  return vim.fn.filereadable('.clang-tidy')
    and vim.fn.filereadable('Makefile')
    and vim.fn.isdirectory('include')
    and vim.fn.isdirectory('src')
end

-- Create a new quickfix list out of the output of an external command.
--
-- title - string title of the quickfix list window
-- efm - string errorformat
-- results - string[] output of an external command
--
-- return nothing
M.add_results_to_qflist = function(title, efm, results)
  vim.fn.setqflist({}, ' ', {
    efm = efm,
    lines = results,
    title = title,
  })

  vim.cmd('copen')
end

return M
