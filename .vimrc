set nocompatible
set encoding=utf-8
scriptencoding utf-8

augroup vimrc
  autocmd!
augroup END

" Plugins ==========================================
" ==================================================

let s:data_dir = expand('~/.vim')
let s:plug_vim = s:data_dir . '/autoload/plug.vim'

if !filereadable(s:plug_vim) && executable('curl')
  silent execute '!curl -fsLo ' . shellescape(s:plug_vim) . ' --create-dirs '
        \ . 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  if filereadable(s:plug_vim)
    autocmd vimrc VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
endif

" Lisp filetypes for vim-sexp; global because Plug evaluates its options.
let g:sexp_filetypes = 'clojure,scheme,lisp,timl,hy,fennel,racket'

if filereadable(s:plug_vim)
  call plug#begin(s:data_dir . '/plugged')
  " git: magit, git-link
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-rhubarb'
  " diff-hl
  Plug 'mhinz/vim-signify'
  " evil-surround
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-repeat'
  " evil-unimpaired
  Plug 'tpope/vim-unimpaired'
  " dtrt-indent
  Plug 'tpope/vim-sleuth'
  " crux file commands, sudo-edit
  Plug 'tpope/vim-eunuch'
  " evil-textobj extras
  Plug 'wellle/targets.vim'
  " align
  Plug 'junegunn/vim-easy-align', { 'on': ['<Plug>(EasyAlign)', 'EasyAlign'] }
  " vundo
  Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }
  " evil-lisp-state
  Plug 'guns/vim-sexp', { 'for': split(g:sexp_filetypes, ',') }
  Plug 'tpope/vim-sexp-mappings-for-regular-people', { 'for': split(g:sexp_filetypes, ',') }
  " smartparens
  Plug 'cohama/lexima.vim'
  " rainbow-delimiters
  Plug 'luochen1990/rainbow'
  " avy
  Plug 'justinmk/vim-sneak'
  " hy-mode
  Plug 'hylang/vim-hy'
  " theme (follows 'background'; see Visuals)
  Plug 'catppuccin/vim', { 'as': 'catppuccin', 'branch': 'main' }
  " writeroom-mode, olivetti
  Plug 'junegunn/goyo.vim', { 'on': 'Goyo' }
  " which-key
  Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKeyVisual'] }
  call plug#end()
endif

function! s:Has(plugin) abort
  return exists('g:plugs') && has_key(g:plugs, a:plugin)
        \ && isdirectory(g:plugs[a:plugin].dir)
endfunction

" Built-in packages ($VIMRUNTIME/pack/dist/opt): matchit, comment (gc
" operator, evil-commentary), nohlsearch (clear search highlight on
" idle/insert), cfilter (:Cfilter / :Lfilter), hlyank (pulse the yanked
" region), editorconfig (sleuth reads the indent keys from .editorconfig;
" this adds the rest: trim_trailing_whitespace, charset, ...).
" Same effect as `packadd!` (inserted after $VIMRUNTIME, none has an after/),
" but ~0.7 ms cheaper each; packages missing from older Vims are skipped.
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']
let s:rtp = split(&runtimepath, '\\\@<!,')
let s:at = index(s:rtp, $VIMRUNTIME) + 1
for s:pkg in ['matchit', 'comment', 'nohlsearch', 'cfilter', 'hlyank', 'editorconfig']
  let s:dir = $VIMRUNTIME . '/pack/dist/opt/' . s:pkg
  if isdirectory(s:dir)
    call insert(s:rtp, escape(s:dir, '\,'), s:at > 0 ? s:at : len(s:rtp))
    let s:at += s:at > 0
  endif
endfor
let &runtimepath = join(s:rtp, ',')
unlet s:rtp s:at s:pkg s:dir

" OSC 52 clipboard over SSH (clipetty); local sessions keep the native clipboard.
if has('clipboard_provider') && !has('gui_running')
      \ && (exists('$SSH_TTY') || !has('clipboard'))
  silent! packadd osc52
  silent! set clipmethod+=osc52
endif

filetype plugin indent on
syntax on

" Basic Settings ===================================
" ==================================================

set fileencoding=utf-8
set fileformats+=mac
set hidden
set mouse=a
set fillchars=eob:\ ,vert:\│
set shortmess+=I
set shortmess-=S                   " search count (evil-anzu)
set autoindent
set copyindent
set backspace=indent,eol,start
set complete-=i
set smarttab
set expandtab
set tabstop=2
set shiftwidth=2
set shiftround
set nrformats-=octal
set ttimeout
set ttimeoutlen=100
set timeout
set timeoutlen=300                 " which-key-idle-delay
set incsearch
set hlsearch
set ignorecase
set smartcase
set nonumber
set ruler                          " column-number-mode
set laststatus=2
set noshowmode
set wrap
set linebreak                      " global-visual-line-mode
if exists('+breakindent')
  set breakindent
endif
set scrolloff=4
set sidescrolloff=5
silent! set smoothscroll           " scroll wrapped lines by screen line
set display+=lastline
set splitright
set splitbelow
set guioptions=
" Crash recovery and persistent undo (auto-save, undo-fu-session), kept out of
" project directories. A trailing // encodes the full path in the file name.
for s:dir in ['swap', 'backup', 'undo']
  if !isdirectory(s:data_dir . '/' . s:dir)
    silent! call mkdir(s:data_dir . '/' . s:dir, 'p', 0700)
  endif
endfor
let &directory = s:data_dir . '/swap//'
let &backupdir = s:data_dir . '/backup//'
let &undodir = s:data_dir . '/undo//'
set swapfile
set nobackup
set writebackup                    " temporary backup while writing only
set undofile
set undolevels=1000
set nomodeline                     " enable-local-variables :safe; untrusted files
set synmaxcol=300                  " so-long: don't highlight minified lines
set foldmethod=indent
set foldlevelstart=99              " open files unfolded; za/zM/zR to fold
if exists('+signcolumn')
  set signcolumn=yes               " spacious-padding: blank left margin
