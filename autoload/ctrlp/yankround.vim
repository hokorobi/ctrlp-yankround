vim9script
# =============================================================================
var CtrlpBuiltins = ctrlp#getvar('g:ctrlp_builtins')
# =======================================
var CtrlpYankroundVar = {
  lname: 'yankround',
  sname: 'ykrd',
  type: 'tabe',
  sort: 0,
  nolim: 1,
  opmul: 1
}
CtrlpYankroundVar.init = 'ctrlp#yankround#Init()'
CtrlpYankroundVar.accept = 'ctrlp#yankround#Accept'
CtrlpYankroundVar.wipe = 'ctrlp#yankround#Wipe'
g:ctrlp_ext_vars = get(g:, 'ctrlp_ext_vars', []) -> add(CtrlpYankroundVar)

var IndexId = CtrlpBuiltins + len(g:ctrlp_ext_vars)

export def Id(): number
  return IndexId
enddef

export def Init(): list<string>
  return copy(g:YankroundCache) -> map((_, v) => CacheToCtrlpLine(v))
enddef

export def Accept(action: string, str: string)
  if action == 't'
    return
  endif

  ctrlp#exit()
  var strlist = copy(g:YankroundCache) -> map((_, v) => CacheToCtrlpLine(v))
  var idx = index(strlist, str)
  var [yank_str, regtype] = GetCacheAndRegtype(idx)
  setreg('"', yank_str, regtype)

  if action == 'e'
    execute 'normal! p'
  elseif action == 'v'
    execute 'normal! P'
  endif
enddef

export def Wipe(entries: list<string>): list<string>
  if len(entries) == 0
    g:YankroundCache = []
    return ctrlp#yankround#Init()
  endif

  var strlist = copy(g:YankroundCache) -> map((_, v) => CacheToCtrlpLine(v))
  var removed_list = []
  var idx: number
  for item in entries
    idx = index(strlist, item)
    remove(g:YankroundCache, idx)
  endfor
  return ctrlp#yankround#Init()
enddef

# =======================================
def CacheToCtrlpLine(str: string): string
  var entry = matchlist(str, '^.\d*\t\(.*\)')
  return strtrans(entry[1])
enddef

def GetCacheAndRegtype(idx: number): list<string>
  var ret = matchlist(g:YankroundCache[idx], '^\(.\d*\)\t\(.*\)')
  return [ret[2], ret[1]]
enddef

# =============================================================================
# END