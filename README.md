vim-github-link
---

Set link for github.com to Clipboard.

generate url like `https://github.com/OWNER/REPO/blob/BRANCH/PATH/TO/FILE#L1-L10` and copy it to clipboard.
there is 2 functions.
1. generate link with current branch. like master or develop.
2. generate link with current commit hash. url may be not found if you dont push to remote yet.

# Usage
In normal mode

```
:1,3GetCurrentBranchLink
```
then link is copied to your clipboard.

In visual mode, same command after selected.

# Install
## dein.vim
add below line into .vimrc 

```
call dein#add('knsh14/vim-github-link')
```

or add to toml file

```
[[plugins]]
repo = 'knsh14/vim-github-link'
```

## vim-plug

```
Plug 'knsh14/vim-github-link'
```
