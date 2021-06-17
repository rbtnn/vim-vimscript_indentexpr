
# vim-vimscript_indentexpr

[![vim](https://github.com/rbtnn/vim-vimscript_indentexpr/workflows/vim/badge.svg)](https://github.com/rbtnn/vim-vimscript_indentexpr/actions?query=workflow%3Avim)
[![neovim](https://github.com/rbtnn/vim-vimscript_indentexpr/workflows/neovim/badge.svg)](https://github.com/rbtnn/vim-vimscript_indentexpr/actions?query=workflow%3Aneovim)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

This plugin provides to format legacy Vim script and Vim9 script if possible.

## Samples

## Sample.1
__before__
```
augroup xxx
autocmd!
autocmd FileType vim
\ : if 1
\ |     echo 1234
\ | else
\ |     echo 5678
\ | endif
augroup END
```
__after__
```
augroup xxx
    autocmd!
    autocmd FileType vim
        \ : if 1
        \ |     echo 1234
        \ | else
        \ |     echo 5678
        \ | endif
augroup END
```

## Sample.2 (Vim9 syntax)
__before__
```
if v:true
let a = p
? 1
: 2
echo 234
:2
echo 234
endif
```
__after__
```
if v:true
    let a = p
        ? 1
        : 2
    echo 234
    :2
    echo 234
endif
```

## Sample.3 (Vim9 syntax)
__before__
```
x
->method()
->method()
->method()
->method()
F()
```
__after__
```
x
    ->method()
    ->method()
    ->method()
    ->method()
F()
```

## Sample.4 (Vim9 syntax)
__before__
```
def outter()
echo 12
def inner()
echo 34
enddef
enddef
```
__after__
```
def outter()
    echo 12
    def inner()
        echo 34
    enddef
enddef
```

## Sample.5 (Vim9 syntax)
__before__
```
Func (
arg
)
echo 123
```
__after__
```
Func (
    arg
    )
echo 123
```

## Sample.6 (Vim9 syntax)
__before__
```
var total = m
+ n
echo 123
```
__after__
```
var total = m
    + n
echo 123
```

## Sample.7 (Vim9 syntax)
__before__
```
var xs = [
a,
b,
c,
d], [
e,
f,
g,
h]
m()
```
__after__
```
var xs = [
    a,
    b,
    c,
    d], [
    e,
    f,
    g,
    h]
m()
```


## Installation

This is an example of installation using [vim-plug](https://github.com/junegunn/vim-plug).

```
Plug 'rbtnn/vim-vimscript_indentexpr'
```

## Concepts
* This plugin supports Vim and Neovim.

