vim9script
if expand('<sfile>:p') !=# expand('%:p') && exists('g:loaded_yankround')
  finish
endif
g:loaded_yankround = 1

scriptencoding utf-8

# =============================================================================
g:yankround_dir = get(g:, 'yankround_dir', '~/.config/vim/yankround')
g:yankround_max_history = get(g:, 'yankround_max_history', 30)
g:yankround_max_element_length = get(g:, 'yankround_max_element_length', 512000)
# =============================================================================

var yankround_dir = expand(g:yankround_dir)
if yankround_dir != '' && !isdirectory(yankround_dir)
  call mkdir(yankround_dir, 'p')
endif

var history_path = yankround_dir .. '/history'
var is_readable = filereadable(history_path)
g:YankroundCache = is_readable ? readfile(history_path) : []
var HistFileVer = is_readable ? getftime(history_path) : 0
g:YankroundStopCaching = 0

augroup yankround
  autocmd!
  autocmd TextYankPost * Yankround_append()
  autocmd VimLeavePre * Persistent()
augroup END

def Yankround_append()
  ReloadHistory()
  var reg_content = @"
  var cache_0_content = get(g:YankroundCache, 0, '') -> substitute('^.\d*\t', '', '')

  if g:YankroundStopCaching || reg_content ==# cache_0_content || reg_content =~# '^.\?$'
    return
  endif

  if g:yankround_max_element_length != 0 && strlen(reg_content) > g:yankround_max_element_length
    return
  endif

  call insert(g:YankroundCache, getregtype('"') .. "\t" .. reg_content)
  g:YankroundCache = DupliMiller(g:YankroundCache)

  if len(g:YankroundCache) > g:yankround_max_history
    call remove(g:YankroundCache, g:yankround_max_history, -1)
  endif
  Persistent()
enddef

# �X�N���v�g���[�J���֐�: Persistent �ɕύX
def Persistent()
  if g:yankround_dir == '' || g:YankroundCache == []
    return
  endif
  var path = yankround_dir .. '/history'
  call writefile(g:YankroundCache, path)
  HistFileVer = getftime(path)
enddef

def ReloadHistory()
  if g:yankround_dir == ''
    return
  endif
  var path = expand(g:yankround_dir) .. '/history'
  if !filereadable(path) || getftime(path) <= HistFileVer
    return
  endif
  g:YankroundCache = readfile(path)
  HistFileVer = getftime(path)
enddef

# =============================================================================
# Misc:
def DupliMiller(list_in: list<any>): list<any>
  # ���ʂ��i�[���郊�X�g
  var result: list<any> = []
  # ���Ɍ��ʃ��X�g�ɒǉ����ꂽ�v�f���L�^����W�� (�������g�p)
  var seen: dict<number> = {}

  # ���X�g�������ɑ������� (�ŏ�����Ō��)
  for item in list_in
    var item_str = string(item)

    # 'item'���܂�'seen'�W���ɑ��݂��Ȃ��ꍇ (�ŏ��ɏo�������ꍇ)
    if !has_key(seen, item_str)
      # 'item'��'result'�̖����ɒǉ� (�ŏ��ɏo�������v�f��ێ�)
      result->add(item)
      # 'item'��'seen'�W���ɒǉ�
      seen[item_str] = 1
    # else: ����'seen'�ɑ��݂���ꍇ (�ォ��o�������d��) �͉������Ȃ� (�폜)
    endif
  endfor

  return result
enddef

# =============================================================================
# END