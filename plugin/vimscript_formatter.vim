
let g:loaded_coloredit = 1

augroup vimscript_formatter
    autocmd!
    autocmd FileType vim :command! -buffer -nargs=? -complete=customlist,vimscript_formatter#comp  VimscriptFormatter :call vimscript_formatter#exec(<q-args>)
    autocmd FileType vim :call vimscript_formatter#setlocal_indentexpr(get(g:, 'vimscript_formatter_replace_indentexpr', 0))
augroup END
