if expand('<sfile>:p')!=#expand('%:p') && exists('g:loaded_yankround')| finish| endif| let g:loaded_yankround = 1
let s:save_cpo = &cpo| set cpo&vim
scriptencoding utf-8
"=============================================================================
let g:yankround_dir = get(g:, 'yankround_dir', '~/.config/vim/yankround')
let g:yankround_max_history = get(g:, 'yankround_max_history', 30)
let g:yankround_max_element_length = get(g:, 'yankround_max_element_length', 512000)
"=============================================================================

let s:yankround_dir = expand(g:yankround_dir)
if !(s:yankround_dir=='' || isdirectory(s:yankround_dir))
  call mkdir(s:yankround_dir, 'p')
end

let s:path = s:yankround_dir. '/history'
let s:is_readable = filereadable(s:path)
let g:_yankround_cache = s:is_readable ? readfile(s:path) : []
let s:_histfilever = s:is_readable ? getftime(s:path) : 0
unlet s:path s:is_readable
let g:_yankround_stop_caching = 0

aug yankround
  autocmd!
  autocmd TextYankPost *   call Yankround_append()
  autocmd VimLeavePre *   call s:_persistent()
aug END

function! Yankround_append() "{{{
  call s:_reloadhistory()
  if g:_yankround_stop_caching || @" ==# substitute(get(g:_yankround_cache, 0, ''), '^.\d*\t', '', '') || @"=~'^.\?$'
    \ || g:yankround_max_element_length!=0 && strlen(@")>g:yankround_max_element_length
    return
  end
  call insert(g:_yankround_cache, getregtype('"'). "\t". @")
  call s:newDupliMiller().mill(g:_yankround_cache)
  if len(g:_yankround_cache) > g:yankround_max_history
    call remove(g:_yankround_cache, g:yankround_max_history, -1)
  end
  call s:_persistent()
endfunction
"}}}
function! s:_persistent() "{{{
  if g:yankround_dir=='' || g:_yankround_cache==[]
    return
  end
  let path = s:yankround_dir. '/history'
  call writefile(g:_yankround_cache, path)
  let s:_histfilever = getftime(path)
endfunction
"}}}
function! s:_reloadhistory() "{{{
  if g:yankround_dir==''
    return
  end
  let path = expand(g:yankround_dir). '/history'
  if !filereadable(path) || getftime(path) <= s:_histfilever
    return
  end
  let g:_yankround_cache = readfile(path)
  let s:_histfilever = getftime(path)
endfunction
"}}}

"=============================================================================
"Misc:
let s:DupliMiller = {}
function! s:newDupliMiller() "{{{
  let obj = copy(s:DupliMiller)
  let obj.seens = {}
  return obj
endfunction
"}}}
function! s:DupliMiller._is_firstseen(str) "{{{
  if has_key(self.seens, a:str)
    return
  end
  if a:str!=''
    let self.seens[a:str] = 1
  end
  return 1
endfunction
"}}}
function! s:DupliMiller.mill(list) "{{{
  return filter(a:list, 'self._is_firstseen(v:val)')
endfunction
"}}}

"=============================================================================
"END "{{{1
let &cpo = s:save_cpo| unlet s:save_cpo
