" function! SetAppearance()
"   if v:os_appearance == 1
"     colorscheme seoul256
"     highlight! VertSplit guifg=white guibg=NONE
"   else
"     colorscheme seoul256-light
"     highlight! VertSplit guifg=black guibg=NONE
"   endif
" endfunction

" autocmd OSAppearanceChanged * call SetAppearance()
" call SetAppearance()

autocmd VimEnter * highlight VertSplit guifg=white guibg=NONE

set guifont=D2Coding\ ligature:h18
set guioptions+=e
set guioptions-=T
set guioptions-=m
set guioptions-=l
set guioptions-=L
set guioptions-=r
set guioptions-=R
set visualbell t_vb=
set guicursor+=a:blinkon0

set fillchars+=vert:│

if has('win32')
  au GUIEnter * simalt ~x
elseif has('mac')
  set fuoptions=maxvert,maxhorz
endif

" set a valid swap file location
if has('win32')
  set directory=%TEMP%
endif

" turn off beeping and prevent screen lighting flash
if has('win32')
  set noerrorbells visualbell t_vb=
  autocmd GUIEnter * set visualbell t_vb=
endif
