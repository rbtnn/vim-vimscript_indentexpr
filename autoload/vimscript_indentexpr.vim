
let s:TEST_LOG = expand('<sfile>:h:h:gs?\?/?') . '/test.log'

let s:ENABLE_VIM9 = exists(':vim9script')

let s:TYPE_NORMAL = 'TYPE_NORMAL'
let s:TYPE_ONELINER = 'TYPE_ONELINER'
let s:TYPE_COMMENT = 'TYPE_COMMENT'
let s:TYPE_CURR_CONTINUOUS = 'TYPE_CURR_CONTINUOUS'
let s:TYPE_KEEP_CONTINUOUS = 'TYPE_KEEP_CONTINUOUS'
let s:TYPE_NEXT_CONTINUOUS = 'TYPE_NEXT_CONTINUOUS'
let s:TYPE_LAST_CONTINUOUS = 'TYPE_LAST_CONTINUOUS'
let s:TYPE_BLOCK_CONTINUOUS = 'TYPE_BLOCK_CONTINUOUS'
let s:TYPE_ENDBLOCK_CONTINUOUS = 'TYPE_ENDBLOCK_CONTINUOUS'
let s:TYPE_QUESTION = 'TYPE_QUESTION'
let s:TYPE_COLLON = 'TYPE_COLLON'
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



function! vimscript_indentexpr#exec() abort
	if 1 == v:lnum
		return 0
	endif
	let prev_info = s:prev(v:lnum)
	let curr_info = s:curr(v:lnum)

	let indent = prev_info['indent']

	let vim_indent_cont = get(g:, 'vim_indent_cont', shiftwidth() * 3)

	if -1 != index(['vimLetHereDoc', 'vimLetHereDocStop'], curr_info['syn_name'])
		return -1
	endif

	if (s:TYPE_ENDBLOCK_CONTINUOUS == curr_info['type'])
		return indent - shiftwidth()
	endif

	if s:TYPE_KEEP_CONTINUOUS != curr_info['type']
		if s:TYPE_BLOCK_CONTINUOUS == prev_info['type']
			return indent + vim_indent_cont + shiftwidth()
		elseif s:TYPE_ENDBLOCK_CONTINUOUS == prev_info['type']
			let indent -= vim_indent_cont
		elseif (s:TYPE_CURR_CONTINUOUS == curr_info['type']) || (s:TYPE_QUESTION == curr_info['type'])
			if s:TYPE_CURR_CONTINUOUS != prev_info['type']
				let indent += vim_indent_cont
			endif
		elseif s:TYPE_LAST_CONTINUOUS == prev_info['type']
			let indent -= vim_indent_cont
		else
			if s:TYPE_COLLON == prev_info['type']
				let indent -= vim_indent_cont

			elseif s:TYPE_CURR_CONTINUOUS == prev_info['type']
				let indent -= vim_indent_cont
			elseif s:TYPE_NEXT_CONTINUOUS == prev_info['type']
				let indent += vim_indent_cont
			endif
		endif
	endif

	let p = (s:TYPE_FUNCTION == prev_info['type']) ||
	  \ (s:TYPE_AUGROUP == prev_info['type']) ||
	  \ (s:TYPE_WHILE == prev_info['type']) ||
	  \ (s:TYPE_DEF == prev_info['type']) ||
	  \ (s:TYPE_FOR == prev_info['type']) ||
	  \ (s:TYPE_TRY == prev_info['type']) ||
	  \ (s:TYPE_FINALLY == prev_info['type']) ||
	  \ (s:TYPE_CATCH == prev_info['type']) ||
	  \ (s:TYPE_IF == prev_info['type']) ||
	  \ (s:TYPE_ELSE == prev_info['type']) ||
	  \ (s:TYPE_ELSEIF == prev_info['type']) ||
	  \ (s:TYPE_BLOCK == prev_info['type'])

	let c = (s:TYPE_ENDFUNCTION == curr_info['type']) ||
	  \ (s:TYPE_ENDAUGROUP == curr_info['type']) ||
	  \ (s:TYPE_ENDWHILE == curr_info['type']) ||
	  \ (s:TYPE_ENDDEF == curr_info['type']) ||
	  \ (s:TYPE_ENDFOR == curr_info['type']) ||
	  \ (s:TYPE_FINALLY == curr_info['type']) ||
	  \ (s:TYPE_CATCH == curr_info['type']) ||
	  \ (s:TYPE_ENDTRY == curr_info['type']) ||
	  \ (s:TYPE_ENDIF == curr_info['type']) ||
	  \ (s:TYPE_ELSE == curr_info['type']) ||
	  \ (s:TYPE_ELSEIF == curr_info['type']) ||
	  \ (s:TYPE_ENDBLOCK == curr_info['type'])

	if p == c
		return indent
	else
		if p
			return indent + shiftwidth()
		else
			return indent - shiftwidth()
		endif
	endif
