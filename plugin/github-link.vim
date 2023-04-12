command! -range GetCommitLink <line1>,<line2>call s:get_commit_link("file")
command! -range GetCurrentBranchLink <line1>,<line2>call s:get_commit_link("branch")
command! -range GetCurrentCommitLink <line1>,<line2>call s:get_commit_link("head")

function! s:get_commit_link(which_ref) range
    let s:currentdir = getcwd()
    lcd %:p:h
    if a:which_ref == "branch"
      let s:ref = system("git rev-parse --abbrev-ref HEAD")
    elseif a:which_ref == "head"
      let s:ref = system("git rev-parse HEAD")
    elseif a:which_ref == "file"
      let s:ref = system("git rev-list -1 HEAD -- " . shellescape(expand('%')))
    else
      echoerr "Unknown ref type '" . a:which_ref . "'"
      return
    endif
    call s:execute_with_ref(s:ref, a:firstline, a:lastline)
    execute 'lcd' . s:currentdir
endfunction

function! s:execute_with_ref(ref, startline, endline)
    let s:remote = system("git ls-remote --get-url origin")
    if s:remote !~ '.*[github|gitlab].*'
        echoerr "Unknown remote host"
        return
    endif

    let s:repo = ''
    if s:remote =~ '^git'
        let s:repo = s:get_repo_url_from_git_protocol(s:remote)
    elseif s:remote =~ '^ssh'
        let s:repo = s:get_repo_url_from_ssh_protocol(s:remote)
    elseif s:remote =~ '^https'
        let s:repo = s:get_repo_url_from_https_protocol(s:remote)
    else
        echoerr "Remote doesn't match any known protocol"
        return
    endif

    let s:root = system("git rev-parse --show-toplevel")
    let s:path_from_root = strpart(expand('%:p'), strlen(s:root))

    " https://github.com/OWNER/REPO/blob/BRANCH/PATH/FROM/ROOT#LN-LM
    let s:link = s:repo . "/blob/" . a:ref . "/" . s:url_encode_path_segments(s:path_from_root)

    " Check for doc extensions and add plain query parameter, because otherwise
    " GitHub ignores the line highlight
    if s:link =~? '\v.*\.(md|rst|markdown|mdown|mkdn|md|textile|rdoc|org|creole|mediawiki|wiki|rst|asciidoc|adoc|asc|pod)$' && s:remote =~ '.*github.*'
        let s:link = s:link . "?plain=1"
    endif

    if a:startline == a:endline
        let s:link = s:link . "#L" . a:startline
    else
        if s:remote =~ '.*github.*'
            let s:link = s:link . "#L" . a:startline . "-L". a:endline
        elseif s:remote =~ '.*gitlab.*'
            let s:link = s:link . "#L" . a:startline . "-". a:endline
        endif
    endif
    let s:link = substitute(s:link, "[\n\t ]", "", "g")
    let @+ = s:link
    echo 'copied ' . s:link
endfunction

function! s:get_repo_url_from_git_protocol(uri)
    let s:matches = matchlist(a:uri, '^git@\(.*\):\(.*\)$')
    return "https://" . s:matches[1] .'/' . s:trim_git_suffix(s:matches[2])
endfunction

function! s:get_repo_url_from_ssh_protocol(uri)
    let s:matches = matchlist(a:uri, '^ssh:\/\/git@\(.\{-\}\)\/\(.*\)$')
    return "https://" . s:matches[1] .'/' . s:trim_git_suffix(s:matches[2])
endfunction

function! s:get_repo_url_from_https_protocol(uri)
    let s:matches = matchlist(a:uri, '^https:\/\/\(.*@\)\?\(.*\)$')
    return "https://" . s:trim_git_suffix(s:matches[2])
endfunction

function! s:trim_git_suffix(str)
    " strip whitespace such as trailing \r from git command output
    let s:nospace = substitute(a:str, '[[:space:]]', '', 'g')
    return substitute(s:nospace, '\.git$', '', '')
endfunction

" copied from tpope/vim-unimpaired
function! s:url_encode(str) abort
  " iconv trick to convert utf-8 bytes to 8bits indiviual char.
  return substitute(iconv(a:str, 'latin1', 'utf-8'),'[^A-Za-z0-9_.~-]','\="%".printf("%02X",char2nr(submatch(0)))','g')
endfunction

" take a string representing a filepath and url encode the names of all of the
" files and directories
function! s:url_encode_path_segments(path) abort
    let s:segments = split(a:path, '/')
    let s:encoded_segments = map(s:segments, 's:url_encode(v:val)')
    return join(s:encoded_segments, '/')
endfunction
