if exists('s:save_cpo')| finish| endif
let s:save_cpo = &cpo| set cpo&vim
"=============================================================================

function! yankround#_get_cache_and_regtype(idx) "{{{
  let ret = matchlist(g:_yankround_cache[a:idx], '^\(.\d*\)\t\(.*\)')
  return [ret[2], ret[1]]
endfunction
"}}}

"=============================================================================
"END "{{{1
let &cpo = s:save_cpo| unlet s:save_cpo
