command! -range GetCurrentBranchLink <line1>,<line2>call s:get_current_branch_link()
function! s:get_current_branch_link() range
    let s:currentdir = getcwd()
    lcd %:p:h
    let s:remote = system("git config --get remote.origin.url")
    if empty(matchstr(s:remote, '.*github.*'))
        return
    endif
    let s:repo = substitute(matchstr(s:remote, "github.com.*/[a-zA-Z0-9_-]*"), ":", "/", "g")
    let s:branch = system("git rev-parse --abbrev-ref HEAD")
    let s:root = system("git rev-parse --show-toplevel")

    let s:path_from_root = strpart(expand('%:p'), strlen(s:root))

    " https://github.com/OWNER/REPO/blob/BRANCH/PATH/FROM/ROOT#LN-LM
    let s:link = "https://" . s:repo . "/blob/" . s:branch . "/" . s:path_from_root
    if a:firstline == a:lastline
        let s:link = s:link . "#L" . a:firstline
    else
        let s:link = s:link . "#L" . a:firstline . "-L".a:lastline
    endif
    let @+ = s:link
    execute 'lcd' . s:currentdir
endfunction