endfunction

function! vimscript_indentexpr#parse(line, lnum) abort
	let text = matchstr(a:line, '^\s*\(export\s\+\)\?\zs\S.*$')
	let type = s:TYPE_NORMAL
	if text =~# '^"'
		let type = s:TYPE_COMMENT
	elseif s:ENABLE_VIM9 && (text =~# '^#')
		let type = s:TYPE_COMMENT
	elseif text =~# '^\\'
		let type = s:TYPE_CURR_CONTINUOUS

	elseif s:ENABLE_VIM9 && (text =~# '^\(+\|-\|*\|/\|%\|&&\|||\|\.\.\|->\|\.\)')
		let type = s:TYPE_CURR_CONTINUOUS

	elseif s:ENABLE_VIM9 && (text =~# '=>$')
		let type = s:TYPE_NEXT_CONTINUOUS

	elseif s:ENABLE_VIM9 && (text =~# '\S\s*{$')
		let type = s:TYPE_BLOCK_CONTINUOUS
	elseif s:ENABLE_VIM9 && (text =~# '^{$')
		let type = s:TYPE_BLOCK

	elseif s:ENABLE_VIM9 && (text =~# '^}\s*\S') && s:expect_pair('{', '}', a:lnum, [(s:TYPE_BLOCK), (s:TYPE_BLOCK_CONTINUOUS)])
		let type = s:TYPE_ENDBLOCK_CONTINUOUS
	elseif s:ENABLE_VIM9 && (text =~# '^}$') && s:expect_pair('{', '}', a:lnum, [(s:TYPE_BLOCK_CONTINUOUS)])
		let type = s:TYPE_ENDBLOCK_CONTINUOUS
	elseif s:ENABLE_VIM9 && (text =~# '^}$') && s:expect_pair('{', '}', a:lnum, [(s:TYPE_BLOCK)])
		let type = s:TYPE_ENDBLOCK

	elseif s:ENABLE_VIM9 && (text =~# '^?')
		let type = s:TYPE_QUESTION
	elseif s:ENABLE_VIM9 && (text =~# '^:') && s:expect_type([(s:TYPE_QUESTION)], a:lnum - 1)
		let type = s:TYPE_COLLON

	elseif s:ENABLE_VIM9 && (text =~# '\]\s*,\s*[{(\[]$') && s:expect_pair('(', ')', a:lnum, [(s:TYPE_NEXT_CONTINUOUS), (s:TYPE_KEEP_CONTINUOUS)])
		let type = s:TYPE_KEEP_CONTINUOUS
	elseif s:ENABLE_VIM9 && (text =~# '\]\s*,\s*[{(\[]$') && s:expect_pair('\[', '\]', a:lnum, [(s:TYPE_NEXT_CONTINUOUS), (s:TYPE_KEEP_CONTINUOUS)])
		let type = s:TYPE_KEEP_CONTINUOUS


	elseif s:ENABLE_VIM9 && (text =~# '[{(\[]$')
		let type = s:TYPE_NEXT_CONTINUOUS
	elseif s:ENABLE_VIM9 && (text =~# '}$') && s:expect_pair('{', '}', a:lnum, [(s:TYPE_NEXT_CONTINUOUS), (s:TYPE_KEEP_CONTINUOUS)])
		let type = s:TYPE_LAST_CONTINUOUS
	elseif s:ENABLE_VIM9 && (text =~# ')$') && s:expect_pair('(', ')', a:lnum, [(s:TYPE_NEXT_CONTINUOUS), (s:TYPE_KEEP_CONTINUOUS)])
		let type = s:TYPE_LAST_CONTINUOUS
	elseif s:ENABLE_VIM9 && (text =~# '\]$') && s:expect_pair('\[', '\]', a:lnum, [(s:TYPE_NEXT_CONTINUOUS), (s:TYPE_KEEP_CONTINUOUS)])
		let type = s:TYPE_LAST_CONTINUOUS

	elseif text =~# '^\<if\>.*\<endi\%[f\]\>$'
		let type = s:TYPE_ONELINER
	elseif text =~# '^\<wh\%[ile\]\>.*\<endw\%[hile\]\>$'
		let type = s:TYPE_ONELINER
	elseif text =~# '^\<for\>.*\<endfo\%[r\]\>$'
		let type = s:TYPE_ONELINER
	elseif text =~# '^\<try\>.*\<endt\%[ry\]\>$'
		let type = s:TYPE_ONELINER
	elseif text =~# '^\<aug\%[roup\]\>!'
		let type = s:TYPE_ONELINER
	elseif text =~# '^\<if\>'
		let type = s:TYPE_IF
	elseif text =~# '^\<elsei\%[f\]\>'
		let type = s:TYPE_ELSEIF
	elseif text =~# '^\<el\%[se\]\>'
		let type = s:TYPE_ELSE
	elseif text =~# '^\<en\%[dif\]\>'
		let type = s:TYPE_ENDIF
	elseif text =~# '^\<for\>'
		let type = s:TYPE_FOR
	elseif text =~# '^\<endfo\%[r\]\>'
		let type = s:TYPE_ENDFOR
	elseif text =~# '^\<fu\%[nction\]\>'
		let type = s:TYPE_FUNCTION
	elseif text =~# '^\<endf\%[unction\]\>'
		let type = s:TYPE_ENDFUNCTION
	elseif text =~# '^\<aug\%[roup\]\>\s\+\<\cend\>'
		let type = s:TYPE_ENDAUGROUP
	elseif text =~# '^\<aug\%[roup\]\>'
		let type = s:TYPE_AUGROUP
	elseif text =~# '^\<wh\%[ile\]\>'
		let type = s:TYPE_WHILE
	elseif text =~# '^\<endw\%[hile\]\>'
		let type = s:TYPE_ENDWHILE
	elseif text =~# '^\<try\>'
		let type = s:TYPE_TRY
	elseif text =~# '^\<cat\%[ch\]\>'
		let type = s:TYPE_CATCH
	elseif text =~# '^\<fina\%[lly\]\>'
		let type = s:TYPE_FINALLY
	elseif text =~# '^\<endt\%[ry\]\>'
		let type = s:TYPE_ENDTRY
	elseif s:ENABLE_VIM9 && (text =~# '^\<enddef\>')
		let type = s:TYPE_ENDDEF
	elseif s:ENABLE_VIM9 && (text =~# '^\<def\>')
		let type = s:TYPE_DEF
	else
		let type = type
	endif
	return { 'type' : type, }
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

		call assert_equal(vimscript_indentexpr#parse('   if v:true | endif', -1), { 'type' : s:TYPE_ONELINER, })
		call assert_equal(vimscript_indentexpr#parse('   for i in [1,2,3] | endfor', -1), { 'type' : s:TYPE_ONELINER, })
		call assert_equal(vimscript_indentexpr#parse('   while v:true | endwhile', -1), { 'type' : s:TYPE_ONELINER, })
		call assert_equal(vimscript_indentexpr#parse('   try | catch | endtry', -1), { 'type' : s:TYPE_ONELINER, })
		call assert_equal(vimscript_indentexpr#parse('   "en', -1), { 'type' : s:TYPE_COMMENT, })
		call assert_equal(vimscript_indentexpr#parse('   \en', -1), { 'type' : s:TYPE_CURR_CONTINUOUS, })
		call assert_equal(vimscript_indentexpr#parse('   if v:true', -1), { 'type' : s:TYPE_IF, })
		call assert_equal(vimscript_indentexpr#parse('   elseif v:true', -1), { 'type' : s:TYPE_ELSEIF, })
		call assert_equal(vimscript_indentexpr#parse('   elsei v:true', -1), { 'type' : s:TYPE_ELSEIF, })
		call assert_equal(vimscript_indentexpr#parse('   else', -1), { 'type' : s:TYPE_ELSE, })
		call assert_equal(vimscript_indentexpr#parse('   el', -1), { 'type' : s:TYPE_ELSE, })
		call assert_equal(vimscript_indentexpr#parse('   endif', -1), { 'type' : s:TYPE_ENDIF, })
		call assert_equal(vimscript_indentexpr#parse('   en', -1), { 'type' : s:TYPE_ENDIF, })
		call assert_equal(vimscript_indentexpr#parse('   for', -1), { 'type' : s:TYPE_FOR, })
		call assert_equal(vimscript_indentexpr#parse('   endfor', -1), { 'type' : s:TYPE_ENDFOR, })
		call assert_equal(vimscript_indentexpr#parse('   endfo', -1), { 'type' : s:TYPE_ENDFOR, })
		call assert_equal(vimscript_indentexpr#parse('   function', -1), { 'type' : s:TYPE_FUNCTION, })
		call assert_equal(vimscript_indentexpr#parse('   fu', -1), { 'type' : s:TYPE_FUNCTION, })
		call assert_equal(vimscript_indentexpr#parse('   endfunction', -1), { 'type' : s:TYPE_ENDFUNCTION, })
		call assert_equal(vimscript_indentexpr#parse('   augroup', -1), { 'type' : s:TYPE_AUGROUP, })
		call assert_equal(vimscript_indentexpr#parse('   aug', -1), { 'type' : s:TYPE_AUGROUP, })
		call assert_equal(vimscript_indentexpr#parse('   augroup end', -1), { 'type' : s:TYPE_ENDAUGROUP, })
		call assert_equal(vimscript_indentexpr#parse('   aug end', -1), { 'type' : s:TYPE_ENDAUGROUP, })
		call assert_equal(vimscript_indentexpr#parse('   augroup END', -1), { 'type' : s:TYPE_ENDAUGROUP, })
		call assert_equal(vimscript_indentexpr#parse('   aug END', -1), { 'type' : s:TYPE_ENDAUGROUP, })
		call assert_equal(vimscript_indentexpr#parse('   while v:true', -1), { 'type' : s:TYPE_WHILE, })
		call assert_equal(vimscript_indentexpr#parse('   wh v:true', -1), { 'type' : s:TYPE_WHILE, })
		call assert_equal(vimscript_indentexpr#parse('   endwhile', -1), { 'type' : s:TYPE_ENDWHILE, })
		call assert_equal(vimscript_indentexpr#parse('   endw', -1), { 'type' : s:TYPE_ENDWHILE, })
		call assert_equal(vimscript_indentexpr#parse('   try', -1), { 'type' : s:TYPE_TRY, })
		call assert_equal(vimscript_indentexpr#parse('   catch', -1), { 'type' : s:TYPE_CATCH, })
		call assert_equal(vimscript_indentexpr#parse('   finally', -1), { 'type' : s:TYPE_FINALLY, })
		call assert_equal(vimscript_indentexpr#parse('   endtry', -1), { 'type' : s:TYPE_ENDTRY, })

		if s:ENABLE_VIM9
			call assert_equal(vimscript_indentexpr#parse('   def', -1), { 'type' : s:TYPE_DEF, })
			call assert_equal(vimscript_indentexpr#parse('   enddef', -1), { 'type' : s:TYPE_ENDDEF, })
			call assert_equal(vimscript_indentexpr#parse('   #en', -1), { 'type' : s:TYPE_COMMENT, })
			call assert_equal(vimscript_indentexpr#parse('   Func (', -1), { 'type' : s:TYPE_NEXT_CONTINUOUS, })
			call assert_equal(vimscript_indentexpr#parse('   Func {', -1), { 'type' : s:TYPE_BLOCK_CONTINUOUS, })
			call assert_equal(vimscript_indentexpr#parse('   Func [', -1), { 'type' : s:TYPE_NEXT_CONTINUOUS, })
			call assert_equal(vimscript_indentexpr#parse('   + i', -1), { 'type' : s:TYPE_CURR_CONTINUOUS, })
			call assert_equal(vimscript_indentexpr#parse('   - i', -1), { 'type' : s:TYPE_CURR_CONTINUOUS, })
			call assert_equal(vimscript_indentexpr#parse('   * i', -1), { 'type' : s:TYPE_CURR_CONTINUOUS, })
			call assert_equal(vimscript_indentexpr#parse('   / i', -1), { 'type' : s:TYPE_CURR_CONTINUOUS, })
			call assert_equal(vimscript_indentexpr#parse('   % i', -1), { 'type' : s:TYPE_CURR_CONTINUOUS, })
			call assert_equal(vimscript_indentexpr#parse('   && i', -1), { 'type' : s:TYPE_CURR_CONTINUOUS, })
			call assert_equal(vimscript_indentexpr#parse('   || i', -1), { 'type' : s:TYPE_CURR_CONTINUOUS, })
			call assert_equal(vimscript_indentexpr#parse('   ->method()', -1), { 'type' : s:TYPE_CURR_CONTINUOUS, })
			call assert_equal(vimscript_indentexpr#parse('   .. str', -1), { 'type' : s:TYPE_CURR_CONTINUOUS, })
			call assert_equal(vimscript_indentexpr#parse('   .member', -1), { 'type' : s:TYPE_CURR_CONTINUOUS, })
			call assert_equal(vimscript_indentexpr#parse('   {', -1), { 'type' : s:TYPE_BLOCK, })
		endif

		let g:vim_indent_cont = 8

		call s:run_test([
		  \ 'let x = [',
		  \ '\ 1,',
		  \ '\ 2,',
		  \ '\ ]',
		  \ ], [
		  \ 'let x = [',
		  \ '        \ 1,',
		  \ '        \ 2,',
		  \ '        \ ]',
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
			  \ 'filter(list, (k, v) =>',
			  \ 'v > 0)',
			  \ ], [
			  \ 'filter(list, (k, v) =>',
			  \ '  v > 0)',
			  \ ])

			call s:run_test([
			  \ 'Func (',
			  \ 'arg)',
			  \ 'echo 123',
			  \ ], [
			  \ 'Func (',
			  \ '  arg)',
			  \ 'echo 123',
			  \ ])

			call s:run_test([
			  \ 'Func (',
			  \ 'arg',
			  \ ')',
			  \ 'echo 123',
			  \ ], [
			  \ 'Func (',
			  \ '  arg',
			  \ '  )',
			  \ 'echo 123',
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
			  \ 'var xs = [',
			  \ 'a,',
			  \ 'b,',
			  \ 'c,',
			  \ 'd]',
			  \ 'm()',
			  \ ], [
			  \ 'var xs = [',
			  \ '  a,',
			  \ '  b,',
			  \ '  c,',
			  \ '  d]',
			  \ 'm()',
			  \ ])

			call s:run_test([
			  \ 'var xs = [',
			  \ 'a,',
			  \ 'b,',
			  \ 'c,',
			  \ 'd], [',
			  \ 'e,',
			  \ 'f,',
			  \ 'g,',
			  \ 'h]',
			  \ 'm()',
			  \ ], [
			  \ 'var xs = [',
			  \ '  a,',
			  \ '  b,',
			  \ '  c,',
			  \ '  d], [',
			  \ '  e,',
			  \ '  f,',
			  \ '  g,',
			  \ '  h]',
			  \ 'm()',
			  \ ])

			call s:run_test([
			  \ 'F((1,2,3), [',
			  \ 'a,',
			  \ 'b,',
			  \ 'c,',
			  \ 'd])',
			  \ 'm()',
			  \ ], [
			  \ 'F((1,2,3), [',
			  \ '  a,',
			  \ '  b,',
			  \ '  c,',
			  \ '  d])',
			  \ 'm()',
			  \ ])

			call s:run_test([
			  \ 'F({}, [',
			  \ 'a,',
			  \ 'b,',
			  \ 'c,',
			  \ 'd])',
			  \ 'm()',
			  \ ], [
			  \ 'F({}, [',
			  \ '  a,',
			  \ '  b,',
			  \ '  c,',
			  \ '  d])',
			  \ 'm()',
			  \ ])

			call s:run_test([
			  \ 'F([], [',
			  \ 'a,',
			  \ 'b,',
			  \ 'c,',
			  \ 'd])',
			  \ 'm()',
			  \ ], [
			  \ 'F([], [',
			  \ '  a,',
			  \ '  b,',
			  \ '  c,',
			  \ '  d])',
			  \ 'm()',
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
			  \ 'var Lambda = (arg) => {',
			  \ 'let n = a',
			  \ '+ b',
			  \ 'return n',
			  \ '}',
			  \ ], [
			  \ 'var Lambda = (arg) => {',
			  \ '      let n = a',
			  \ '        + b',
			  \ '      return n',
			  \ '  }',
			  \ ])

			call s:run_test([
			  \ 'var Lambda = (arg) =>',
			  \ '{',
			  \ 'let n = a',
			  \ '+ b',
			  \ 'return n',
			  \ '}',
			  \ 'M()',
			  \ ], [
			  \ 'var Lambda = (arg) =>',
			  \ '  {',
			  \ '      let n = a',
			  \ '        + b',
			  \ '      return n',
			  \ '  }',
			  \ '  M()',
			  \ ])

			call s:run_test([
			  \ 'aaaa({',
			  \ 'let n = a',
			  \ '+ b',
			  \ 'return n',
			  \ '})->method()',
			  \ 'M()',
			  \ ], [
			  \ 'aaaa({',
			  \ '      let n = a',
			  \ '        + b',
			  \ '      return n',
			  \ '  })->method()',
			  \ 'M()',
			  \ ])

			call s:run_test([
			  \ 'if v:true',
			  \ 'popup_setoptions(winid, {',
			  \ '"title": "abc",',
			  \ '})',
			  \ 'else',
			  \ 'popup_setoptions(winid, {',
			  \ '"title": "abc",',
			  \ '})',
			  \ 'M()',
			  \ 'endif',
			  \ ], [
			  \ 'if v:true',
			  \ '    popup_setoptions(winid, {',
			  \ '          "title": "abc",',
			  \ '      })',
			  \ 'else',
			  \ '    popup_setoptions(winid, {',
			  \ '          "title": "abc",',
			  \ '      })',
			  \ '    M()',
			  \ 'endif',
			  \ ])
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



function! s:expect_pair(st, ed, n, ts) abort
	let saved = getcurpos()
	call setpos('.', [0, a:n, 0, 0])
	let lnum = searchpairpos(a:st, '', a:ed, 'bn')[0]
	call setpos('.', saved)
	if (1 <= lnum) && (lnum <= line('$')) && (a:n != lnum)
		return s:expect_type(a:ts, lnum)
	else
		return v:false
	endif
endfunction

function! s:expect_type(ts, n) abort
	let x = vimscript_indentexpr#parse(getline(a:n), a:n)
	return -1 != index(a:ts, x['type'])
endfunction

function! s:prev(lnum) abort
	let prev_lnum = prevnonblank(a:lnum - 1)
	while (-1 != index(['vimLetHereDoc', 'vimLetHereDocStop'], synIDattr(synID(prev_lnum, 1, 1), 'name'))) && (1 < prev_lnum)
		let prev_lnum = prevnonblank(prev_lnum - 1)
	endwhile
	let syn_name = synIDattr(synID(prev_lnum, 1, 1), 'name')
	let line = getline(prev_lnum)
	let t = vimscript_indentexpr#parse(line, prev_lnum)['type']
	let indent = indent(prev_lnum)
	return { 'syn_name' : syn_name, 'type' : t, 'indent' : indent, }
endfunction

function! s:curr(lnum) abort
	let syn_name = synIDattr(synID(a:lnum, 1, 1), 'name')
	let line = getline(a:lnum)
	let t = vimscript_indentexpr#parse(line, -1)['type']
	return { 'syn_name' : syn_name, 'type' : t, }
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

