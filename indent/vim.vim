" for overrides $VIMRUNTIME/indent/vim.vim

if &indentexpr != 'GetVimIndent()'
	if exists("b:did_indent")
		finish
	endif
endif
let b:did_indent = 1

setlocal indentexpr=vimscript_indentexpr#exec()
