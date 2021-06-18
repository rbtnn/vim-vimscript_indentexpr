
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
Following examples are before/after when using `gg=G`.  
`shiftwidth()` is `4` and `g:vim_indent_cont` is `2` in following examples.  

* __Augroup (legacy)__

    *before*
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
    *after*
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

* __Heredoc (legacy)__

    *before*
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
    *after*
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

* __Binary operators (Vim9)__

    *before*
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
    *after*
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

* __Continues method (Vim9)__

    *before*
    ```
    x
    ->method()
    ->method()
    ->method()
    ->method()
    F()
    ```
    *after*
    ```
    x
      ->method()
      ->method()
      ->method()
      ->method()
    F()
    ```

* __Def (Vim9)__

    *before*
    ```
    def outter()
    echo 12
    def inner()
    echo 34
    enddef
    enddef
    ```
    *after*
    ```
    def outter()
        echo 12
        def inner()
            echo 34
        enddef
    enddef
    ```

* __Continues parenthesis (Vim9)__

    *before*
    ```
    Func (
    arg
    )
    echo 123
    ```
    *after*
    ```
    Func (
      arg
      )
    echo 123
    ```

* __Continues expr (Vim9)__

    *before*
    ```
    var total = m
    + n
    echo 123
    ```
    *after*
    ```
    var total = m
      + n
    echo 123
    ```

* __Continues expr (Vim9)__

    *before*
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
    *after*
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

* __Block (Vim9)__

    *before*
    ```
    {
    let n = a
    + b
    return n
    }
    ```
    *after*
    ```
    {
        let n = a
          + b
        return n
    }
    ```

* __Block (Vim9)__

    *before*
    ```
    var Lambda = (arg) =>
    {
    let n = a
    + b
    return n
    }
    echo 123
    ```
    *after*
    ```
    var Lambda = (arg) =>
     {
         let n = a
           + b
         return n
     }
     echo 123
    ```
    NOTE: This recognizes block but lambda and block.

* __Lambda and Block (Vim9)__

    *before*
    ```
    var Lambda = (arg) => {
    let n = a
    + b
    return n
    }
    echo 123
    ```
    *after*
    ```
    var Lambda = (arg) => {
         let n = a
           + b
         return n
     }
    echo 123
    ```

* __Dictionary (Vim9)__

    *before*
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
    *after*
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

