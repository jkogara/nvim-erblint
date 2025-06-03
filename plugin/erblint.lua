if vim.g.loaded_vim_erblint or vim.o.compatible then
  return
end
vim.g.loaded_vim_erblint = 1

local erblint = require('erblint')

vim.api.nvim_create_user_command('ErbLint', function(opts)
  erblint.run_erblint(opts.args)
end, {
  nargs = '?',
  complete = function(arg_lead, cmd_line, cursor_pos)
    return erblint.complete_options(arg_lead, cmd_line, cursor_pos)
  end
})