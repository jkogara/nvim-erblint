local M = {}

local sort_by_msg_option = "--sort-by-msg"
local erblint_options =
{ "--autocorrect", "--lint-all", "--enable-all-linters", "--enable-linters", sort_by_msg_option }

local function qflist_compare(sort_by_msg)
  return function(i1, i2)
    local f1, f2 = i1.bufnr, i2.bufnr

    local l1, l2
    if sort_by_msg then
      l1, l2 = i1.text, i2.text
    else
      l1, l2 = i1.lnum, i2.lnum
    end

    if f1 == f2 then
      if l1 == l2 then
        return 0
      else
        return l1 > l2 and 1 or -1
      end
    else
      return f1 > f2 and 1 or -1
    end
  end
end

function M.run_erblint(args)
  local filename = vim.fn.expand("%")
  local erblint_cmd = "erblint"

  local sort_by_msg = false
  local erblint_opts = ""

  if args and string.find(args, sort_by_msg_option) then
    sort_by_msg = true
    erblint_opts = string.gsub(args, sort_by_msg_option, "")
  else
    erblint_opts = args or ""
  end

  local fidget = require("fidget")
  local notify = require("notify")

  fidget.notify("Running erblint...", vim.log.levels.INFO)

  local cmd = erblint_cmd .. " " .. erblint_opts .. " " .. filename .. " 2> /dev/null"
  local erblint_output = vim.fn.system(cmd)

  if erblint_opts:find("--autocorrect") then
    vim.cmd("edit")
  end

  local save_errorformat = vim.o.errorformat
  vim.o.errorformat = "%-GLinting%.%#,%ZIn\\ file:\\ %f:%l,%E%m,%-G%.%#"
  vim.o.errorformat = save_errorformat
  local error_lines = vim.split(erblint_output, "\n")
  -- remove any empty error_lines
  for i = #error_lines, 1, -1 do
    if error_lines[i] == "" then
      table.remove(error_lines, i)
    end
  end

  local no_errors_found = false
  for _, item in ipairs(error_lines) do
    if item:find("No errors") then
      no_errors_found = true
      break
    end
  end

  if not no_errors_found then
    local messages = {}
    for _, item in ipairs(error_lines) do
      table.insert(messages, item)
    end
    notify(table.concat(messages, "\n"), vim.log.levels.ERROR, {
      title = "Erblint Results",
      timeout = 5000,
    })
  end
end

function M.complete_options(arg_lead, cmd_line, cursor_pos)
  return table.concat(erblint_options, "\n")
end

return M
