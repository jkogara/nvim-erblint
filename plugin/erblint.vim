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

" completion of options
let s:erblint_options = ['--autocorrect', '--enable-all-linters', '--enable-linters ']
function! s:ErblintOptions(...)
  return join(s:erblint_options, "\n")
endfunction

function! s:ErbLint(current_args)
  let l:filename = @%
  let l:erblint_cmd = 'erblint'
  let l:erblint_opts = ' ' . a:current_args

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
  let qflist = sort(qflist, "QflistCompare")
  call setqflist(qflist)

  copen
endfunction

function! QflistCompare(i1, i2)
  let [t1, t2] = [a:i1.lnum, a:i2.lnum]
   return t1 == t2 ? 0 : t1 > t2 ? 1 : -1
endfunc

command! -complete=custom,s:ErblintOptions -nargs=? ErbLint :call <SID>ErbLint(<q-args>)
"autocmd BufWritePost *.erb ErbLint

let &cpo = s:save_cpo
