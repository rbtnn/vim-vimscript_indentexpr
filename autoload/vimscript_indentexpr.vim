
let s:TEST_LOG = expand('<sfile>:h:h:gs?\?/?') . '/test.log'

let s:ENABLE_VIM9 = exists(':vim9script')

let s:TYPE_HEREDOC = 'TYPE_HEREDOC'
let s:TYPE_NORMAL = 'TYPE_NORMAL'
let s:TYPE_ONELINER = 'TYPE_ONELINER'
let s:TYPE_COMMENT = 'TYPE_COMMENT'
let s:TYPE_CONTINUOUS = 'TYPE_CONTINUOUS'
let s:TYPE_QUESTION = 'TYPE_QUESTION'
let s:TYPE_COLLON = 'TYPE_COLLON'
let s:TYPE_FINAL = 'TYPE_FINAL'
let s:TYPE_IF = 'TYPE_IF'
let s:TYPE_ELSEIF = 'TYPE_ELSEIF'
let s:TYPE_ELSE = 'TYPE_ELSE'
let s:TYPE_ENDIF = 'TYPE_ENDIF'
let s:TYPE_FOR = 'TYPE_FOR'
let s:TYPE_ENDFOR = 'TYPE_ENDFOR'
let s:TYPE_FUNCTION = 'TYPE_FUNCTION'
let s:TYPE_ENDFUNCTION = 'TYPE_ENDFUNCTION'
let s:TYPE_AUGROUP = 'TYPE_AUGROUP'
let s:TYPE_ENDAUGROUP = 'TYPE_ENDAUGROUP'
let s:TYPE_WHILE = 'TYPE_WHILE'
let s:TYPE_ENDWHILE = 'TYPE_ENDWHILE'
let s:TYPE_TRY = 'TYPE_TRY'
let s:TYPE_CATCH = 'TYPE_CATCH'
let s:TYPE_FINALLY = 'TYPE_FINALLY'
let s:TYPE_ENDTRY = 'TYPE_ENDTRY'
let s:TYPE_DEF = 'TYPE_DEF'
let s:TYPE_ENDDEF = 'TYPE_ENDDEF'
let s:TYPE_BLOCK = 'TYPE_BLOCK'
let s:TYPE_ENDBLOCK = 'TYPE_ENDBLOCK'

let s:CONTINUOUS_LIST = [
	\ s:TYPE_QUESTION,
	\ s:TYPE_COLLON,
	\ s:TYPE_CONTINUOUS,
	\ ]

let s:BEGIN_LIST = [
	\ s:TYPE_FUNCTION,
	\ s:TYPE_AUGROUP,
	\ s:TYPE_WHILE,
	\ s:TYPE_DEF,
	\ s:TYPE_FOR,
	\ s:TYPE_TRY,
	\ s:TYPE_FINALLY,
	\ s:TYPE_CATCH,
	\ s:TYPE_IF,
	\ s:TYPE_ELSE,
	\ s:TYPE_ELSEIF,
	\ s:TYPE_BLOCK,
	\ ]

let s:END_LIST = [
	\ s:TYPE_ENDFUNCTION,
	\ s:TYPE_ENDAUGROUP,
	\ s:TYPE_ENDWHILE,
	\ s:TYPE_ENDDEF,
	\ s:TYPE_ENDFOR,
	\ s:TYPE_FINALLY,
	\ s:TYPE_CATCH,
	\ s:TYPE_ENDTRY,
	\ s:TYPE_ENDIF,
	\ s:TYPE_ELSE,
	\ s:TYPE_ELSEIF,
	\ s:TYPE_ENDBLOCK,
	\ ]

function! vimscript_indentexpr#exec() abort
	return vimscript_indentexpr#sub(v:lnum)
endfunction

