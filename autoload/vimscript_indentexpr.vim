
let s:TEST_LOG = expand('<sfile>:h:h:gs?\?/?') . '/test.log'

if exists(':vim9script')
	let s:ENABLE_VIM9 = v:true
endif

let s:TYPE_NORMAL = 'TYPE_NORMAL'
let s:TYPE_ONELINER = 'TYPE_ONELINER'
let s:TYPE_COMMENT = 'TYPE_COMMENT'
let s:TYPE_CURR_CONTINUOUS = 'TYPE_CURR_CONTINUOUS'
let s:TYPE_KEEP_CONTINUOUS = 'TYPE_KEEP_CONTINUOUS'
let s:TYPE_NEXT_CONTINUOUS = 'TYPE_NEXT_CONTINUOUS'
let s:TYPE_LAST_CONTINUOUS = 'TYPE_LAST_CONTINUOUS'
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



function! vimscript_indentexpr#exec() abort
	if 1 == v:lnum
		return 0
	endif
	let prev_info = s:prev(v:lnum)
	let curr_info = s:curr(v:lnum)

	let indent = prev_info['indent']

	if -1 != index(['vimLetHereDoc', 'vimLetHereDocStop'], curr_info['syn_name'])
		return -1
	endif

	if (s:TYPE_KEEP_CONTINUOUS == curr_info['parsed']['type'])
		" keep


	elseif (s:TYPE_CURR_CONTINUOUS == curr_info['parsed']['type']) || (s:TYPE_QUESTION == curr_info['parsed']['type'])
		if (s:TYPE_CURR_CONTINUOUS != prev_info['parsed']['type'])
			let indent += shiftwidth()
		endif

	elseif (s:TYPE_LAST_CONTINUOUS == prev_info['parsed']['type'])
		let indent -= shiftwidth()

	else
		if (s:TYPE_COLLON == prev_info['parsed']['type'])
			let indent -= shiftwidth()

		elseif (s:TYPE_CURR_CONTINUOUS == prev_info['parsed']['type'])
			let indent -= shiftwidth()
		elseif (s:TYPE_NEXT_CONTINUOUS == prev_info['parsed']['type'])
			let indent += shiftwidth()
		endif

	endif

	let p = (s:TYPE_FUNCTION == prev_info['parsed']['type']) ||
		\ (s:TYPE_AUGROUP == prev_info['parsed']['type']) ||
		\ (s:TYPE_WHILE == prev_info['parsed']['type']) ||
		\ (s:TYPE_DEF == prev_info['parsed']['type']) ||
		\ (s:TYPE_FOR == prev_info['parsed']['type']) ||
		\ (s:TYPE_TRY == prev_info['parsed']['type']) ||
		\ (s:TYPE_FINALLY == prev_info['parsed']['type']) ||
		\ (s:TYPE_CATCH == prev_info['parsed']['type']) ||
		\ (s:TYPE_IF == prev_info['parsed']['type']) ||
		\ (s:TYPE_ELSE == prev_info['parsed']['type']) ||
		\ (s:TYPE_ELSEIF == prev_info['parsed']['type'])

	let c = (s:TYPE_ENDFUNCTION == curr_info['parsed']['type']) ||
		\ (s:TYPE_ENDAUGROUP == curr_info['parsed']['type']) ||
		\ (s:TYPE_ENDWHILE == curr_info['parsed']['type']) ||
		\ (s:TYPE_ENDDEF == curr_info['parsed']['type']) ||
		\ (s:TYPE_ENDFOR == curr_info['parsed']['type']) ||
		\ (s:TYPE_FINALLY == curr_info['parsed']['type']) ||
		\ (s:TYPE_CATCH == curr_info['parsed']['type']) ||
		\ (s:TYPE_ENDTRY == curr_info['parsed']['type']) ||
		\ (s:TYPE_ENDIF == curr_info['parsed']['type']) ||
		\ (s:TYPE_ELSE == curr_info['parsed']['type']) ||
		\ (s:TYPE_ELSEIF == curr_info['parsed']['type'])

	if p
		if c
			return indent
		else
			return indent + shiftwidth()
		endif
	else
		if c
			return indent - shiftwidth()
		else
			return indent
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

	elseif s:ENABLE_VIM9 && (text =~# '^\(+\|-\|*\|/\|%\|\.\.\|->\|\.\)')
		let type = s:TYPE_CURR_CONTINUOUS

	elseif s:ENABLE_VIM9 && (text =~# '^?')
		let type = s:TYPE_QUESTION
	elseif s:ENABLE_VIM9 && (text =~# '^:') && s:expect_type(s:TYPE_QUESTION, a:lnum - 1)
		let type = s:TYPE_COLLON

	elseif s:ENABLE_VIM9 && (text =~# '\]\s*,\s*[{(\[]$') && s:expect_pair('{', '}', a:lnum)
		let type = s:TYPE_KEEP_CONTINUOUS
	elseif s:ENABLE_VIM9 && (text =~# '\]\s*,\s*[{(\[]$') && s:expect_pair('(', ')', a:lnum)
		let type = s:TYPE_KEEP_CONTINUOUS
	elseif s:ENABLE_VIM9 && (text =~# '\]\s*,\s*[{(\[]$') && s:expect_pair('\[', '\]', a:lnum)
		let type = s:TYPE_KEEP_CONTINUOUS

	elseif s:ENABLE_VIM9 && (text =~# '[{(\[]$')
		let type = s:TYPE_NEXT_CONTINUOUS
	elseif s:ENABLE_VIM9 && (text =~# '}$') && s:xxx('{', '}', a:lnum)
		let type = s:TYPE_LAST_CONTINUOUS
	elseif s:ENABLE_VIM9 && (text =~# ')$') && s:xxx('(', ')', a:lnum)
		let type = s:TYPE_LAST_CONTINUOUS
	elseif s:ENABLE_VIM9 && (text =~# '\]$') && s:xxx('\[', '\]', a:lnum)
		let type = s:TYPE_LAST_CONTINUOUS

	elseif text =~# '^\<if\>.*\<endi\%[f\]\>$'
		let type = s:TYPE_ONELINER
	elseif text =~# '^\<wh\%[ile\]\>.*\<endw\%[hile\]\>$'
		let type = s:TYPE_ONELINER
	elseif text =~# '^\<for\>.*\<endfo\%[r\]\>$'
		let type = s:TYPE_ONELINER
	elseif text =~# '^\<try\>.*\<endt\%[ry\]\>$'
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
	elseif text =~# '^\<enddef\>'
		let type = s:TYPE_ENDDEF
	elseif text =~# '^\<def\>'
		let type = s:TYPE_DEF
	else
		let type = type
	endif
	return { 'type' : type, }
endfunction

function! vimscript_indentexpr#run_tests() abort
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
	call assert_equal(vimscript_indentexpr#parse('   def', -1), { 'type' : s:TYPE_DEF, })
	call assert_equal(vimscript_indentexpr#parse('   enddef', -1), { 'type' : s:TYPE_ENDDEF, })

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

	if s:ENABLE_VIM9
		call assert_equal(vimscript_indentexpr#parse('   #en', -1), { 'type' : s:TYPE_COMMENT, })
		call assert_equal(vimscript_indentexpr#parse('   Func (', -1), { 'type' : s:TYPE_NEXT_CONTINUOUS, })
		call assert_equal(vimscript_indentexpr#parse('   Func {', -1), { 'type' : s:TYPE_NEXT_CONTINUOUS, })
		call assert_equal(vimscript_indentexpr#parse('   Func [', -1), { 'type' : s:TYPE_NEXT_CONTINUOUS, })
		call assert_equal(vimscript_indentexpr#parse('   + i', -1), { 'type' : s:TYPE_CURR_CONTINUOUS, })
		call assert_equal(vimscript_indentexpr#parse('   - i', -1), { 'type' : s:TYPE_CURR_CONTINUOUS, })
		call assert_equal(vimscript_indentexpr#parse('   * i', -1), { 'type' : s:TYPE_CURR_CONTINUOUS, })
		call assert_equal(vimscript_indentexpr#parse('   / i', -1), { 'type' : s:TYPE_CURR_CONTINUOUS, })
		call assert_equal(vimscript_indentexpr#parse('   % i', -1), { 'type' : s:TYPE_CURR_CONTINUOUS, })
		call assert_equal(vimscript_indentexpr#parse('   ->method()', -1), { 'type' : s:TYPE_CURR_CONTINUOUS, })
		call assert_equal(vimscript_indentexpr#parse('   .. str', -1), { 'type' : s:TYPE_CURR_CONTINUOUS, })
		call assert_equal(vimscript_indentexpr#parse('   .member', -1), { 'type' : s:TYPE_CURR_CONTINUOUS, })

		call s:run_test([
			\ 'Func (',
			\ 'arg)',
			\ ], [
			\ 'Func (',
			\ '    arg)',
			\ ])

		call s:run_test([
			\ 'Func (',
			\ 'arg',
			\ ')',
			\ ], [
			\ 'Func (',
			\ '    arg',
			\ '    )',
			\ ])

		call s:run_test([
			\ 'var total = m',
			\ '+ n',
			\ ], [
			\ 'var total = m',
			\ '    + n',
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
			\ '    a,',
			\ '    b,',
			\ '    c,',
			\ '    d]',
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
			\ '    a,',
			\ '    b,',
			\ '    c,',
			\ '    d], [',
			\ '    e,',
			\ '    f,',
			\ '    g,',
			\ '    h]',
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
			\ '    a,',
			\ '    b,',
			\ '    c,',
			\ '    d])',
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
			\ '    a,',
			\ '    b,',
			\ '    c,',
			\ '    d])',
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
			\ '    a,',
			\ '    b,',
			\ '    c,',
			\ '    d])',
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
			\ '    ? 1',
			\ '    : 2',
			\ 'echo 234',
			\ ':2',
			\ ])

		call s:run_test([
			\ 'x',
			\ '->method()',
			\ '->method()',
			\ '->method()',
			\ '->method()',
			\ ], [
			\ 'x',
			\ '    ->method()',
			\ '    ->method()',
			\ '    ->method()',
			\ '    ->method()',
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
			\ '        ? 1',
			\ '        : 2',
			\ '    echo 234',
			\ '    :2',
			\ '    echo 234',
			\ 'endif',
			\ ])
	endif

	if !empty(v:errors)
		call writefile(v:errors, s:TEST_LOG)
		for err in v:errors
			let xs = split(err, '\(Expected\|but got\)')
			echohl Error
			if 3 == len(xs)
				echo xs[0]
				echo '  Expected ' .. xs[1]
				echo '  but got  ' .. xs[2]
			else
				echo err
			endif
			echohl None
		endfor
	endif
endfunction



function! s:expect_pair(st, ed, n) abort
	let saved = getcurpos()
	call setpos('.', [0, a:n, 0, 0])
	let lnum = searchpairpos(a:st, '', a:ed, 'bn')[0]
	call setpos('.', saved)
	if (1 <= lnum) && (lnum <= line('$')) && (a:n != lnum)
		let x = vimscript_indentexpr#parse(getline(lnum), lnum)
		return (x['type'] == s:TYPE_NEXT_CONTINUOUS) || (x['type'] == s:TYPE_KEEP_CONTINUOUS)
	else
		return v:false
	endif
endfunction

function! s:expect_type(t, n) abort
	let x = vimscript_indentexpr#parse(getline(a:n), a:n)
	return x['type'] == a:t
endfunction

function! s:prev(lnum) abort
	let prev_lnum = prevnonblank(a:lnum - 1)
	while (-1 != index(['vimLetHereDoc', 'vimLetHereDocStop'], synIDattr(synID(prev_lnum, 1, 1), 'name'))) && (1 < prev_lnum)
		let prev_lnum = prevnonblank(prev_lnum - 1)
	endwhile
	let syn_name = synIDattr(synID(prev_lnum, 1, 1), 'name')
	let line = getline(prev_lnum)
	let parsed = vimscript_indentexpr#parse(line, prev_lnum)
	let indent = indent(prev_lnum)
	return { 'syn_name' : syn_name, 'line' : line, 'parsed' : parsed, 'indent' : indent, }
endfunction

function! s:curr(lnum) abort
	let syn_name = synIDattr(synID(a:lnum, 1, 1), 'name')
	let line = getline(a:lnum)
	let parsed = vimscript_indentexpr#parse(line, -1)
	return { 'syn_name' : syn_name, 'line' : line, 'parsed' : parsed, }
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
	call assert_equal(formatted_lines, a:expect)
endfunction

