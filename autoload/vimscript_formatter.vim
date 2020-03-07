
let s:TEST_LOG = expand('<sfile>:h:h:gs?\?/?') . '/test.log'

function! vimscript_formatter#exec(q_args) abort
    let pos = getpos('.')
    let w0 = line('w0')
    let saved_indentexpr = &indentexpr
    try
        call vimscript_formatter#setlocal_indentexpr(1)
        silent! call feedkeys('gg=G', 'nx')
    finally
        let &indentexpr = saved_indentexpr
    endtry
    " for keeping the top position of current window.
    execute printf('%d', w0)
    call feedkeys("z\<cr>", 'xn')
    call setpos('.', pos)
endfunction

function! vimscript_formatter#indentexpr() abort
    return vimscript_formatter#internal#indentexpr()
endfunction

function! vimscript_formatter#setlocal_indentexpr(setting) abort
    if a:setting
        runtime! autoload/vimscript_formatter/internal.vim
        if exists('*vimscript_formatter#internal#indentexpr')
            setlocal indentexpr=vimscript_formatter#internal#indentexpr()
        endif
    endif
endfunction

function! vimscript_formatter#comp(ArgLead, CmdLine, CursorPos) abort
    return []
endfunction

function! vimscript_formatter#run_tests() abort
    if filereadable(s:TEST_LOG)
        call delete(s:TEST_LOG)
    endif

    let v:errors = []

    call vimscript_formatter#internal#run_tests()

    let lines = [
        \ 'try',
        \ 'if 1',
        \ 'while 1',
        \ 'echo 12',
        \ 'for i in [1,2,3]',
        \ 'echo 23',
        \ 'endfor',
        \ 'endwhile',
        \ 'echo 34',
        \ 'endif',
        \ 'catch',
        \ 'echo 45',
        \ 'finally',
        \ 'echo 56',
        \ 'endtry',
        \ 'augroup xxx',
        \ 'autocmd!',
        \ 'autocmd FileType vim',
        \ '    \ : if 1',
        \ '    \ |     echo 67',
        \ '    \ | else',
        \ '    \ |     echo 78',
        \ '    \ | endif',
        \ 'augroup END',
        \ ]

    try
        new
        setlocal filetype=vim
        let lnum = 0
        for line in lines
            let lnum += 1
            call setbufline(bufnr(), lnum, line)
        endfor
        VimscriptFormatter
        let formatted_lines = getbufline('%', 1, '$')
    finally
        bdelete!
    endtry

    call assert_equal(formatted_lines, [
        \ 'try',
        \ '    while 1',
        \ '        echo 12',
        \ '        for i in [1,2,3]',
        \ '            echo 23',
        \ '        endfor',
        \ '    endwhile',
        \ '    if 1',
        \ '        echo 34',
        \ '    endif',
        \ 'catch',
        \ '    echo 45',
        \ 'finally',
        \ '    echo 56',
        \ 'endtry',
        \ 'augroup xxx',
        \ '    autocmd!',
        \ '    autocmd FileType vim',
        \ '        \ : if 1',
        \ '        \ |     echo 76',
        \ '        \ | else',
        \ '        \ |     echo 78',
        \ '        \ | endif',
        \ 'augroup END',
        \ ])

    if !empty(v:errors)
        call writefile(v:errors, s:TEST_LOG)
        for err in v:errors
            echohl Error
            echo err
            echohl None
        endfor
    endif
endfunction