function! vimscript_indentexpr#sub(lnum) abort
	let curr_type = vimscript_indentexpr#get_type(getline(a:lnum), a:lnum)
	if 1 == a:lnum
		return 0
	elseif s:TYPE_HEREDOC == curr_type
		return -1
	else
		let prev_lnum = prevnonblank(a:lnum - 1)
		let prev_type = ''
		while 0 < prev_lnum
			let prev_type = vimscript_indentexpr#get_type(getline(prev_lnum), prev_lnum)
			if s:TYPE_HEREDOC == prev_type
				let prev_lnum = prevnonblank(prev_lnum - 1)
			else
				if -1 != index(s:CONTINUOUS_LIST, prev_type)
					let prev_lnum = prevnonblank(prev_lnum - 1)
				else
					break
				endif
			endif
		endwhile
		let n = indent(prev_lnum)
		if -1 != index(s:END_LIST, curr_type)
			if -1 == index(s:BEGIN_LIST, prev_type)
				let n -= shiftwidth()
			endif
		elseif -1 != index(s:CONTINUOUS_LIST, curr_type)
			let n += get(g:, 'vim_indent_cont', shiftwidth() * 3)
		else
			if -1 != index(s:BEGIN_LIST, prev_type)
				let n += shiftwidth()
			endif
		endif
		return n
	endif
endfunction

