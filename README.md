
# vim-vimscript_indentexpr

[![vim](https://github.com/rbtnn/vim-vimscript_indentexpr/workflows/vim/badge.svg)](https://github.com/rbtnn/vim-vimscript_indentexpr/actions?query=workflow%3Avim)
[![neovim](https://github.com/rbtnn/vim-vimscript_indentexpr/workflows/neovim/badge.svg)](https://github.com/rbtnn/vim-vimscript_indentexpr/actions?query=workflow%3Aneovim)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

This plugin provides to format Vim script's codes.

## Why I create this

1. Writing a Vim script, I use `gg=G` to format the codes as follows:

```
autocmd FileType vim
    \ : if 1
    \ |     echo 1234
    \ | else
    \ |     echo 5678
    \ | endif
```

But the formatted codes is so bad.

```
autocmd FileType vim
    \ : if 1
    \ |     echo 1234
    \ | else
        \ |     echo 5678
        \ | endif
```

2. `gg=G` is that cursor position is not keeping.

3. `gg=G` is that heredoc is not keeping.

## Installation

This is an example of installation using [vim-plug](https://github.com/junegunn/vim-plug).

```
Plug 'rbtnn/vim-vimscript_indentexpr'
```

## Concepts
* This plugin supports Vim and Neovim.

