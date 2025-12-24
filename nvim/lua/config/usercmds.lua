local utils = require('utils')

vim.api.nvim_create_user_command('RunLinter', function()
  local is_npm_project = utils.is_npm_project()
  local is_lua_project = utils.is_lua_project()
  local is_c_project = utils.is_c_project()

  if not is_npm_project and not is_lua_project and not is_c_project then
    -- if not an npm project there is no point of running eslinto or luacheck
    vim.print('The current working directory is not an npm, lua, or c project')
    return
  end

  if is_npm_project then
    vim.fn.jobstart('npm run lint -- -f unix', {
      stdout_buffered = true,
      on_stdout = function(_, data, _)
        utils.add_results_to_qflist('Eslint results', '%f:%l:%c: %m', data)
      end,
    })
  elseif is_lua_project == 1 then
    vim.fn.jobstart('luacheck . -q --no-color', {
      stdout_buffered = true,
      on_stdout = function(_, data, _)
        utils.add_results_to_qflist('Luacheck results', '%f:%l:%c: %m', data)
      end,
    })
  elseif is_c_project == 1 then
    vim.fn.jobstart('clang-tidy --quiet --config-file=.clang-tidy include/* src/*', {
      stdout_buffered = true,
      on_stdout = function(_, data, _)
        utils.add_results_to_qflist('Clang-tidy results', '%f:%l:%c: %m', data)
      end,
    })
  end
end, {
  desc = 'Run linter and open results in a quickfix list',
})