function! vimscript_indentexpr#get_type(line, lnum) abort
	let text = matchstr(a:line, '^\s*\(export\s\+\)\?\zs\S.*$')
	let t = s:TYPE_NORMAL
	if (-1 != a:lnum) && (-1 != index(['vimLetHereDoc', 'vimLetHereDocStop'], synIDattr(synID(a:lnum, 1, 1), 'name')))
		let t = s:TYPE_HEREDOC
	elseif text =~# '^"'
		let t = s:TYPE_COMMENT
	elseif s:ENABLE_VIM9 && (text =~# '^#')
		let t = s:TYPE_COMMENT
	elseif text =~# '^\\'
		let t = s:TYPE_CONTINUOUS
	elseif s:ENABLE_VIM9 && (text =~# '^\(+\|-\|*\|/\|%\|&&\|||\|\.\.\|->\|\.\)')
		let t = s:TYPE_CONTINUOUS
	elseif s:ENABLE_VIM9 && (text =~# '^{$')
		let t = s:TYPE_BLOCK
	elseif s:ENABLE_VIM9 && (text =~# '^}$')
		let t = s:TYPE_ENDBLOCK
	elseif s:ENABLE_VIM9 && (text =~# '^?')
		let t = s:TYPE_QUESTION
	elseif s:ENABLE_VIM9 && ((-1 != a:lnum) && (text =~# '^:') && (s:TYPE_QUESTION == vimscript_indentexpr#get_type(getline(a:lnum - 1), a:lnum - 1)))
		let t = s:TYPE_COLLON
	elseif text =~# '^\<if\>.*\<endi\%[f\]\>$'
		let t = s:TYPE_ONELINER
	elseif text =~# '^\<wh\%[ile\]\>.*\<endw\%[hile\]\>$'
		let t = s:TYPE_ONELINER
	elseif text =~# '^\<for\>.*\<endfo\%[r\]\>$'
		let t = s:TYPE_ONELINER
	elseif text =~# '^\<try\>.*\<endt\%[ry\]\>$'
		let t = s:TYPE_ONELINER
	elseif text =~# '^\<aug\%[roup\]\>!'
		let t = s:TYPE_ONELINER
	elseif text =~# '^\<if\>'
		let t = s:TYPE_IF
	elseif text =~# '^\<elsei\%[f\]\>'
		let t = s:TYPE_ELSEIF
	elseif text =~# '^\<el\%[se\]\>'
		let t = s:TYPE_ELSE
	elseif text =~# '^\<en\%[dif\]\>'
		let t = s:TYPE_ENDIF
	elseif text =~# '^\<for\>'
		let t = s:TYPE_FOR
	elseif text =~# '^\<endfo\%[r\]\>'
		let t = s:TYPE_ENDFOR
	elseif text =~# '^\<fu\%[nction\]\>'
		let t = s:TYPE_FUNCTION
	elseif text =~# '^\<endf\%[unction\]\>'
		let t = s:TYPE_ENDFUNCTION
	elseif text =~# '^\<aug\%[roup\]\>\s\+\<\cend\>'
		let t = s:TYPE_ENDAUGROUP
	elseif text =~# '^\<aug\%[roup\]\>'
		let t = s:TYPE_AUGROUP
	elseif text =~# '^\<wh\%[ile\]\>'
		let t = s:TYPE_WHILE
	elseif text =~# '^\<endw\%[hile\]\>'
		let t = s:TYPE_ENDWHILE
	elseif text =~# '^\<try\>'
		let t = s:TYPE_TRY
	elseif text =~# '^\<cat\%[ch\]\>'
		let t = s:TYPE_CATCH
	elseif s:ENABLE_VIM9 && (text =~# '^\<final\>')
		let t = s:TYPE_FINAL
	elseif text =~# '^\<fina\%[lly\]\>'
		let t = s:TYPE_FINALLY
	elseif text =~# '^\<endt\%[ry\]\>'
		let t = s:TYPE_ENDTRY
	elseif s:ENABLE_VIM9 && (text =~# '^\<enddef\>')
		let t = s:TYPE_ENDDEF
	elseif s:ENABLE_VIM9 && (text =~# '^\<def\>')
		let t = s:TYPE_DEF
	endif
	return t
endfunction

function! vimscript_indentexpr#run_tests() abort
	let saved = -1
	if exists('g:vim_indent_cont')
		let saved = g:vim_indent_cont
	endif
	try
		set nomore
		syntax on
		filetype plugin indent on

		if filereadable(s:TEST_LOG)
			call delete(s:TEST_LOG)
		endif

		let v:errors = []

		call assert_equal(vimscript_indentexpr#get_type('   if v:true | endif', -1), s:TYPE_ONELINER)
		call assert_equal(vimscript_indentexpr#get_type('   for i in [1,2,3] | endfor', -1), s:TYPE_ONELINER)
		call assert_equal(vimscript_indentexpr#get_type('   while v:true | endwhile', -1), s:TYPE_ONELINER)
		call assert_equal(vimscript_indentexpr#get_type('   try | catch | endtry', -1), s:TYPE_ONELINER)
		call assert_equal(vimscript_indentexpr#get_type('   "en', -1), s:TYPE_COMMENT)
		call assert_equal(vimscript_indentexpr#get_type('   \en', -1), s:TYPE_CONTINUOUS)
		call assert_equal(vimscript_indentexpr#get_type('   if v:true', -1), s:TYPE_IF)
		call assert_equal(vimscript_indentexpr#get_type('   elseif v:true', -1), s:TYPE_ELSEIF)
		call assert_equal(vimscript_indentexpr#get_type('   elsei v:true', -1), s:TYPE_ELSEIF)
		call assert_equal(vimscript_indentexpr#get_type('   else', -1), s:TYPE_ELSE)
		call assert_equal(vimscript_indentexpr#get_type('   el', -1), s:TYPE_ELSE)
		call assert_equal(vimscript_indentexpr#get_type('   endif', -1), s:TYPE_ENDIF)
		call assert_equal(vimscript_indentexpr#get_type('   en', -1), s:TYPE_ENDIF)
		call assert_equal(vimscript_indentexpr#get_type('   for', -1), s:TYPE_FOR)
		call assert_equal(vimscript_indentexpr#get_type('   endfor', -1), s:TYPE_ENDFOR)
		call assert_equal(vimscript_indentexpr#get_type('   endfo', -1), s:TYPE_ENDFOR)
		call assert_equal(vimscript_indentexpr#get_type('   function', -1), s:TYPE_FUNCTION)
		call assert_equal(vimscript_indentexpr#get_type('   fu', -1), s:TYPE_FUNCTION)
		call assert_equal(vimscript_indentexpr#get_type('   endfunction', -1), s:TYPE_ENDFUNCTION)
		call assert_equal(vimscript_indentexpr#get_type('   augroup', -1), s:TYPE_AUGROUP)
		call assert_equal(vimscript_indentexpr#get_type('   aug', -1), s:TYPE_AUGROUP)
		call assert_equal(vimscript_indentexpr#get_type('   augroup end', -1), s:TYPE_ENDAUGROUP)
		call assert_equal(vimscript_indentexpr#get_type('   aug end', -1), s:TYPE_ENDAUGROUP)
		call assert_equal(vimscript_indentexpr#get_type('   augroup END', -1), s:TYPE_ENDAUGROUP)
		call assert_equal(vimscript_indentexpr#get_type('   aug END', -1), s:TYPE_ENDAUGROUP)
		call assert_equal(vimscript_indentexpr#get_type('   while v:true', -1), s:TYPE_WHILE)
		call assert_equal(vimscript_indentexpr#get_type('   wh v:true', -1), s:TYPE_WHILE)
		call assert_equal(vimscript_indentexpr#get_type('   endwhile', -1), s:TYPE_ENDWHILE)
		call assert_equal(vimscript_indentexpr#get_type('   endw', -1), s:TYPE_ENDWHILE)
		call assert_equal(vimscript_indentexpr#get_type('   try', -1), s:TYPE_TRY)
		call assert_equal(vimscript_indentexpr#get_type('   catch', -1), s:TYPE_CATCH)
		call assert_equal(vimscript_indentexpr#get_type('   finally', -1), s:TYPE_FINALLY)
		call assert_equal(vimscript_indentexpr#get_type('   endtry', -1), s:TYPE_ENDTRY)

		if s:ENABLE_VIM9
			call assert_equal(vimscript_indentexpr#get_type('   final', -1), s:TYPE_FINAL)
			call assert_equal(vimscript_indentexpr#get_type('   fina', -1), s:TYPE_FINALLY)
			call assert_equal(vimscript_indentexpr#get_type('   finall', -1), s:TYPE_FINALLY)
			call assert_equal(vimscript_indentexpr#get_type('   def', -1), s:TYPE_DEF)
			call assert_equal(vimscript_indentexpr#get_type('   enddef', -1), s:TYPE_ENDDEF)
			call assert_equal(vimscript_indentexpr#get_type('   #en', -1), s:TYPE_COMMENT)
			call assert_equal(vimscript_indentexpr#get_type('   + i', -1), s:TYPE_CONTINUOUS)
			call assert_equal(vimscript_indentexpr#get_type('   - i', -1), s:TYPE_CONTINUOUS)
			call assert_equal(vimscript_indentexpr#get_type('   * i', -1), s:TYPE_CONTINUOUS)
			call assert_equal(vimscript_indentexpr#get_type('   / i', -1), s:TYPE_CONTINUOUS)
			call assert_equal(vimscript_indentexpr#get_type('   % i', -1), s:TYPE_CONTINUOUS)
			call assert_equal(vimscript_indentexpr#get_type('   && i', -1), s:TYPE_CONTINUOUS)
			call assert_equal(vimscript_indentexpr#get_type('   || i', -1), s:TYPE_CONTINUOUS)
			call assert_equal(vimscript_indentexpr#get_type('   ->method()', -1), s:TYPE_CONTINUOUS)
			call assert_equal(vimscript_indentexpr#get_type('   .. str', -1), s:TYPE_CONTINUOUS)
			call assert_equal(vimscript_indentexpr#get_type('   .member', -1), s:TYPE_CONTINUOUS)
			call assert_equal(vimscript_indentexpr#get_type('   {', -1), s:TYPE_BLOCK)
		endif

		let g:vim_indent_cont = 0

		call s:run_test([
			\ 'let x = [',
			\ '\ 1,',
			\ '\ 2,',
			\ '\ ]',
			\ ], [
			\ 'let x = [',
			\ '\ 1,',
			\ '\ 2,',
			\ '\ ]',
			\ ])

		call s:run_test([
			\ 'if foo',
			\ '\ . bar',
			\ 'echo "hi"',
			\ 'endif',
			\ ], [
			\ 'if foo',
			\ '\ . bar',
			\ '    echo "hi"',
			\ 'endif',
			\ ])

		let g:vim_indent_cont = 8

		call s:run_test([
			\ 'let x = [',
			\ '\ 1,',
			\ '\ 2,',
			\ '\ ]',
			\ 'echo "hi"',
			\ ], [
			\ 'let x = [',
			\ '        \ 1,',
			\ '        \ 2,',
			\ '        \ ]',
			\ 'echo "hi"',
			\ ])

		let g:vim_indent_cont = 2

		if !has('nvim')
			call s:run_test([
				\ 'if v:true',
				\ 'var lines =<< trim END',
				\ 'text text text',
				\ '   text text text',
				\ 'text text text',
				\ '       text text',
				\ '   text text text',
				\ '         text text text',
				\ 'END',
				\ 'echo 123',
				\ 'else',
				\ 'echo 456',
				\ 'endif',
				\ ], [
				\ 'if v:true',
				\ '    var lines =<< trim END',
				\ 'text text text',
				\ '   text text text',
				\ 'text text text',
				\ '       text text',
				\ '   text text text',
				\ '         text text text',
				\ 'END',
				\ '    echo 123',
				\ 'else',
				\ '    echo 456',
				\ 'endif',
				\ ])
		endif

		call s:run_test([
			\ 'for n in range(1, 8)',
			\ 'call popup_create(" ", {',
			\ '\ "highlight": "aaa",',
			\ '\ "pos": "botleft",',
			\ '\ "line": 1,',
			\ '\ "col": 1,',
			\ '\ })',
			\ 'endfor',
			\ ], [
			\ 'for n in range(1, 8)',
			\ '    call popup_create(" ", {',
			\ '      \ "highlight": "aaa",',
			\ '      \ "pos": "botleft",',
			\ '      \ "line": 1,',
			\ '      \ "col": 1,',
			\ '      \ })',
			\ 'endfor',
			\ ])

		call s:run_test([
			\ 'augroup! xxx',
			\ 'echo 12',
			\ ], [
			\ 'augroup! xxx',
			\ 'echo 12',
			\ ])

		call s:run_test([
			\ 'if 1',
			\ 'echo 12',
			\ 'endif',
			\ ], [
			\ 'if 1',
			\ '    echo 12',
			\ 'endif',
			\ ])

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
			\ 'if 1',
			\ 'elseif 2',
			\ 'else',
			\ 'endif',
			\ 'endif',
			\ ], [
			\ 'if 1',
			\ '    echo 12',
			\ 'elseif 2',
			\ '    echo 12',
			\ 'else',
			\ '    echo 12',
			\ '    if 1',
			\ '    elseif 2',
			\ '    else',
			\ '    endif',
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
			\ '      \ : if 1',
			\ '      \ |     echo 12',
			\ '      \ | else',
			\ '      \ |     echo 12',
			\ '      \ | endif',
			\ 'augroup END',
			\ 'augroup xxx',
			\ 'augroup END',
			\ ])

		if s:ENABLE_VIM9
			call s:run_test([
				\ 'def outter()',
				\ 'echo 12',
				\ 'def inner()',
				\ 'echo 34',
				\ 'enddef',
				\ 'enddef',
				\ ], [
				\ 'def outter()',
				\ '    echo 12',
				\ '    def inner()',
				\ '        echo 34',
				\ '    enddef',
				\ 'enddef',
				\ ])

			call s:run_test([
				\ 'var total = m',
				\ '+ n',
				\ 'echo 123',
				\ ], [
				\ 'var total = m',
				\ '  + n',
				\ 'echo 123',
				\ ])

			call s:run_test([
				\ 'x',
				\ '->method()',
				\ '->method()',
				\ '->method()',
				\ '->method()',
				\ 'F()',
				\ ], [
				\ 'x',
				\ '  ->method()',
				\ '  ->method()',
				\ '  ->method()',
				\ '  ->method()',
				\ 'F()',
				\ ])

			call s:run_test([
				\ 'if v:true',
				\ 'let a = p',
				\ '? 1',
				\ ': 2',
				\ 'echo 234',
				\ ':2',
				\ 'echo 234',
				\ 'endif',
				\ ], [
				\ 'if v:true',
				\ '    let a = p',
				\ '      ? 1',
				\ '      : 2',
				\ '    echo 234',
				\ '    :2',
				\ '    echo 234',
				\ 'endif',
				\ ])

			call s:run_test([
				\ '{',
				\ 'echo 234',
				\ '}',
				\ ], [
				\ '{',
				\ '    echo 234',
				\ '}',
				\ ])

			call s:run_test([
				\ 'let ruby =<< RUBY',
				\ '    require("csv")',
				\ 'RUBY',
				\ '',
				\ 'let c =<< C',
				\ '    #include <stdio.h>',
				\ 'C',
				\ ], [
				\ 'let ruby =<< RUBY',
				\ '    require("csv")',
				\ 'RUBY',
				\ '',
				\ 'let c =<< C',
				\ '    #include <stdio.h>',
				\ 'C',
				\ ])

			call s:run_test([
				\ 'let a = p',
				\ '? 1',
				\ ': 2',
				\ 'echo 234',
				\ ':2',
				\ ], [
				\ 'let a = p',
				\ '  ? 1',
				\ '  : 2',
				\ 'echo 234',
				\ ':2',
				\ ])

			call s:run_test([
				\ 'def Func(): number',
				\ 'try',
				\ 'final foo = 10',
				\ 'fina',
				\ 'final foo = 10',
				\ 'endtry',
				\ 'try',
				\ 'final foo = 10',
				\ 'finall',
				\ 'final foo = 10',
				\ 'endtry',
				\ 'try',
				\ 'final foo = 10',
				\ 'finally',
				\ 'final foo = 10',
				\ 'endtry',
				\ 'return foo',
				\ 'enddef',
				\ ], [
				\ 'def Func(): number',
				\ '    try',
				\ '        final foo = 10',
				\ '    fina',
				\ '        final foo = 10',
				\ '    endtry',
				\ '    try',
				\ '        final foo = 10',
				\ '    finall',
				\ '        final foo = 10',
				\ '    endtry',
				\ '    try',
				\ '        final foo = 10',
				\ '    finally',
				\ '        final foo = 10',
				\ '    endtry',
				\ '    return foo',
				\ 'enddef',
				\ ])

			"call s:run_test([
			" \ 'filter(list, (k, v) =>',
			" \ 'v > 0)',
			" \ ], [
			" \ 'filter(list, (k, v) =>',
			" \ '  v > 0)',
			" \ ])

			"call s:run_test([
			" \ 'Func (',
			" \ 'arg)',
			" \ 'echo 123',
			" \ ], [
			" \ 'Func (',
			" \ '  arg)',
			" \ 'echo 123',
			" \ ])

			"call s:run_test([
			" \ 'Func (',
			" \ 'arg',
			" \ ')',
			" \ 'echo 123',
			" \ ], [
			" \ 'Func (',
			" \ '  arg',
			" \ '  )',
			" \ 'echo 123',
			" \ ])

			"call s:run_test([
			" \ 'var xs = [',
			" \ 'a,',
			" \ 'b,',
			" \ 'c,',
			" \ 'd]',
			" \ 'm()',
			" \ ], [
			" \ 'var xs = [',
			" \ '  a,',
			" \ '  b,',
			" \ '  c,',
			" \ '  d]',
			" \ 'm()',
			" \ ])

			"call s:run_test([
			" \ 'F((1,2,3), [',
			" \ 'a,',
			" \ 'b,',
			" \ 'c,',
			" \ 'd])',
			" \ 'm()',
			" \ ], [
			" \ 'F((1,2,3), [',
			" \ '  a,',
			" \ '  b,',
			" \ '  c,',
			" \ '  d])',
			" \ 'm()',
			" \ ])

			"call s:run_test([
			" \ 'F({}, [',
			" \ 'a,',
			" \ 'b,',
			" \ 'c,',
			" \ 'd])',
			" \ 'm()',
			" \ ], [
			" \ 'F({}, [',
			" \ '  a,',
			" \ '  b,',
			" \ '  c,',
			" \ '  d])',
			" \ 'm()',
			" \ ])

			"call s:run_test([
			" \ 'F([], [',
			" \ 'a,',
			" \ 'b,',
			" \ 'c,',
			" \ 'd])',
			" \ 'm()',
			" \ ], [
			" \ 'F([], [',
			" \ '  a,',
			" \ '  b,',
			" \ '  c,',
			" \ '  d])',
			" \ 'm()',
			" \ ])

			"call s:run_test([
			" \ 'var Lambda = (arg) => {',
			" \ 'let n = a',
			" \ '+ b',
			" \ 'return n',
			" \ '}',
			" \ ], [
			" \ 'var Lambda = (arg) => {',
			" \ '      let n = a',
			" \ '        + b',
			" \ '      return n',
			" \ '  }',
			" \ ])

			"call s:run_test([
			" \ 'var Lambda = (arg) =>',
			" \ '{',
			" \ 'let n = a',
			" \ '+ b',
			" \ 'return n',
			" \ '}',
			" \ 'M()',
			" \ ], [
			" \ 'var Lambda = (arg) =>',
			" \ '  {',
			" \ '      let n = a',
			" \ '        + b',
			" \ '      return n',
			" \ '  }',
			" \ '  M()',
			" \ ])

			"call s:run_test([
			" \ 'aaaa({',
			" \ 'let n = a',
			" \ '+ b',
			" \ 'return n',
			" \ '})->method()',
			" \ 'M()',
			" \ ], [
			" \ 'aaaa({',
			" \ '      let n = a',
			" \ '        + b',
			" \ '      return n',
			" \ '  })->method()',
			" \ 'M()',
			" \ ])

			"call s:run_test([
			" \ 'if v:true',
			" \ 'popup_setoptions(winid, {',
			" \ '"title": "abc",',
			" \ '})',
			" \ 'else',
			" \ 'popup_setoptions(winid, {',
			" \ '"title": "abc",',
			" \ '})',
			" \ 'M()',
			" \ 'endif',
			" \ ], [
			" \ 'if v:true',
			" \ '    popup_setoptions(winid, {',
			" \ '          "title": "abc",',
			" \ '      })',
			" \ 'else',
			" \ '    popup_setoptions(winid, {',
			" \ '          "title": "abc",',
			" \ '      })',
			" \ '    M()',
			" \ 'endif',
			" \ ])
		endif

		if !empty(v:errors)
			let lines = []
			for err in v:errors
				let xs = split(err, '\(Expected\|but got\)')
				echohl Error
				if 3 == len(xs)
					let lines += [
						\ xs[0],
						\ '  Expected ' .. xs[1],
						\ '  but got  ' .. xs[2],
						\ ]
					echo xs[0]
					echo '  Expected ' .. xs[1]
					echo '  but got  ' .. xs[2]
				else
					let lines += [err]
					echo err
				endif
				echohl None
			endfor
			call writefile(lines, s:TEST_LOG)
		endif
	finally
		if -1 != saved
			let g:vim_indent_cont = saved
		endif
	endtry
endfunction

function! s:run_test(lines, expect) abort
	try
		new
		setlocal filetype=vim
		setlocal expandtab softtabstop=-1 shiftwidth=4 tabstop=4
		setlocal indentexpr=vimscript_indentexpr#exec()
		let lnum = 0
		for line in a:lines
			let lnum += 1
			call setbufline(bufnr(), lnum, line)
		endfor
		call feedkeys('gg=G', 'xn')
		let formatted_lines = getbufline('%', 1, '$')
	finally
		bdelete!
	endtry
	call assert_equal(a:expect, formatted_lines)
endfunction

