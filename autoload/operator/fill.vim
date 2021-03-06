let s:save_cpo = &cpo
set cpo&vim

function! operator#fill#strfill(src, char) abort
  let builder = split(a:src, "\n", 1)
  for i in range(len(builder))
    let builder[i] = repeat(a:char, strdisplaywidth(builder[i]))
  endfor
  return join(builder, "\n")
endfunction

let s:operator = {
\   'is_repeating': 0,
\   'char': '',
\ }

function! s:operator.setchar() abort
  if !self.is_repeating
    let char = getchar()
    let self.char = (type(char) == type(0))? nr2char(char): char
    let self.is_repeating = 1
  endif
endfunction

function! s:operator.canceled() abort
  return self.char == "\<C-[>"
endfunction

function! s:operator.fill(motion_wise) abort
  if a:motion_wise == 'block'
    execute "normal! `[\<C-v>`]r" . self.char
  else
    let v = operator#user#visual_command_from_wise_name(a:motion_wise)
    try
      let sel_save     = &l:selection
      let &l:selection = 'inclusive'
      let reg_save     = getreg('z')
      let regtype_save = getregtype('z')
      execute 'normal!' '`[' . v . '`]"zy'
      let src = getreg('z')
      let dst = operator#fill#strfill(src, self.char)
      call setreg('z', dst)
      execute 'normal! `[' . v . '`]"zp'
      execute 'normal! `['
    finally
      let &l:selection = sel_save
      call setreg('z', reg_save, regtype_save)
    endtry
  endif
endfunction

function! operator#fill#initialize() abort
  let s:operator.is_repeating = 0
endfunction

function! operator#fill#fill(motion_wise) abort
  silent call s:operator.setchar()
  if s:operator.canceled()
    return
  endif
  silent call s:operator.fill(a:motion_wise)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