endif
set history=1000
set tabpagemax=50
set novisualbell
set t_vb=
set belloff=all
set autoread
set updatetime=1000
set sessionoptions-=options
set viewoptions-=options
set viminfo='1000,<50,s10,h,!      " recentf-max-saved-items, savehist
set formatoptions+=j
set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
set wildmenu
set wildcharm=<C-z>
silent! set nolangremap
silent! set noimd
" ediff: side by side, aligned changed lines, word-level inline highlights.
" One item per :set so older Vims keep whatever they support.
set diffopt+=vertical
silent! set diffopt+=algorithm:histogram
silent! set diffopt+=linematch:60
if &diffopt =~# 'inline:'
  silent! set diffopt-=inline:char diffopt+=inline:word
endif
if has('path_extra')
  setglobal tags-=./tags tags-=./tags; tags^=./tags;
endif

if has('clipboard')
  if has('mac')
    set clipboard=unnamed
  else
    set clipboard=unnamedplus
  endif
endif

" Built-in grep via ripgrep (rg/ag/consult-ripgrep)
if executable('rg')
  set grepprg=rg\ --vimgrep\ --smart-case\ --hidden\ --glob=!.git/
  set grepformat=%f:%l:%c:%m
endif

" save-place
autocmd vimrc BufReadPost *
      \ let s:line = line("'\"")
      \ | if s:line >= 1 && s:line <= line('$') && &filetype !~# 'commit'
      \      && index(['xxd', 'gitrebase'], &filetype) == -1
      \ |   execute "normal! g`\""
      \ | endif

" so-long: plain, cheap buffers for huge files. filetypedetect's autocmds are
" defined earlier (filetype on), so syntax can be switched off after them.
let s:large_file = 2 * 1024 * 1024
autocmd vimrc BufReadPre *
      \ if getfsize(expand('<afile>')) > s:large_file || getfsize(expand('<afile>')) == -2
      \ |   let b:vimrc_large_file = 1
      \ |   setlocal noswapfile noundofile undolevels=-1 bufhidden=unload
      \ | endif
autocmd vimrc BufReadPost,BufWinEnter *
      \ if get(b:, 'vimrc_large_file')
      \ |   setlocal syntax=OFF foldmethod=manual nowrap
      \ | endif

" global-auto-revert-mode
autocmd vimrc FocusGained,BufEnter,CursorHold * if getcmdwintype() ==# '' | silent! checktime | endif

" vc-follow-symlinks: visit a symlinked file by its real path, so fugitive
" (which only looks above the buffer's own path) and 'autochdir' see the
" repository it lives in, e.g. ~/.vimrc -> .../dots/.vimrc.
function! s:FollowSymlink() abort
  let l:path = expand('%:p')
  if !empty(&buftype) || empty(l:path) || str2nr(expand('<abuf>')) != bufnr('%')
    return
  endif
  let l:real = resolve(l:path)
  if l:real ==# l:path || !filereadable(l:real)
    return
  endif
  " Vim matches buffers by inode, so rename in place rather than :edit the
  " target; :edit then clears the 'not edited' flag :file sets (E13 on :w).
  execute 'keepalt file' fnameescape(l:real)
  keepalt keepjumps edit
endfunction
autocmd vimrc BufReadPost * ++nested call s:FollowSymlink()

" default-directory: cwd follows the current file.
set autochdir

" Completion =======================================
" ==================================================

" Command line (vertico + orderless)
if exists('*wildtrigger')
  set wildmode=noselect:lastused,full
  set wildoptions=pum,fuzzy
  autocmd vimrc CmdlineChanged : call wildtrigger()
  cnoremap <expr> <Up>   wildmenumode() ? "\<C-e>\<Up>"   : "\<Up>"
  cnoremap <expr> <Down> wildmenumode() ? "\<C-e>\<Down>" : "\<Down>"
else
  set wildmode=longest:full,full
  if has('patch-8.2.4325')
    set wildoptions=pum
  endif
endif

" Insert mode (corfu: auto, 0.2s delay, cycling)
if exists('+autocomplete')
  set autocomplete
  silent! set autocompletedelay=200
  set complete=.^5,w^5,b^5,u^5
  set completeopt=menuone,popup,fuzzy
  inoremap <silent><expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
  inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
  inoremap <silent><expr> <C-n>   pumvisible() ? "\<C-n>" : "\<Down>"
  inoremap <silent><expr> <C-p>   pumvisible() ? "\<C-p>" : "\<Up>"
endif

" Project root: git toplevel of the current file, else the cwd.
function! s:ProjectRoot() abort
  let l:dir = expand('%:p:h')
  if empty(l:dir) || !isdirectory(l:dir)
    let l:dir = getcwd()
  endif
  if executable('git')
    let l:root = systemlist('git -C ' . shellescape(l:dir) . ' rev-parse --show-toplevel 2>/dev/null')
    if !v:shell_error && !empty(l:root)
      return l:root[0]
    endif
  endif
  return getcwd()
endfunction

" Fuzzy :find over the project (projectile-find-file); see :h fuzzy-file-picker
if exists('+findfunc') && exists('*matchfuzzy')
  let s:files_cache = []

  function! VimrcFindFunc(arg, cmdcomplete) abort
    if !a:cmdcomplete && filereadable(expand(a:arg))
      return [a:arg]
    endif
    if empty(s:files_cache)
      let l:root = s:ProjectRoot()
      if executable('fd')
        let l:files = systemlist('fd --type f --hidden --exclude .git --max-results 100000 --base-directory '
              \ . shellescape(l:root))
      elseif executable('git') && !empty(glob(l:root . '/.git', 1))
        let l:files = systemlist('git -C ' . shellescape(l:root)
              \ . ' ls-files --cached --others --exclude-standard')
      else
        let l:files = map(filter(globpath(l:root, '**', 1, 1), '!isdirectory(v:val)'),
              \ 'strpart(v:val, len(l:root) + 1)')
      endif
      let s:files_cache = map(l:files, 'fnamemodify(l:root . "/" . v:val, ":~:.")')
      autocmd vimrc CmdlineLeave : ++once let s:files_cache = []
    endif
    return empty(a:arg) ? copy(s:files_cache) : matchfuzzy(s:files_cache, a:arg)
  endfunction

  set findfunc=VimrcFindFunc
endif

" Live :Grep (consult-ripgrep); see :h live-grep
let s:live_grep = exists('*wildtrigger') && exists('*cmdcomplete_info')
      \ && exists('##CmdlineLeavePre') && &grepprg =~# '^rg'
