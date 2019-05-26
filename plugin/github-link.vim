command! -range GetCurrentBranchLink <line1>,<line2>call s:get_current_branch_link()
function! s:get_current_branch_link() range
    let s:currentdir = getcwd()
    lcd %:p:h
    let s:branch = system("git rev-parse --abbrev-ref HEAD")
    call s:execute_with_commit(s:branch, a:firstline, a:lastline)
    execute 'lcd' . s:currentdir
endfunction

command! -range GetCurrentCommitLink <line1>,<line2>call s:get_current_commit_link()
function! s:get_current_commit_link() range
    let s:currentdir = getcwd()
    lcd %:p:h
    let s:commit = system("git rev-parse HEAD")
    call s:execute_with_commit(s:commit, a:firstline, a:lastline)
    execute 'lcd' . s:currentdir
endfunction

function! s:execute_with_commit(commit, startline, endline)
    let s:remote = system("git config --get remote.origin.url")
    if s:remote !~ '.*[github|gitlab].*'
        return
    endif
    let s:repo = ''
    if s:remote =~ '^git'
        let s:repo = s:get_repo_url_from_git_protocol(s:remote)
    elseif s:remote =~ '^https'
        let s:repo = s:get_repo_url_from_https_protocol(s:remote)
    else
        echo "not match any protocol schema"
        return
    endif
    let s:root = system("git rev-parse --show-toplevel")

    let s:path_from_root = strpart(expand('%:p'), strlen(s:root))

    " https://github.com/OWNER/REPO/blob/BRANCH/PATH/FROM/ROOT#LN-LM
    let s:link = s:repo . "/blob/" . a:commit . "/" . s:path_from_root
    if a:startline == a:endline
        let s:link = s:link . "#L" . a:startline
    else
        let s:link = s:link . "#L" . a:startline . "-L". a:endline
    endif
    let @+ = s:link
    echo 'copied ' . s:link
endfunction

function! s:get_repo_url_from_git_protocol(uri)
    let s:matches = matchlist(a:uri, '^git@\(.*\):\(.*\).git')
    return "https://" . s:matches[1] .'/' . s:matches[2]
endfunction

function! s:get_repo_url_from_https_protocol(uri)
    let s:matches = matchlist(a:uri, '^\(.*\).git')
    return s:matches[1]
endfunction
