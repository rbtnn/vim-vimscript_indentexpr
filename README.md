
# vim-vimscript_indentexpr

[![vim](https://github.com/rbtnn/vim-vimscript_indentexpr/workflows/vim/badge.svg)](https://github.com/rbtnn/vim-vimscript_indentexpr/actions?query=workflow%3Avim)
[![neovim](https://github.com/rbtnn/vim-vimscript_indentexpr/workflows/neovim/badge.svg)](https://github.com/rbtnn/vim-vimscript_indentexpr/actions?query=workflow%3Aneovim)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Features
* Supports Vim and Neovim.
* Supports legacy Vim script syntax and Vim9 script syntax if possible.
* Uses `g:vim_indent_cont` when indenting of continues line.

## Installation

This is an example of installation using [vim-plug](https://github.com/junegunn/vim-plug).

```
Plug 'rbtnn/vim-vimscript_indentexpr'
```

## Samples

`shiftwidth()` is `4` and `g:vim_indent_cont` is `2` in following samples.

### augroup (legacy)
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

### heredoc (legacy)
__before__
```
if v:true
var lines =<< trim END
text text text
   text text text
text text text
       text text
   text text text
         text text text
END
echo 123
else
echo 456
endif
```
__after__
```
if v:true
    var lines =<< trim END
text text text
   text text text
text text text
       text text
   text text text
         text text text
END
    echo 123
else
    echo 456
endif
```

### binary operators (Vim9)
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

### continues method (Vim9)
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

### def (Vim9)
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

### continues parenthesis (Vim9)
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

### continues expr (Vim9)
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

### continues array (Vim9)
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

### block (Vim9)
__before__
```
{
let n = a
+ b
return n
}
```
__after__
```
{
    let n = a
      + b
    return n
}
```

### block (Vim9)
__before__
```
var Lambda = (arg) =>
{
let n = a
+ b
return n
}
echo 123
```
__after__
This recognizes block but lambda and block.
```
var Lambda = (arg) =>
 {
     let n = a
       + b
     return n
 }
 echo 123
```

### lambda and block (Vim9)
__before__
```
var Lambda = (arg) => {
let n = a
+ b
return n
}
echo 123
```
__after__
```
var Lambda = (arg) => {
     let n = a
       + b
     return n
 }
echo 123
```

### dictionary (Vim9)
__before__
```
if v:true
popup_setoptions(winid, {
"title": "xyz",
})
else
popup_setoptions(winid, {
"title": "abc",
})
endif
```
__after__
```
if v:true
    popup_setoptions(winid, {
          "title": "xyz",
      })
else
    popup_setoptions(winid, {
          "title": "abc",
      })
endif
```