if s:live_grep
  command! -nargs=+ -complete=customlist,s:GrepComplete Grep call s:GrepVisit()

  function! s:GrepComplete(arglead, cmdline, cursorpos) abort
    let l:prg = &grepprg =~# '\$\*' ? &grepprg : &grepprg . ' $*'
    if len(a:arglead) < 2
      return []
    endif
    " rg reads stdin under system(), so pass the project root explicitly.
    let l:root = s:ProjectRoot()
    let l:cmd = substitute(l:prg, '\$\*', escape(shellescape(a:arglead) . ' '
          \ . shellescape(l:root), '\&'), '')
    let l:short = fnamemodify(l:root . '/x', ':~:.')[:-2]
    return map(systemlist(l:cmd), 'l:short . strpart(v:val, len(l:root) + 1)')
  endfunction

  function! s:GrepVisit() abort
    if empty(get(s:, 'grep_selected', ''))
      return
    endif
    let l:item = getqflist({'lines': [s:grep_selected], 'efm': &grepformat}).items[0]
    let s:grep_selected = ''
    execute 'buffer' l:item.bufnr
    call setbufvar(l:item.bufnr, '&buflisted', 1)
    call cursor(l:item.lnum, l:item.col)
  endfunction
endif

" Accept the first candidate on <CR> when nothing is selected.
if exists('##CmdlineLeavePre') && exists('*cmdcomplete_info')
  function! s:CmdlineAcceptFirst() abort
    let l:info = cmdcomplete_info()
    if empty(get(l:info, 'matches', []))
      return
    endif
    let l:line = getcmdline()
    if l:info.selected == -1 && (l:line =~# '^\s*fin\%[d]\s'
          \ || l:line =~# '^\s*b\%[uffer]\s\+\D')
      call setcmdline(matchstr(l:line, '^\s*\S\+') . ' ' . l:info.matches[0])
    elseif l:line =~# '^\s*Grep\s'
      let s:grep_selected = l:info.matches[l:info.selected == -1 ? 0 : l:info.selected]
      call setcmdline(l:info.cmdline_orig)
    endif
  endfunction
  autocmd vimrc CmdlineLeavePre : call s:CmdlineAcceptFirst()
endif

" Formatting (format-all): 'formatprg' per filetype, so gq also uses it.
let s:formatters = {
      \ 'python': ['ruff', 'ruff format --quiet -'],
      \ 'rust':   ['rustfmt', 'rustfmt --quiet'],
      \ 'go':     ['gofmt', 'gofmt'],
      \ 'nix':    ['nixfmt', 'nixfmt'],
      \ 'lua':    ['stylua', 'stylua -'],
      \ 'sh':     ['shfmt', 'shfmt'],
      \ 'bash':   ['shfmt', 'shfmt'],
      \ 'c':      ['clang-format', 'clang-format'],
      \ 'cpp':    ['clang-format', 'clang-format'],
      \ 'json':   ['jq', 'jq .'],
      \ }
autocmd vimrc FileType *
      \ if has_key(s:formatters, &filetype) && empty(&l:formatprg)
      \     && executable(s:formatters[&filetype][0])
      \ |   let &l:formatprg = s:formatters[&filetype][1]
      \ | endif

function! s:FormatBuffer() abort
  let l:view = winsaveview()
  if empty(&formatprg)
    keepjumps normal! gg=G
  else
    let l:out = systemlist(&formatprg . ' 2>/dev/null', getline(1, '$'))
    if v:shell_error
      echohl ErrorMsg | echomsg 'Formatter failed: ' . &formatprg | echohl None
    elseif l:out !=# getline(1, '$')
      call setline(1, l:out)
      if line('$') > len(l:out)
        silent execute (len(l:out) + 1) . ',$delete _'
      endif
    endif
  endif
  call winrestview(l:view)
endfunction

" Helpers ==========================================
" ==================================================

function! s:DeleteFile() abort
  let l:file = expand('%:p')
  if empty(l:file) || confirm('Delete ' . l:file . '?', "&Yes\n&No", 2) != 1
    return
  endif
  if executable('trash')
    call system('trash ' . shellescape(l:file))
  else
    call delete(l:file)
  endif
  if filereadable(l:file)
    echohl ErrorMsg | echomsg 'Could not delete ' . l:file | echohl None
  else
    bdelete!
  endif
endfunction

function! s:Scratch() abort
  enew
  setlocal buftype=nofile bufhidden=hide noswapfile
  file *scratch*
endfunction

" projectile-regenerate-tags; needs universal-ctags (BSD ctags lacks -R).
function! s:RegenerateTags() abort
  let l:root = s:ProjectRoot()
  let l:out = system('cd ' . shellescape(l:root) . ' && ctags -R -f tags .')
  if v:shell_error
    echohl ErrorMsg | echomsg 'ctags failed: ' . substitute(trim(l:out), '\n', ' ', 'g') | echohl None
  else
    echomsg 'Wrote ' . fnamemodify(l:root, ':~') . '/tags'
  endif
endfunction

" Keymaps ==========================================
" ==================================================

let mapleader = "\<Space>"
let maplocalleader = ","

nnoremap ZA :wqa!<CR>
nnoremap <C-x><C-c> :confirm qa<CR>
nnoremap <C-l> zz
inoremap <C-l> <C-o>zz
inoremap <C-u> <C-g>u<C-u>

" Emacs editing keys in insert mode (evil-disable-insert-state-bindings)
inoremap <C-a> <Home>
inoremap <expr> <C-e> pumvisible() ? "\<C-e>" : "\<End>"
inoremap <C-f> <Right>
inoremap <C-b> <Left>
inoremap <C-d> <Del>
inoremap <expr> <C-k> col('.') > strlen(getline('.')) ? "\<Del>" : "\<C-o>D"
cnoremap <C-a> <Home>
cnoremap <C-f> <Right>
cnoremap <C-b> <Left>
cnoremap <C-d> <Del>

" SPC ------------------------------------------------
nnoremap <leader><leader> :
nnoremap <leader><Tab> <C-^>
nnoremap <leader>! :!
nnoremap <leader>: :echo<Space>
nnoremap <leader><C-r> :edit<CR>

" tabs
nnoremap <leader>. :tabnew<CR>
nnoremap <leader>, :tabclose<CR>
nnoremap <leader>[ :tabprevious<CR>
nnoremap <leader>] :tabnext<CR>
nnoremap <leader>{ :-tabmove<CR>
nnoremap <leader>} :+tabmove<CR>

" errors (flymake) -> quickfix
nnoremap <leader>/ :cnext<CR>
nnoremap <leader>\ :cprevious<CR>

" Borrowed from VSpaceCode's menu (mirrored in NeovimConfig and init.el).
function! s:GrepProject(text) abort
  execute 'silent grep! -F --' shellescape(a:text, 1) shellescape(s:ProjectRoot(), 1)
  redraw!
  cwindow
endfunction

" A shell in the buffer's directory: a tmux pane below if inside tmux, else Terminal.app.
function! s:ExternalTerminal() abort
  let l:dir = expand('%:p:h')
  let l:dir = shellescape(isdirectory(l:dir) ? l:dir : getcwd())
  if !empty($TMUX)
    call system('tmux split-window -v -t ' . shellescape($TMUX_PANE) . ' -c ' . l:dir)
  else
    call system('open -a Terminal ' . l:dir)
  endif
endfunction

nmap <leader>cl gcc
xmap <leader>cl gc
nnoremap <leader>cn :cnext<CR>
nnoremap <leader>cp :cprevious<CR>
execute 'nnoremap <leader>sp :' . (s:live_grep ? 'Grep' : 'grep') . '<Space>'
nnoremap <silent> <leader>sP :call <SID>GrepProject(expand('<cword>'))<CR>
xnoremap <silent> <leader>sP :<C-u>call <SID>GrepProject(join(getregion(getpos("'<"), getpos("'>"), {'type': visualmode()}), "\n"))<CR>
nmap <leader>* <leader>sP
xmap <leader>* <leader>sP
nnoremap <leader>se :%s/\<<C-r><C-w>\>//gI<Left><Left><Left>
execute 'nnoremap <leader>rl :' . (s:live_grep ? 'Grep' : 'grep') . ' <Up>'
nnoremap <leader>rb :ls t<CR>:buffer<Space>
nnoremap <leader>? :filter /\c/ map<Left><Left><Left><Left><Left>
nnoremap <silent> <leader>" :call <SID>ExternalTerminal()<CR>

" windows
nnoremap <leader>; :vsplit<CR>
nnoremap <leader>' :split<CR>
for s:i in range(1, 9)
  execute 'nnoremap <silent> <leader>' . s:i . ' :' . s:i . 'wincmd w<CR>'
endfor
nnoremap <leader>wd <C-w>c
nnoremap <leader>wh <C-w>h
nnoremap <leader>wj <C-w>j
nnoremap <leader>wk <C-w>k
nnoremap <leader>wl <C-w>l
nnoremap <leader>wH <C-w>H
nnoremap <leader>wJ <C-w>J
nnoremap <leader>wK <C-w>K
nnoremap <leader>wL <C-w>L
nnoremap <leader>ws <C-w>s
nnoremap <leader>wv <C-w>v
nnoremap <leader>w; <C-w>v
nnoremap <leader>w' <C-w>s
nnoremap <leader>ww <C-w>w
nnoremap <leader>wr <C-w>r
nnoremap <leader>wR <C-w>R
nnoremap <leader>wM <C-w>x
nnoremap <leader>wS <C-w>x
nnoremap <leader>w= <C-w>=
nnoremap <leader>wx :bdelete<CR>

" files
nnoremap <leader>ff :edit <C-r>=fnameescape(expand('%:p:~:h')) . '/'<CR>
nnoremap <leader>o  :edit <C-r>=fnameescape(expand('%:p:~:h')) . '/'<CR>
nnoremap <leader>fF :vsplit <C-r>=fnameescape(expand('%:p:~:h')) . '/'<CR>
nnoremap <leader>fT :tabedit <C-r>=fnameescape(expand('%:p:~:h')) . '/'<CR>
nnoremap <leader>fs :update<CR>
nnoremap <leader>fS :wall<CR>
nnoremap <leader>fa :saveas<Space>
nnoremap <leader>fc :write <C-r>=fnameescape(expand('%:p:~:h')) . '/'<CR>
nnoremap <leader>fR :Move <C-r>=fnameescape(expand('%:p:~'))<CR>
nnoremap <leader>fE :SudoEdit<CR>
nnoremap <leader>fDD :call <SID>DeleteFile()<CR>
nnoremap <leader>fi :read<Space>
nnoremap <leader>fr :browse oldfiles<CR>
nnoremap <leader>fj :Explore<CR>
nnoremap <leader>fp :buffer <C-z>
nnoremap <leader>fed :edit $MYVIMRC<CR>
nnoremap <leader>feD :edit ~/.gvimrc<CR>
nnoremap <leader>feR :source $MYVIMRC<CR>
nnoremap <leader>fgd :find<Space>
execute 'nnoremap <leader>fgr :' . (s:live_grep ? 'Grep' : 'grep') . '<Space>'
nnoremap <leader>fgR :vimgrep<Space>
nnoremap <leader>fgg :Ggrep<Space>
nnoremap <leader>fbb :marks<CR>
nnoremap <leader>fbj :marks<CR>
nnoremap <leader>fbs :mark<Space>
nnoremap <leader>fbd :delmarks<Space>

" buffers
nnoremap <leader>bb :buffer <C-z>
nnoremap <leader>bB :ls<CR>
nnoremap <leader>bd :bdelete<CR>
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <leader>br :file<Space>
nnoremap <leader>bc :split<CR>
nnoremap <leader>bs :call <SID>Scratch()<CR>
nnoremap <leader>b= :call <SID>FormatBuffer()<CR>

" projectile
nnoremap <leader>pf :find<Space>
execute 'nnoremap <leader>p/ :' . (s:live_grep ? 'Grep' : 'grep') . '<Space>'
nnoremap <leader>pb :buffer <C-z>
nnoremap <leader>pc :make<CR>
nnoremap <leader>pd :execute 'Explore' fnameescape(<SID>ProjectRoot())<CR>
nnoremap <leader>pg :Git<CR>
nnoremap <leader>pk :%bdelete<CR>
nnoremap <leader>ps :wall<CR>
nnoremap <leader>p! :!cd <C-r>=shellescape(<SID>ProjectRoot(), 1)<CR> &&<Space>
nnoremap <leader>pG :call <SID>RegenerateTags()<CR>

" git (magit, git-link): read and stage only; push/pull/commit from a shell.
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gm :Git<Space>
nnoremap <leader>gb :Git blame<CR>
nnoremap <leader>ga :Git add -- %<CR>
nnoremap <leader>gu :Git reset -q -- %<CR>
nnoremap <leader>gd :Gdiffsplit<CR>
nnoremap <leader>gff :Gedit<Space>
nnoremap <leader>gfl :0Gclog<CR>
nnoremap <leader>gfd :Gdiffsplit<CR>
nnoremap <leader>gll :GBrowse!<CR>
nnoremap <leader>glL :GBrowse<CR>
xnoremap <leader>gll :GBrowse!<CR>
xnoremap <leader>glL :GBrowse<CR>

" lisp state (vim-sexp)
nmap <leader>ks <Plug>(sexp_capture_next_element)
nmap <leader>kS <Plug>(sexp_capture_prev_element)
nmap <leader>kb <Plug>(sexp_emit_tail_element)
nmap <leader>kB <Plug>(sexp_emit_head_element)
nmap <leader>kr <Plug>(sexp_raise_element)
nmap <leader>kw <Plug>(sexp_round_head_wrap_element)
nmap <leader>kW <Plug>(sexp_splice_list)
nmap <leader>kc <Plug>(sexp_convolute)
nmap <leader>kt <Plug>(sexp_swap_element_forward)
nmap <leader>kH <Plug>(sexp_move_to_prev_element_head)
nmap <leader>kL <Plug>(sexp_move_to_next_element_head)
nmap <leader>k[ <Plug>(sexp_square_head_wrap_element)
nmap <leader>k{ <Plug>(sexp_curly_head_wrap_element)
nnoremap <leader>kU [(
nnoremap <leader>k% %

" jump (avy -> vim-sneak with labels)
nmap <leader>jj <Plug>SneakLabel_s
nmap <leader>jc <Plug>SneakLabel_s
nmap <leader>jC <Plug>SneakLabel_S

" imenu -> built-in outline for help/markdown/man/terminal
nnoremap <leader>ii :packadd helptoc<Bar>HelpToc<CR>

" tabs
nnoremap <leader>tp :tabprevious<CR>
nnoremap <leader>th :tabprevious<CR>
nnoremap <leader>tn :tabnext<CR>
nnoremap <leader>tl :tabnext<CR>
nnoremap <leader>tH :-tabmove<CR>
nnoremap <leader>tL :+tabmove<CR>
nnoremap <leader>tN :tabnew<CR>
nnoremap <leader>tt :tabs<CR>
nnoremap <leader>td :tabclose<CR>
nnoremap <leader>tD :tabonly<CR>
nnoremap <leader>ty :tab split<CR>
nnoremap <leader>tb :tab sbuffer <C-z>
nnoremap <leader>tf :tabedit <C-r>=fnameescape(expand('%:p:~:h')) . '/'<CR>
nnoremap <leader>t<Tab> g<Tab>
for s:i in range(1, 9)
  execute 'nnoremap <silent> <leader>t' . s:i . ' ' . s:i . 'gt'
endfor

" toggles
nnoremap <leader>Tl :setlocal number!<CR>
nnoremap <leader>TL :set number!<CR>
nnoremap <leader>Tt :colorscheme <C-z>
nnoremap <leader>Tm :let &laststatus = (&laststatus ? 0 : 2)<CR>
nnoremap <leader>Tp :let &l:signcolumn = (&l:signcolumn ==# 'yes' ? 'no' : 'yes')<CR>
nnoremap <leader>Tw :Goyo<CR>
nnoremap <leader>Too :Goyo<CR>
if exists('+fullscreen')
  nnoremap <leader>Tf :set invfullscreen<CR>
endif

" text
nnoremap <leader>xu :UndotreeToggle<CR>
nmap <leader>xa <Plug>(EasyAlign)
xmap <leader>xa <Plug>(EasyAlign)
nnoremap <leader>xc g<C-g>
nnoremap <leader>xix :digraphs<CR>

" yank (kill ring -> registers)
nnoremap <leader>yy :registers<CR>

" help
nnoremap <leader>hh :help<Space>
nnoremap <leader>ha :helpgrep<Space>
nnoremap <leader>hdb :map<CR>
nnoremap <leader>hdM :map<Space>
nnoremap <leader>hdf :help<Space>
nnoremap <leader>hdk :verbose map<Space>
nnoremap <leader>hdv :verbose set<Space>
nnoremap <leader>hdc :verbose command<Space>
nnoremap <leader>hdx ga
nnoremap <leader>hd. :help <C-r><C-w><CR>
nnoremap <leader>hdp :PlugStatus<CR>

" lang tools
nnoremap <leader>lmc :setfiletype cpp<CR>
nnoremap <leader>lmC :setfiletype c<CR>
nnoremap <leader>lmr :setfiletype rust<CR>
nnoremap <leader>lmm :setfiletype markdown<CR>

" utilities
nnoremap <leader>ai :echo strftime('%c')<CR>

" straight -> vim-plug
nnoremap <leader>Spu :PlugInstall<CR>
nnoremap <leader>Spp :PlugUpdate<Space>
nnoremap <leader>SpP :PlugUpdate<CR>
nnoremap <leader>Spc :PlugClean<CR>
nnoremap <leader>Spv :PlugStatus<CR>
nnoremap <leader>SpU :PlugUpgrade<CR>

" quit
nnoremap <leader>qq :qa!<CR>
nnoremap <leader>qf :quit<CR>

" Aliases for commonly used commands+lazy shift finger:
command! -bar -nargs=* -complete=file -range=% -bang W         <line1>,<line2>write<bang> <args>
command! -bar -nargs=* -complete=file -range=% -bang Write     <line1>,<line2>write<bang> <args>
command! -bar -nargs=* -complete=file -range=% -bang Wq        <line1>,<line2>wq<bang> <args>
command! -bar -nargs=* -complete=file -range=% -bang WQ        <line1>,<line2>wq<bang> <args>
command! -bar                                  -bang Wqall     wqa<bang>
command! -bar -nargs=* -complete=file -range=% -bang We        <line1>,<line2>w<bang> | e <args>
command! -bar -nargs=* -complete=file -count   -bang Wnext     <count>wnext<bang> <args>
command! -bar -nargs=* -complete=file -count   -bang Wprevious <count>wprevious<bang> <args>
command! -bar -nargs=* -complete=file          -bang E         edit<bang> <args>
command! -bar -nargs=* -complete=file          -bang Edit      edit<bang> <args>
command! -bar                                  -bang Q         quit<bang>
command! -bar                                  -bang Quit      quit<bang>
command! -bar                                  -bang Qall      qall<bang>
command! -bar -nargs=? -complete=option              Set       set <args>
command! -bar -nargs=? -complete=help                Help      help <args>
command! -bar -nargs=* -complete=file          -bang Make      make<bang> <args>
command! -bar -nargs=* -complete=buffer        -bang Bdel      bdel<bang> <args>
command! -bar -nargs=* -complete=buffer        -bang Bwipe     bwipe<bang> <args>
command! -bar -nargs=* -complete=file          -bang Mksession mksession<bang> <args>
command! -bar -nargs=* -complete=dir           -bang Cd        cd<bang> <args>
command! -bar                                        Messages  messages
command! -bar -nargs=+ -complete=file          -bang Source    source<bang> <args>

" Plugin configs ===================================
" ==================================================

" vim-sexp: lazy-loaded on the first Lisp buffer (see g:sexp_filetypes above);
" its own FileType autocmds still run for that buffer.

" lexima (smartparens): plain pairs only, no <Esc> remap, no endwise/newline rules.
let g:lexima_map_escape = ''
let g:lexima_enable_endwise_rules = 0
let g:lexima_enable_newline_rules = 0

" rainbow (rainbow-delimiters)
let g:rainbow_active = 1

" vim-sneak: keep stock s/S/;/,/z/Z by claiming sneak's default <Plug>s.
let g:sneak#use_ic_scs = 1
for s:plug in ['Sneak_s', 'Sneak_S', 'Sneak_;', 'Sneak_,']
  execute 'map <Plug>(vimrc-unused-' . s:plug . ') <Plug>' . s:plug
endfor

" signify (diff-hl): git only; ]c/[c jump hunks and fall back to stock in diff mode.
let g:signify_skip = {'vcs': {'allow': ['git']}}
let g:signify_sign_change = '~'

" diff-hl's local-leader keys, only in git-tracked files (diff-hl-mode).
let s:hunk_keys = {'name': '+diff-hl', 'j': 'next-hunk', 'k': 'previous-hunk',
      \ 'n': 'next-hunk', 'p': 'previous-hunk',
      \ 'J': 'show-hunk-next', 'K': 'show-hunk-previous',
      \ 'N': 'show-hunk-next', 'P': 'show-hunk-previous',
      \ '.': 'show-hunk', 'r': 'revert-hunk', 'm': 'mark-hunk'}
function! s:HunkMaps() abort
  if s:Has('vim-signify') && empty(&buftype) && !exists('b:vimrc_hunk_maps')
        \ && exists('*FugitiveGitDir') && !empty(FugitiveGitDir())
    let b:vimrc_hunk_maps = 1
    for [l:keys, l:rhs] in [
          \ [['j', 'n'], '<Plug>(signify-next-hunk)'],
          \ [['k', 'p'], '<Plug>(signify-prev-hunk)'],
          \ [['J', 'N'], '<Plug>(signify-next-hunk):SignifyHunkDiff<CR>'],
          \ [['K', 'P'], '<Plug>(signify-prev-hunk):SignifyHunkDiff<CR>'],
          \ [['.'], ':SignifyHunkDiff<CR>'],
          \ [['r'], ':SignifyHunkUndo<CR>'],
          \ [['m'], 'v<Plug>(signify-motion-inner-visual)']]
      for l:key in l:keys
        execute 'nmap <buffer><silent> <localleader>v' . l:key l:rhs
      endfor
    endfor
  endif
  " The , which-key map is global; label the group only where it exists.
  if exists('g:which_key_local_map')
    if exists('b:vimrc_hunk_maps')
      let g:which_key_local_map.v = s:hunk_keys
    elseif has_key(g:which_key_local_map, 'v')
      call remove(g:which_key_local_map, 'v')
    endif
  endif
endfunction
autocmd vimrc BufEnter,FileType * call s:HunkMaps()

" undotree (vundo)
let g:undotree_SetFocusWhenToggle = 1

" Magit (evil-collection) keys in the :Git status buffer, aliased onto
" fugitive's own maps. Remote ops (push/pull/fetch) stay on the shell.
let s:magit_aliases = [
      \ ['nx', 'x', 'X'], ['nx', '<Tab>', '='],
      \ ['n', 'q', 'gq'], ['n', '?', 'g?'],
      \ ['nxo', '<C-j>', ')'], ['nxo', '<C-k>', '('],
      \ ['nxo', 'gj', ']/'], ['nxo', 'gk', '[/'],
      \ ['nxo', 'gn', 'gu'], ['nxo', 'gu', 'gU'],
      \ ['nxo', 'gpu', 'gp'], ['nxo', 'gpp', 'gp'],
      \ ['nxo', 'gfu', 'gP'], ['nxo', 'gfp', 'gP'],
      \ ['n', 'Zz', 'czz'], ['n', 'Zw', 'czw'], ['n', 'Zi', 'czs'],
      \ ['n', 'Za', 'cza'], ['n', 'Zp', 'czp'],
      \ ['n', '_', 'crc'], ['n', '-', 'crn'],
      \ ['n', 'bb', 'co<Space>'], ['n', 'm', 'cm<Space>']]
function! s:MagitKeys() abort
  " Snapshot every source first so aliases never chain (gn -> gu -> gU).
  let l:maps = []
  for [l:modes, l:new, l:old] in s:magit_aliases
    for l:mode in split(l:modes, '\zs')
      let l:dict = maparg(l:old, l:mode, 0, 1)
      if !empty(l:dict)
        call add(l:maps, [l:mode, l:new, l:dict])
      endif
    endfor
  endfor
  for l:mode in ['n', 'x', 'o']
    silent! execute l:mode . 'unmap <buffer> gp'
  endfor
  for [l:mode, l:new, l:dict] in l:maps
    " Borrow the raw lhs Vim itself computes (<C-j> has a modifyOtherKeys
    " form and a simplified one), then swap in the copied mapping.
    execute l:mode . 'noremap <buffer> ' . l:new . ' <Nop>'
    let l:raw = maparg(l:new, l:mode, 0, 1)
    if has_key(l:dict, 'lhsrawalt')
      call remove(l:dict, 'lhsrawalt')
    endif
    call extend(l:dict, filter(copy(l:raw), 'v:key =~# "^lhs"'))
    let l:dict.buffer = 1
    call mapset(l:mode, 0, l:dict)
  endfor
  nnoremap <buffer><silent><nowait> gr :<C-U>edit<CR>
  nnoremap <buffer><silent><nowait> S :<C-U>Git add -u<CR>
  nnoremap <buffer><silent><nowait> L :<C-U>Git log --graph --oneline --decorate<CR>
  nnoremap <buffer><nowait> <Bar> :Git<Space>
  nnoremap <buffer><nowait> bc :Git switch -c<Space>
endfunction
autocmd vimrc User FugitiveIndex call s:MagitKeys()

" Which-key ========================================
" ==================================================

let g:which_key_map = {
      \ ' ':      ':',
      \ '<Tab>':  'last-buffer',
      \ '!':      'shell-command',
      \ ':':      'eval-expression',
      \ '<C-R>':  'revert-buffer',
      \ '.':      'tab-new',
      \ ',':      'tab-close',
      \ '[':      'tab-previous',
      \ ']':      'tab-next',
      \ '{':      'tab-move-previous',
      \ '}':      'tab-move-next',
      \ '/':      'next-error',
      \ '\':      'previous-error',
      \ ';':      'vsplit',
      \ "'":      'split',
      \ 'o':      'find-file',
      \ '*':      'search-project-at-point',
      \ '?':      'search-keybindings',
      \ '"':      'external-terminal',
      \ '1': 'window-1', '2': 'window-2', '3': 'window-3',
      \ '4': 'window-4', '5': 'window-5', '6': 'window-6',
      \ '7': 'window-7', '8': 'window-8', '9': 'window-9',
      \ }
let g:which_key_map.w = {
      \ 'name': '+window',
      \ 'd': 'delete', 'h': 'left', 'j': 'down', 'k': 'up', 'l': 'right',
      \ 'H': 'move-far-left', 'J': 'move-bottom', 'K': 'move-top', 'L': 'move-far-right',
      \ 's': 'split', 'v': 'vsplit', ';': 'vsplit', "'": 'split',
      \ 'w': 'other-window', 'r': 'rotate-down', 'R': 'rotate-up',
      \ 'M': 'swap', 'S': 'swap', '=': 'balance', 'x': 'kill-buffer-and-window',
      \ }
let g:which_key_map.f = {
      \ 'name': '+file',
      \ 'f': 'find-file', 'F': 'find-file-other-window', 'T': 'find-file-other-tab',
      \ 's': 'save', 'S': 'save-all', 'a': 'write-file', 'c': 'copy-file',
      \ 'R': 'rename-file', 'E': 'sudo-edit', 'i': 'insert-file', 'r': 'recent-files',
      \ 'j': 'dired-jump', 'p': 'project-buffer',
      \ 'D': {'name': '+delete', 'D': 'delete-this-file'},
      \ 'e': {'name': '+vim', 'd': 'open-vimrc', 'D': 'open-gvimrc', 'R': 'source-vimrc'},
      \ 'g': {'name': '+find/grep', 'd': 'find', 'r': 'ripgrep', 'R': 'vimgrep', 'g': 'git-grep'},
      \ 'b': {'name': '+bookmarks', 'b': 'list', 'j': 'list', 's': 'set', 'd': 'delete'},
      \ }
let g:which_key_map.b = {
      \ 'name': '+buffer',
      \ 'b': 'switch', 'B': 'list', 'd': 'kill', 'n': 'next', 'p': 'previous',
      \ 'r': 'rename', 'c': 'clone', 's': 'scratch', '=': 'format',
      \ }
let g:which_key_map.p = {
      \ 'name': '+project',
      \ 'f': 'find-file', '/': 'ripgrep', 'b': 'switch-buffer', 'c': 'compile',
      \ 'd': 'dired', 'g': 'vc', 'k': 'kill-buffers', 's': 'save-buffers',
      \ '!': 'shell-command-in-root', 'G': 'regenerate-tags',
      \ }
let g:which_key_map.g = {
      \ 'name': '+git',
      \ 's': 'status', 'm': 'dispatch', 'b': 'blame',
      \ 'a': 'stage-file', 'u': 'unstage-file', 'd': 'diff',
      \ 'f': {'name': '+file', 'f': 'find-file-at-rev', 'l': 'log', 'd': 'diff'},
      \ 'l': {'name': '+links', 'l': 'copy-url', 'L': 'open-url'},
      \ }
let g:which_key_map.k = {
      \ 'name': '+lisp',
      \ 's': 'slurp-forward', 'S': 'slurp-backward', 'b': 'barf-forward', 'B': 'barf-backward',
      \ 'r': 'raise', 'w': 'wrap', 'W': 'unwrap', 'c': 'convolute', 't': 'transpose',
      \ 'H': 'backward-sexp', 'L': 'forward-sexp', 'U': 'up-sexp', '%': 'jump-item',
      \ '[': 'wrap-[]', '{': 'wrap-{}',
      \ }
let g:which_key_map.j = {
      \ 'name': '+jump', 'j': 'sneak-label', 'c': 'sneak-label', 'C': 'sneak-label-backward',
      \ }
let g:which_key_map.i = {'name': '+imenu', 'i': 'outline'}
let g:which_key_map.t = {
      \ 'name': '+tab',
      \ 'p': 'previous', 'h': 'previous', 'n': 'next', 'l': 'next',
      \ 'H': 'move-previous', 'L': 'move-next', 'N': 'new', 't': 'list',
      \ 'd': 'close', 'D': 'close-other', 'y': 'duplicate', 'b': 'buffer-other-tab',
      \ 'f': 'find-file-other-tab', '<Tab>': 'recent',
      \ '1': 'tab-1', '2': 'tab-2', '3': 'tab-3', '4': 'tab-4', '5': 'tab-5',
      \ '6': 'tab-6', '7': 'tab-7', '8': 'tab-8', '9': 'tab-9',
      \ }
let g:which_key_map.T = {
      \ 'name': '+toggle',
      \ 'l': 'line-numbers', 'L': 'global-line-numbers', 't': 'theme',
      \ 'm': 'mode-line', 'f': 'fullscreen', 'p': 'padding', 'w': 'writeroom',
      \ 'o': {'name': '+olivetti', 'o': 'olivetti'},
      \ }
let g:which_key_map.x = {
      \ 'name': '+text', 'u': 'vundo', 'a': 'align', 'c': 'count-words',
      \ 'i': {'name': '+insert', 'x': 'digraphs'},
      \ }
let g:which_key_map.y = {'name': '+yank', 'y': 'registers'}
let g:which_key_map.h = {
      \ 'name': '+help', 'h': 'help', 'a': 'apropos',
      \ 'd': {'name': '+describe', 'b': 'bindings', 'M': 'keymap', 'f': 'function',
      \       'k': 'key', 'v': 'variable', 'c': 'command', 'x': 'char',
      \       '.': 'at-point', 'p': 'package'},
      \ }
let g:which_key_map.l = {
      \ 'name': '+lang-tools',
      \ 'm': {'name': '+major-modes', 'c': 'c++', 'C': 'c', 'r': 'rust', 'm': 'markdown'},
      \ }
let g:which_key_map.a = {'name': '+utilities', 'i': 'current-time'}
let g:which_key_map.S = {
      \ 'name': '+plug',
      \ 'p': {'name': '+package', 'u': 'install', 'p': 'update', 'P': 'update-all',
      \       'c': 'clean', 'v': 'status', 'U': 'upgrade-vim-plug'},
      \ }
let g:which_key_map.q = {'name': '+quit', 'q': 'quit-vim', 'f': 'quit-window'}
let g:which_key_map.c = {
      \ 'name': '+compile/comments', 'l': 'comment-line',
      \ 'n': 'next-error', 'p': 'previous-error',
      \ }
let g:which_key_map.s = {
      \ 'name': '+search', 'p': 'ripgrep-project', 'P': 'search-project-at-point',
      \ 'e': 'edit-symbol',
      \ }
let g:which_key_map.r = {'name': '+resume/recent', 'l': 'resume-grep', 'b': 'recent-buffers'}

let g:which_key_local_map = {}

if s:Has('vim-which-key')
  autocmd vimrc User vim-which-key
        \   call which_key#register('<Space>', 'g:which_key_map')
        \ | call which_key#register(',', 'g:which_key_local_map')

  " which-key dispatches the rest of the sequence itself, so the trigger must
  " fire immediately instead of after 'timeoutlen'. Vim only honors <nowait>
  " on buffer-local maps, and only over buffer-local maps defined before it
  " (e.g. vim-sexp's ,w), hence the per-buffer triggers installed after
  " plugins' FileType autocmds. SPC maps are global and static, so their parse
  " is cached; , maps are buffer-local (vim-sexp), so they are re-parsed, and
  " buffers without any keep stock , (repeat f/t backward).
  function! s:WhichKeyTriggers() abort
    for [l:key, l:prefix, l:reparse] in [['<Space>', '<Space>', 0], [',', ',', 1]]
      for [l:mode, l:cmd] in [['n', 'WhichKey'], ['x', 'WhichKeyVisual']]
        if get(maparg(l:key, l:mode, 0, 1), 'buffer')
          execute l:mode . 'unmap <buffer>' l:key
        endif
        if l:reparse && empty(mapcheck(l:key, l:mode))
          continue
        endif
        execute l:mode . 'noremap <buffer><nowait><silent>' l:key
              \ ':<C-u>let g:which_key_run_map_on_popup =' l:reparse
              \ '<Bar>' l:cmd "'" . l:prefix . "'<CR>"
      endfor
    endfor
  endfunction
  autocmd vimrc VimEnter * ++once
        \   autocmd vimrc BufEnter,FileType * call s:WhichKeyTriggers()
  autocmd vimrc VimEnter * ++once call s:WhichKeyTriggers()
endif

" Visuals ==========================================
" ==================================================

if has('termguicolors') && $TERM !=# 'linux' && $TERM_PROGRAM !=# 'Apple_Terminal'
  set termguicolors
endif

autocmd vimrc ColorScheme *
      \   highlight Normal ctermbg=NONE
      \ | highlight NonText ctermbg=NONE
      \ | highlight SignColumn guibg=NONE

" auto-dark without a watcher process: Vim asks the terminal for its background
" color (t_RB), but the reply lands after the first redraw. Start from the last
" detected value so catppuccin doesn't flash latte -> mocha, then follow the
" reply ourselves (Vim ignores it once 'background' has been set).
" Live switching is MacVim-only (.gvimrc).
if !has('gui_running') && exists('##TermResponseAll')
  let s:bg_file = s:data_dir . '/background'
  let s:bg_last = get(filereadable(s:bg_file) ? readfile(s:bg_file, '', 1) : [], 0, '')
  if s:bg_last =~# '^\%(dark\|light\)$'
    let &background = s:bg_last
  endif

  function! s:FollowTermBackground() abort
    let l:rgb = matchlist(v:termrbgresp, 'rgb:\(\x\x\)\x*/\(\x\x\)\x*/\(\x\x\)\x*')
    if empty(l:rgb)
      return
    endif
    let l:bg = eval(join(map(l:rgb[1:3], 'str2nr(v:val, 16)'), '+')) < 3 * 128
          \ ? 'dark' : 'light'
    if l:bg !=# &background
      let &background = l:bg
      redraw!
    endif
    if l:bg !=# s:bg_last
      let s:bg_last = l:bg
      silent! call writefile([l:bg], s:bg_file)
    endif
  endfunction
  autocmd vimrc TermResponseAll background call s:FollowTermBackground()
endif

if !exists('g:colors_name')
  try
    colorscheme catppuccin
  catch /^Vim\%((\a\+)\)\=:E185/
    silent! colorscheme lunaperche
  endtry
endif

let s:fugitive_status = "%{exists('*FugitiveStatusline') ? FugitiveStatusline() : ''}"
let &statusline = '%<%f %h%m%r' . s:fugitive_status . '%=%-14.(%l,%c%V%) %P'

" Different cursor shapes in Insert mode and Normal mode.
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
