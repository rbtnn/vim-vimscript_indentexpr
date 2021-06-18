
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

## Examples
Following examples are before/after when using `gg=G`.  
`shiftwidth()` is `4` and `g:vim_indent_cont` is `2` in following examples.  

* __Augroup (legacy)__

    *before*
    ```vim
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
    *after*
    ```vim
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

* __Heredoc (legacy)__

    *before*
    ```vim
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
    *after*
    ```vim
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

* __Binary operators (Vim9)__

    *before*
    ```vim
    if v:true
    let a = p
    ? 1
    : 2
    echo 234
    :2
    echo 234
    endif
    ```
    *after*
    ```vim
    if v:true
        let a = p
          ? 1
          : 2
        echo 234
        :2
        echo 234
    endif
    ```

* __Continues method (Vim9)__

    *before*
    ```vim
    x
    ->method()
    ->method()
    ->method()
    ->method()
    F()
    ```
    *after*
    ```vim
    x
      ->method()
      ->method()
      ->method()
      ->method()
    F()
    ```

* __Def (Vim9)__

    *before*
    ```vim
    def outter()
    echo 12
    def inner()
    echo 34
    enddef
    enddef
    ```
    *after*
    ```vim
    def outter()
        echo 12
        def inner()
            echo 34
        enddef
    enddef
    ```

* __Continues parenthesis (Vim9)__

    *before*
    ```vim
    Func (
    arg
    )
    echo 123
    ```
    *after*
    ```vim
    Func (
      arg
      )
    echo 123
    ```

* __Continues expr (Vim9)__

    *before*
    ```vim
    var total = m
    + n
    echo 123
    ```
    *after*
    ```vim
    var total = m
      + n
    echo 123
    ```

* __Continues expr (Vim9)__

    *before*
    ```vim
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
    *after*
    ```vim
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

* __Block (Vim9)__

    *before*
    ```vim
    {
    let n = a
    + b
    return n
    }
    ```
    *after*
    ```vim
    {
        let n = a
          + b
        return n
    }
    ```

* __Block (Vim9)__

    *before*
    ```vim
    var Lambda = (arg) =>
    {
    let n = a
    + b
    return n
    }
    echo 123
    ```
    *after*
    ```vim
    var Lambda = (arg) =>
     {
         let n = a
           + b
         return n
     }
     echo 123
    ```
    NOTE: This recognizes Block but Lambda and Block.

* __Lambda and Block (Vim9)__

    *before*
    ```vim
    var Lambda = (arg) => {
    let n = a
    + b
    return n
    }
    echo 123
    ```
    *after*
    ```vim
    var Lambda = (arg) => {
         let n = a
           + b
         return n
     }
    echo 123
    ```

* __Dictionary (Vim9)__

    *before*
    ```vim
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
    *after*
    ```vim
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

