" GUI settings, mirroring ~/.emacs.d/early-init.el and init.el frame settings.
" Bells, 'fillchars', and swap files are handled in .vimrc.

" default-frame-alist font; Nix-managed (nerd-fonts.d2coding), with fallbacks.
set guifont=D2CodingLigature\ Nerd\ Font:h18,D2Coding:h18,Menlo:h18

" menu-bar/tool-bar/scroll-bar off, GUI tab bar (tab-bar-mode), and
" frame-inhibit-implied-resize (k).
set guioptions-=T guioptions-=m guioptions-=l guioptions-=L guioptions-=r guioptions-=R
set guioptions+=e guioptions+=k

" blink-cursor-mode nil
set guicursor+=a:blinkon0

if has('gui_macvim')
  " mac-option-modifier 'meta
  set macmeta
  " (fullscreen . fullboth) with ns-use-native-fullscreen (MacVim's default).
  set fuoptions=maxvert,maxhorz
  autocmd GUIEnter * set fullscreen

  " tab-bar keys; <D-{>/<D-}> are already bound by MacVim, and <D-,> is
  " reserved for MacVim's Settings.
  nnoremap <D-[> gT
  nnoremap <D-]> gt
  nnoremap <D-.> <Cmd>tabnew<CR>

  " auto-dark, using MacVim's built-in appearance tracking instead of vim-lumen.
  if exists('##OSAppearanceChanged')
    function! s:FollowAppearance() abort
      let l:dark = v:os_appearance % 2
      let &background = l:dark ? 'dark' : 'light'
      try
        execute 'colorscheme' l:dark ? get(g:, 'lumen_dark_colorscheme', 'catppuccin_mocha')
              \ : get(g:, 'lumen_light_colorscheme', 'catppuccin_latte')
      catch /^Vim\%((\a\+)\)\=:E185/
        silent! colorscheme catppuccin
      endtry
    endfunction
    call s:FollowAppearance()
    autocmd OSAppearanceChanged * call s:FollowAppearance()
  endif
elseif has('win32')
  autocmd GUIEnter * simalt ~x
endif
