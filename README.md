
# vim-vimscript_formatter

[![vim](https://github.com/rbtnn/vim-vimscript_formatter/workflows/vim/badge.svg)](https://github.com/rbtnn/vim-vimscript_formatter/actions?query=workflow%3Avim)
[![neovim](https://github.com/rbtnn/vim-vimscript_formatter/workflows/neovim/badge.svg)](https://github.com/rbtnn/vim-vimscript_formatter/actions?query=workflow%3Aneovim)
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
Plug 'rbtnn/vim-vimscript_formatter'
```

## Usage

### :VimscriptFormatter
Format Vim script codes. This command fix issues of [Why I create this](https://github.com/rbtnn/vim-vimscript_formatter#why-i-create-this).

### g:vimscript_formatter_replace_indentexpr (default: 1)
When `g:vimscript_formatter_replace_indentexpr` is non-zero, set `&indentexpr` in a buffer that `&filetype` is vim.  
When `g:vimscript_formatter_replace_indentexpr` is zero, does not set `&indentexpr` in a buffer that `&filetype` is vim.  
This variable must be set before loading this plugin.

## Concepts
* This plugin supports Vim and Neovim.

