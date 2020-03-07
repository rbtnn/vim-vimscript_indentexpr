
let g:loaded_vimscript_formatter = 1

augroup vimscript_formatter
    autocmd!
    autocmd FileType vim :command! -buffer -nargs=? -complete=customlist,vimscript_formatter#comp  VimscriptFormatter :call vimscript_formatter#exec(<q-args>)
augroup END

if get(g:, 'vimscript_formatter_replace_indentexpr', 1)
    augroup vimscript_formatter-indentexpr
        autocmd!
        autocmd FileType vim :setlocal indentexpr=vimscript_formatter#internal#indentexpr()
    augroup END
endif
