
let g:loaded_vimscript_indentexpr = 1

augroup vimscript_indentexpr
    autocmd!
    autocmd FileType vim :setlocal indentexpr=vimscript_indentexpr#exec()
augroup END
