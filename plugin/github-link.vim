command! -range=% GetBranchLink <line1>,<line2>call s:getbranchlink()
function! s:getbranchlink() range
    let currentdir = getcwd()
    echo currentdir
    let fullpath = expand('%:p:h')
    echo fullpath
    let remote = system("git config --get remote.origin.url")
    echo remote
    if empty(matchstr(remote, '.*github.*'))
        echo "no github!"
        return
    endif
    let repo = substitute(matchstr(remote, "github.com.*/[a-zA-Z0-9_-]*"), ":", "/", "g")
    echo repo
    let branch = system("git rev-parse --abbrev-ref HEAD")
    let root = system("git rev-parse --show-toplevel")

    " https://github.com/OWNER/REPO/blob/BRANCH/PATH/FROM/ROOT.go#L1-L3
    echo a:firstline
    echo a:lastline
"    lcd currentdir
endfunction
