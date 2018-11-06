"  Vim plugin for "Shopify/erb-lint" 
" Author:    Takehru Katsuyama
" URL:       https://github.com/tkatsu/vim-erblint
" License:   MIT
" ----------------------------------------------------------------------------

if exists('g:loaded_vim_erblint') || &cp
  finish
endif
let g:loaded_vim_erblint = 1

" Disable 'Vi-compatible' temporarily
let s:save_cpo = &cpo
set cpo&vim

let s:sort_by_msg_option = '--sort-by-msg'
" completion of options
let s:erblint_options = ['--autocorrect', '--lint-all', '--enable-all-linters', '--enable-linters ', s:sort_by_msg_option]

function! s:ErblintOptions(...)
  return join(s:erblint_options, "\n")
endfunction

function! s:ErbLint(current_args)
  let l:filename = @%
  let l:erblint_cmd = 'erblint'
  if match(a:current_args, s:sort_by_msg_option) == -1 
    let l:erblint_opts = ' ' . a:current_args
    let s:sort_by_msg = 'false'
  else
    let l:erblint_opts = ' ' . substitute(a:current_args, s:sort_by_msg_option, '', 'g') 
    let s:sort_by_msg = 'true'
  endif

  let l:erblint_output = system(l:erblint_cmd . l:erblint_opts . ' ' . l:filename . ' 2> /dev/null')
  if !empty(matchstr(l:erblint_opts, '--autocorrect'))
    "Reload file if using auto correct
    edit
  endif

  let s:save_errorformat = &errorformat
  let &errorformat = '%-GLinting%.%#,%ZIn\ file:\ %f:%l,%E%m,%-G%.%#'
  cexpr l:erblint_output
  let &errorformat = s:save_errorformat

  " Change type of 'E' to empty.
  let qflist = getqflist()
  for i in qflist
     let i.type = substitute(i.type, 'E', '', '')
  endfor

  " sort by filename and line number or lint message
  let qflist = sort(qflist, "QflistCompare")
  call setqflist(qflist)
  copen
endfunction

function! QflistCompare(i1, i2)
  " 1'st  sort key is filename 
  let [f1, f2] = [a:i1.bufnr, a:i2.bufnr]

  " 2'nd  sort key is lint error message or line number
  if s:sort_by_msg == 'true'
    let [l1, l2] = [a:i1.text, a:i2.text]
  else
    let [l1, l2] = [a:i1.lnum, a:i2.lnum]
  end

  if f1 == f2
    return l1 == l2 ? 0 : l1 > l2 ? 1 : -1
  else
    return f1 == f2 ? 0 : f1 > f2 ? 1 : -1
  endif
endfunc

command! -complete=custom,s:ErblintOptions -nargs=? ErbLint :call <SID>ErbLint(<q-args>)
"autocmd BufWritePost *.erb ErbLint

let &cpo = s:save_cpo
