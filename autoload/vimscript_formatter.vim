
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

    call s:run_test([
        \ 'try',
        \ 'echo 12',
        \ 'catch',
        \ 'echo 12',
        \ 'finally',
        \ 'echo 12',
        \ 'endtry',
        \ 'try',
        \ 'catch',
        \ 'finally',
        \ 'endtry',
        \ ], [
        \ 'try',
        \ '    echo 12',
        \ 'catch',
        \ '    echo 12',
        \ 'finally',
        \ '    echo 12',
        \ 'endtry',
        \ 'try',
        \ 'catch',
        \ 'finally',
        \ 'endtry',
        \ ])

    call s:run_test([
        \ 'if 1',
        \ 'echo 12',
        \ 'elseif 2',
        \ 'echo 12',
        \ 'else',
        \ 'echo 12',
        \ 'endif',
        \ 'if 1',
        \ 'elseif 2',
        \ 'else',
        \ 'endif',
        \ ], [
        \ 'if 1',
        \ '    echo 12',
        \ 'elseif 2',
        \ '    echo 12',
        \ 'else',
        \ '    echo 12',
        \ 'endif',
        \ 'if 1',
        \ 'elseif 2',
        \ 'else',
        \ 'endif',
        \ ])

    call s:run_test([
        \ 'while 1',
        \ 'echo 12',
        \ 'endwhile',
        \ 'while 1',
        \ 'endwhile',
        \ ], [
        \ 'while 1',
        \ '    echo 12',
        \ 'endwhile',
        \ 'while 1',
        \ 'endwhile',
        \ ])

    call s:run_test([
        \ 'for i in [1,2,3]',
        \ 'echo 12',
        \ 'endfor',
        \ 'for i in [1,2,3]',
        \ 'endfor',
        \ ], [
        \ 'for i in [1,2,3]',
        \ '    echo 12',
        \ 'endfor',
        \ 'for i in [1,2,3]',
        \ 'endfor',
        \ ])

    call s:run_test([
        \ 'def xxx',
        \ 'echo 12',
        \ 'enddef',
        \ 'def xxx',
        \ 'enddef',
        \ ], [
        \ 'def xxx',
        \ '    echo 12',
        \ 'enddef',
        \ 'def xxx',
        \ 'enddef',
        \ ])

    call s:run_test([
        \ 'augroup xxx',
        \ 'autocmd!',
        \ 'autocmd FileType vim',
        \ '\ : if 1',
        \ '\ |     echo 12',
        \ '\ | else',
        \ '\ |     echo 12',
        \ '\ | endif',
        \ 'augroup END',
        \ 'augroup xxx',
        \ 'augroup END',
        \ ], [
        \ 'augroup xxx',
        \ '    autocmd!',
        \ '    autocmd FileType vim',
        \ '        \ : if 1',
        \ '        \ |     echo 12',
        \ '        \ | else',
        \ '        \ |     echo 12',
        \ '        \ | endif',
        \ 'augroup END',
        \ 'augroup xxx',
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

function! s:run_test(actual, expect) abort
    try
        new
        setlocal filetype=vim
        let lnum = 0
        for line in a:actual
            let lnum += 1
            call setbufline(bufnr(), lnum, line)
        endfor
        VimscriptFormatter
        let formatted_lines = getbufline('%', 1, '$')
    finally
        bdelete!
    endtry
    call assert_equal(formatted_lines, a:expect)
endfunction

