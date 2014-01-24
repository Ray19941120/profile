" Notes {
" Based on Smylers's .vimrc
" 2000 Jun  1: for `Vim' 5.6
"
" Hints
" <C-C> goto normal mode
" <C-O> stay in insert mode to execute a single cmd
"
" Toggle key maps: <localleader>
" Action key maps: <leader>
"

" *******************************************************
" } Prepare environment {
" *******************************************************

" Version check
if v:version < 700
  echoe ".vimrc requires VIM 7.0 or above"
  finish
endif

" User commands check
if !has("user_commands") && !exists("g:loaded_vimrc")
  " Reload .vimrc silently (removes autocommands errors)
  let g:loaded_vimrc = 1
  silent! source $MYVIMRC
  finish
endif

" Use before config
if filereadable(expand("~/.vimrc.before"))
    source ~/.vimrc.before
endif

" Use before local config
if filereadable(expand("~/.vimrc.before.local"))
    source ~/.vimrc.before.local
endif


" *******************************************************
" } Global settings {
" *******************************************************
set path=.,,**              " Search path: recurse from current directory
let mapleader = ";"         " Leader key
let maplocalleader = ","    " Local leader key
set nobackup                " No backup
set noswapfile              " No swap
set noerrorbells            " No bells (!!)
set novisualbell            " No visual bells too
set updatetime=1000         " Swap file write / event CursorHold delay (in ms)
set shell=/bin/bash\ --rcfile\ ~/.bashrc\ -i    " Set shell, load user profile

" Force write with sudo after opening the file
cmap w!! w !sudo tee % >/dev/null


" *******************************************************
" } Source vimrc {
" *******************************************************
" Resource vimrc
noremap  <leader>s      :source $MYVIMRC<CR>
cnoreabbrev reload source $MYVIMRC


" *******************************************************
" } Key mapping functions {
" *******************************************************

" Map function keys (or Ctrl-X) in normal/visual & insert modes
function! FnMap(args)
  let args = matchlist(a:args,'\(<silent>\s\+\)\?\(.\{-}\)\s\+\(.*\)')
  execute 'map'  args[1] args[2] '<c-c>'.args[3]
  execute 'imap' args[1] args[2] '<c-o>'.args[3]
endfunction

" Noremap function keys (or Ctrl-X) in normal/visual & insert modes
function! FnNoremap(args)
  let args = matchlist(a:args,'\(<silent>\s\+\)\?\(.\{-}\)\s\+\(.*\)')
  execute 'noremap'  args[1] args[2] '<c-c>'.args[3]
  execute 'inoremap' args[1] args[2] '<c-o>'.args[3]
endfunction

" Make an alternate mapping based on another
function! DoAltNmap(new,old)
  if empty(maparg(a:new,'n')) && !empty(maparg(a:old,'n'))
    execute 'nmap' a:new a:old
  endif
endfunction

" Make alternate key mappings based on another one
function! AltNmap(new,old)
  call DoAltNmap('<'.a:new.'>', '<'.a:old.'>')
  call DoAltNmap('<S-'.a:new.'>', '<S-'.a:old.'>')
  call DoAltNmap('<C-'.a:new.'>', '<C-'.a:old.'>')
  call DoAltNmap('<A-'.a:new.'>', '<A-'.a:old.'>')
endfunction

" User commands
command! -nargs=1 FnMap      call FnMap(<f-args>)
command! -nargs=1 FnNoremap  call FnNoremap(<f-args>)
command! -nargs=+ AltNmap    call AltNmap(<f-args>)


" *******************************************************
" } Terminal Settings {
" *******************************************************
" `XTerm', `RXVT', `Gnome Terminal', and `Konsole' all claim to be "xterm";
" `KVT' claims to be "xterm-color":
if &term =~ 'xterm'

  " `Gnome Terminal' fortunately sets $COLORTERM; it needs <BkSpc> and <Del>
  " fixing, and it has a bug which causes spurious "c"s to appear, which can be
  " fixed by unsetting t_RV:
  if $COLORTERM == 'gnome-terminal'
    execute 'set t_kb=' . nr2char(8)
    " [Char 8 is <Ctrl>+H.]
    fixdel
    set t_RV=

  " `XTerm', `Konsole', and `KVT' all also need <BkSpc> and <Del> fixing;
  " there's no easy way of distinguishing these terminals from other things
  " that claim to be "xterm", but `RXVT' sets $COLORTERM to "rxvt" and these
  " don't:
  elseif $COLORTERM == ''
    execute 'set t_kb=' . nr2char(8)
    fixdel

  " The above won't work if an `XTerm' or `KVT' is started from within a `Gnome
  " Terminal' or an `RXVT': the $COLORTERM setting will propagate; it's always
  " OK with `Konsole' which explicitly sets $COLORTERM to "".
  endif
endif


" *******************************************************
" } User Interface {
" *******************************************************

" Theme & color scheme
if has('syntax') && (&t_Co > 2)
  colorscheme torte   " Theme
  syntax on           " Syntax highlight
endif

set hlsearch          " Highlight searches
set history=50        " History length
set wildmode=list:longest,full    " Command line completion with Tabs & cycling
set shortmess+=r      " Use "[RO]" instead of "[readonly]"
set shortmess+=a      " Use short messages
set showmode          " Display current mode in the status line
set showcmd           " Display partially-typed commands
set mouse=a           " Enable mouse all the time
set nomodeline        " Do not override this .vimrc
if !exists('g:loaded_vimrc')
  set nu              " Show line numbers
endif
set hidden            " Show hidden buffers & allow switching to modified buffer
set switchbuf=useopen " Buffer switch use open windows instead of splitting/openning new window
set noea              " No equalize windows
set splitbelow        " Window split location. Also applied to :vsp & :sp
set splitright        " Window split location. Also applied to :vsp & :sp

" Save/restore part of edit session
"  /10  :  search items
"  '10  :  marks in 10 previously edited files
"  r/mnt/zip,r/mnt/floppy : excluded locations
"  "100 :  100 lines for each register
"  :20  :  20 lines of command-line history
"  %    :  buffer list
"  n... :  viminfo file location
set viminfo='10,\"100,:20,n~/.viminfo

" When using list, keep tabs at their full width and display `arrows':
" (Character 187 is a right double-chevron, and 183 a mid-dot.)
execute 'set listchars+=tab:' . nr2char(187) . nr2char(183)

" Change directory when changing buffers
if exists('+autochdir')
  set noautochdir
"else
"  autocmd BufEnter * silent! lcd %:p:h:gs/ /\\ /
endif

" Gui options
set guioptions-=T       " Remove toolbar

" Jump to the last cursor position
autocmd! BufReadPost *
  \ if line("'\"") > 0 && line ("'\"") <= line("$") |
  \   exe "normal! g'\"" |
  \ endif

" Key maps
map <localleader>n  :set nu!<CR>


" *******************************************************
" } Statusline {
" *******************************************************
" Line text content
setlocal statusline=\ %F
setlocal statusline+=\ [%{strlen(&fenc)?&fenc:'none'},\ %{&ff}]%h%m%r
setlocal statusline+=\ [%{&expandtab==0?'tabs':'space'}]\ %y
setlocal statusline+=%=
setlocal statusline+=%c,%l/%L\ %P

" Line options
"hi StatusLine ctermbg=NONE ctermfg=white
"hi clear StatusLine
"set laststatus=0         " Disable bottom status line
set laststatus=2         " Always show status line


" *******************************************************
" } Text Formatting {
" *******************************************************
set guioptions+=rb    " Right/bottom scroll bars enabled
set formatoptions-=t  " Do not format text as it is typed

set tabstop=4         " Indents of 4
set shiftwidth=4      " Indents of 4
set shiftround        " Indents are copied down lines
set autoindent        " Auto-indent
if !exists('g:loaded_vimrc')
  set expandtab       " Expand tabs to spaces
endif

set comments-=s1:/*,mb:*,ex:*/    " Get rid of the default style of C comments
set comments+=s:/*,mb:**,ex:*/    " Define new comment style starting with '**'
set comments+=fb:*                " Prevent single '*' lists to be intepreted as comments

" treat lines starting with a quote mark as comments (for `Vim' files, such as
" this very one!), and colons as well so that reformatting usenet messages from
" `Tin' users works OK:
set comments+=b:\"    " Define comment starting with '"'
set comments+=n::     " Define comment starting with ':'

" File type detection
filetype on           " enable filetype detection:

" C-like: automatic indentation
autocmd! FileType c,cc,cpp,slang set cindent tabstop=4 expandtab

" C: allow comments starting in the middle of a line
autocmd! FileType c set formatoptions+=ro

" Python: no tab to space, enable auto indentation
autocmd! FileType python set noexpandtab tabstop=4 smartindent

" Makefile: no tab to space, tab width 4 chars
autocmd! FileType make set noexpandtab shiftwidth=4

" Word/line wrap options
set nowrap              " No wrap by default
nnoremap <localleader>w  :set invwrap<CR>
"nnoremap <localleader>w  :exec &wrap?'set nowrap':'set wrap linebreak nolist'<CR>

" Show all characters
set nolist              " Do not show alla characters by default
nnoremap <localleader>c  :set invlist<CR>
"nnoremap <localleader>c  :exec &list?'set nolist':'set list'<CR>


" *******************************************************
" } Mswin plugin - loaded soon to override its settings later {
" *******************************************************
source ~/.vim/plugin/mswin.vim
let g:skip_loading_mswin = 1

" Additional key mapping
vmap <C-z>  <C-c><C-z>
vmap <C-y>  <C-c><C-y>


" *******************************************************
" } Formatting {
" *******************************************************
" Indentation normal & visual modes
noremap  <Tab>   >>
vnoremap <Tab>   >
noremap  <S-Tab> <LT><LT>
vnoremap <S-Tab> <LT>

" Identation insert mode
"inoremap <Tab>   <C-T>
"inoremap <S-Tab> <C-D>

" Y behave like C and D (not like cc, dd, yy)
noremap Y y$

" Word quote
nnoremap <silent> <leader>" viw<esc>a"<esc>hbi"<esc>lel


" *******************************************************
" } Space to tabs / tab to spaces {
" *******************************************************

" Tab to space
function! s:Tab2Space() range
  let firstline = a:firstline == a:lastline ? 0 : a:firstline
  let lastline = a:firstline == a:lastline ? line('$') : a:lastline
  execute ':'.firstline.','.lastline.'s#^\t\+#\=repeat(" ", len(submatch(0))*' . &ts . ')'
endfunction

" Space to tab
function! s:Space2Tab() range
  let firstline = a:firstline == a:lastline ? 0 : a:firstline
  let lastline = a:firstline == a:lastline ? line('$') : a:lastline
  execute ':'.firstline.','.lastline.'s#^\( \{'.&ts.'\}\)\+#\=repeat("\t", len(submatch(0))/' . &ts . ')'
endfunction

" Intelligent tab to spaces
function! s:Tabfix() abort
  if &expandtab==0
    call s:Tab2Space()
  else
    call s:Space2Tab()
  endif
  update
  YAIFAMagic
endfunction

" User commands
command! -range=% -nargs=0 Tab2Space call <SID>Tab2Space()
command! -range=% -nargs=0 Space2Tab call <SID>Space2Tab()
command! -range=% -nargs=0 Tabfix    call <SID>Tabfix()

" Key mapping
noremap <leader><Tab> :call <SID>Tabfix()<CR>


" *******************************************************
" } Space & tabs highlight {
" *******************************************************

" Show unwanted extra white space and tab characters
if !exists('s:spaceTabHighlight')
  let s:spaceTabHighlight = 0
endif

" Highlight unwanted space and tabs
function! s:SpaceTabHighlight(switchOn)
  if a:switchOn == 1
    " Set color
    hi ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
    hi ExtraTabs ctermbg=darkgreen guibg=darkgreen
    " Show trailing spaces and spaces before a tab
    syn match ExtraWhitespace /\s\+$\| \+\ze\t/
    if &expandtab==0
      " Show spaces wrongly used for indenting
      " Show tabs that are not at the start of a line
      syn match ExtraTabs /^\t*\zs \+\|[^\t]\zs\t\+/
    else
      " Show tabs that are not at the start of a line
      syn match ExtraTabs /[^\t]\zs\t\+/
    endif
  else
    " Enable syntax back
    syn on
  endif
endfunction

" Highlight unwanted space and tabs
function! s:SpaceTabToggle()
  let s:spaceTabHighlight = !s:spaceTabHighlight
  call <SID>SpaceTabHighlight(s:spaceTabHighlight)
endfunction

" Key mapping
map <silent><localleader>v  :call <SID>SpaceTabToggle()<CR>


" *******************************************************
" } Search & Replace {
" *******************************************************
set ignorecase      " Case-insensitive search
set smartcase       " Unless search contain upper-case letters
set incsearch       " Show the `best match so far' when search is typed
set gdefault        " Assume /g flag is on (replace all)

" Toggle search highlighting
nnoremap <localleader><F3>  :set invhls hls?<CR>
nnoremap <localleader>f     :set invhls hls?<CR>

" Search & replace
FnNoremap <C-F>     /
FnNoremap <C-A-F>   yiw:/<C-R>"
FnNoremap <C-H>     yiw:%s/<C-R>"//c<left><left>
FnNoremap <C-A-H>   yiw:%s/<C-R>"/<C-R>"/c<left><left>
vnoremap <C-F>      "+y:/<C-R>"
vnoremap <C-H>      "+y:%s/<C-R>"/<C-R>"/c<left><left>
vnoremap <C-A-H>    "+y:%s/<C-R>"//c<left><left>

" F3 for search (n and N)
FnMap  <F3>         n
FnMap  <S-F3>       N
vmap <S-F3>         <F3>N
vnoremap <silent>   <F3> :<C-u>call <SID>SearchHighlight()<CR>

" Alternative search
AltNmap f F3

" F4 for select & search (* and #)
FnMap <F4>      *
FnMap <S-F4>    #
nmap µ          #

" Highlight current selection
function! s:SearchHighlight()
  let old_reg=getreg('"')
  let old_regtype=getregtype('"')
  execute "normal! gvy"
  let @/=substitute(escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')
  execute "normal! gV"
  call setreg('"', old_reg, old_regtype)
  set hls
endfunction


" *******************************************************
" } Grep {
" *******************************************************
" Grep program
set grepprg=ref\ $*
"set grepprg=lid\ -Rgrep\ -s
"set grepformat=%f:%l:%m

" Grep
function! s:Grep(expr)
  execute "grep" a:expr
endfunction

" Count expression
function! s:GrepCount(expr)
  execute "!ref" a:expr "| wc -l"
endfunction

" Next grep
function! s:GrepNext()
  try | silent cnext | catch | silent! cfirst | endtry
endfunction

" Prev grep
function! s:GrepPrev()
  try | silent cprev | catch | silent! clast | endtry
endfunction

" Key mappings
FnNoremap <F7>   :GrepNext<CR>
FnNoremap <S-F7> :GrepPrev<CR>
FnNoremap <C-F7> :Grep<SPACE><C-r><C-w>
FnNoremap <A-F7> :GrepCount<SPACE><C-r><C-w>
cnoreabbrev gg Grep

" Alternate key mappings
AltNmap g F7

" User commands
command! -nargs=1 -bar Grep      call <SID>Grep(<f-args>)
command! -nargs=0 -bar GrepNext  call <SID>GrepNext()
command! -nargs=0 -bar GrepPrev  call <SID>GrepPrev()
command! -nargs=1 -bar GrepCount call <SID>GrepCount(<f-args>)


" *******************************************************
" } Cursor management {
" *******************************************************
set whichwrap=h,l,~,[,]   " Wrap between lines for h, l, ~, cursor keys [ and ]
set matchpairs+=<:>       " '%' bounce between brackets

" Backspace delete line breaks, over the start of the
" current insertion, and over indentations
set backspace=indent,eol,start

" Disable default behaviour "Ctrl-n=j" and "Ctrl-p=k"
if mapcheck("<C-n>") == ""
  noremap <C-n> <NOP>
endif
if mapcheck("<C-p>") == ""
  noremap <C-p> <NOP>
endif

" Goto line
FnNoremap  <C-b> :

" Prev/next cursor location
" Note: <C-[> is Esc
FnNoremap <A-Left>  <C-O>
FnNoremap <A-Right> <C-I>
vnoremap <A-Left>  <C-[><C-O>
vnoremap <A-Right> <C-[><C-I>


" *******************************************************
" } Marks {
" *******************************************************

" Map F2 to set/jump to marks
if !exists("s:mark_next")
  let s:mark_cur=0
  let s:mark_next=0
  let s:mark_max=1
endif

" Set a mark
function! s:MarkSet()
  exec printf("ma %c", 65 + s:mark_next)
  let s:mark_cur=s:mark_next
  let s:mark_next=(s:mark_next + 1) % 26
  let s:mark_max=max([s:mark_next,s:mark_max])
endfunction

" Goto next mark
function! s:MarkGotoNext()
  let s:mark_cur=(s:mark_cur + 1) % s:mark_max
  exec printf("normal '%c", 65 + s:mark_cur)
endfunction

" Goto prev mark
function! s:MarkGotoPrev()
  exec printf("normal '%c", 65 + s:mark_cur)
  let s:mark_cur=(s:mark_cur + s:mark_max - 1) % s:mark_max
endfunction

" Mark key maps
FnMap <silent> <F2>     :call <SID>MarkGotoPrev()<CR>
FnMap <silent> <S-F2>   :call <SID>MarkGotoNext()<CR>
FnMap <silent> <C-F2>   :call <SID>MarkSet()<CR>
AltNmap m F2


" *******************************************************
" } Tab management {
" *******************************************************
" Tab name is the filename only
if exists('+gtl')
  set gtl=%t
endif

" Enable/disable tabs
if $VIM_USETABS != ""
  let s:vimrc_useTabs = 1
  set switchbuf=usetab,newtab  " Buffer switch
endif

" Open/close tab
FnMap  <C-t>t   :tabnew<CR>:e<space>
FnMap  <C-t>c   :tabclose<CR>

" Prev/next tab
if exists('s:vimrc_useTabs')
  FnNoremap  <C-Tab>    :tabn<CR>
  FnNoremap  <C-S-Tab>  :tabp<CR>
else
  FnNoremap  <C-PgUp>   :tabn<CR>
  FnNoremap  <C-PgDown> :tabp<CR>
endif


" *******************************************************
" } Window management {
" *******************************************************
" Open/close window : standard mappings <C-w>...
" Prev/next window (Ctrl-w/W)

" Go up/down/left/right window
FnNoremap <C-Up>      :wincmd k<CR>
FnNoremap <C-Down>    :wincmd j<CR>
FnNoremap <C-Left>    :wincmd h<CR>
FnNoremap <C-Right>   :wincmd l<CR>

" Resize current window by +/- 5
" Same as 5<C-w>+  5<C-w>-  5<C-w>>  5<C-w><
"nnoremap <C-w><left>   :vertical resize -5<cr>
"nnoremap <C-w><right>  :vertical resize +5<cr>
"nnoremap <C-w><up>     :resize -5<cr>
"nnoremap <C-w><down>   :resize +5<cr>

" Extend window through the splits...
" Same as <C-w>_  <C-w>|
"noremap <C-J>  <C-w>j<C-w>_
"noremap <C-K>  <C-w>k<C-w>_
"noremap <C-H>  <C-w>h<C-w>\|
"noremap <C-L>  <C-w>l<C-w>\|

" Exit to normal when changing windows
augroup exit_to_normal
  autocmd!
  autocmd WinEnter * stopinsert
augroup END

" Toggles window max/equal
function! s:WndToggleMax()
  if exists('s:wndMaxFlag')
    au! maxCurrWin
    wincmd =
    unlet s:wndMaxFlag
  else
    augroup maxCurrWin
      au WinEnter * wincmd _ | wincmd |
    augroup END
    do maxCurrWin WinEnter
    let s:wndMaxFlag=1
  endif
endfunction

" Key maps
nnoremap <localleader>w :call <SID>WndToggleMax()<CR>
nnoremap <c-\<> :call <SID>WndToggleMax()<CR>


" *******************************************************
" } Buffer management {
" *******************************************************
" Open/close buffer (close=:bd or :bw)
map <C-b><C-o>      :e<SPACE>
map <C-b><C-c>      :bd<CR>
if !exists("s:vimrc_useTabs")
  "FnMap <F4>          :e<SPACE>
  FnMap <C-F4>        :bd<CR>
endif

" Prev/next buffer
map  <C-b><C-n>     :bn<CR>
map  <C-b><C-p>     :bp<CR>
FnNoremap <A-Down>    :bp<CR>
FnNoremap <A-Up>      :bn<CR>
if !exists("s:vimrc_useTabs")
  FnNoremap <C-Tab>   :bn<CR>
  FnNoremap <C-S-Tab> :bp<CR>
endif

" Wide empty buffer at startup
if bufname('%') == ''
  set bufhidden=wipe
endif


" *******************************************************
" } Function keys {
" *******************************************************
" Fx keys in insert mode = normal mode
for idx in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
  execute "imap <F" . idx . "> <C-O><F" . idx . ">"
endfor

" Map F1 to the help
FnMap <F1>    :vert help<space>


" *******************************************************
" } Tags {
" *******************************************************
" Set tags root
set tags=./tags,tags,$TAGS_DB

" Goto next tag (& loop)
function! s:TagNextTag()
  try | silent tnext | catch | silent! tfirst | endtry
endfunction

" Goto prev tag (& loop)
function! s:TagPrevTag()
  try | silent tprevious | catch | silent! tlast | endtry
endfunction

" User commands
command! -nargs=0 -bar Tnext    call s:TagNextTag()
command! -nargs=0 -bar Tprev    call s:TagPrevTag()

" Key mapping
noremap <C-ENTER>           <C-]>
noremap <c-SPACE>           <C-t>
FnNoremap <silent><F5>      :Tnext<CR>
FnNoremap <silent><S-F5>    :Tprev<CR>
FnNoremap <silent><C-F5>    <C-]>
FnNoremap <silent><A-F5>    <C-t>
AltNmap t F5


" *******************************************************
" } Preview window {
" *******************************************************
" Options
set previewheight=12          " Preview window height

" Variables
if !exists('s:p_lastw')
  let s:p_lastw = ""
  let s:p_highlight = 0
  let s:p_center = 0
endif

" Open preview window
function! s:PreviewOpenWnd()
  silent! execute "below pedit!"
  wincmd P
  if &previewwindow
  "  wincmd J
    set nonu
    wincmd p
  endif
  augroup PreviewWnd
    au!
    au CursorHold * nested call s:PreviewShowTag()
  augroup END
endfunction

" Close preview window
function! s:PreviewCloseWnd()
  augroup PreviewWnd
    au!
  augroup END
  pclose
  let s:p_lastw = ""
endfunction

" Toggle preview window
function! s:PreviewToggleWnd()
  if s:p_lastw == ""
    call s:PreviewOpenWnd()
  else
    call s:PreviewCloseWnd()
  endif
endfunction

function! s:PreviewShowTag()
  if &previewwindow || ! &modifiable  " don't do this in the preview window
    return
  endif
  let w = expand("<cword>")     " get the word under cursor
  if w == s:p_lastw             " Same word, skip all this
    return
  endif
  let s:p_lastw = w
  if w =~ '\a'                  " if the word contains a letter
    " Try displaying a matching tag for the word under the cursor
    try
      exec "silent! ptag " . w
      if s:p_highlight
        call s:PreviewHighlightTag(w)
      endif
      if s:p_center
        call s:PreviewCenterTag()
      endif
    endtry
  endif
endfunction

function! s:PreviewNextTag()
  try | silent ptnext | catch | silent! ptfirst | endtry
endfunction

function! s:PreviewPrevTag()
  try | silent ptprevious | catch | silent! ptlast | endtry
endfunction

function! s:PreviewCenterTag()
  silent! wincmd P            " jump to preview window
  if &previewwindow           " if we really get there...
    normal! zz                " Center
    wincmd p                  " back to old window
  endif
endfunction

function! s:PreviewHighlightTag(pattern)
  silent! wincmd P            " jump to preview window
  if &previewwindow           " if we really get there...
    match none                " delete existing highlight
    if has("folding")
      silent! .foldopen        " don't want a closed fold
    endif
    call search("$", "b")      " to end of previous line
    let w = substitute(a:pattern, '\\', '\\\\', "")
    call search('\<\V' . w . '\>') " position cursor on match
    " Add a match highlight to the word at this position
    hi previewWord term=bold ctermbg=blue guibg=blue
    exe 'match previewWord "\%' . line(".") . 'l\%' . col(".") . 'c\k*"'
    wincmd p                  " back to old window
  endif
endfunction

" User commands
command! -nargs=0 -bar Popen    call s:PreviewOpenWnd()
command! -nargs=0 -bar Pclose   call s:PreviewCloseWnd()
command! -nargs=0 -bar Ptoggle  call s:PreviewToggleWnd()
command! -nargs=0 -bar Pnext    call s:PreviewNextTag()
command! -nargs=0 -bar Pprev    call s:PreviewPrevTag()

" Key mapping
FnNoremap <silent><F6>      :Pnext<CR>
FnNoremap <silent><S-F6>    :Pprev<CR>
FnNoremap <C-F6>            :Pclose<CR>
nmap <localleader>p         :Ptoggle<CR>
nmap <localleader>pp        :Pclose<CR>
if mapcheck('t','n')!=''
  nmap <silent>t            :if &previewwindow <BAR> Pnext <BAR> else <BAR> Tnext <BAR> endif<CR>
  nmap <silent>T            :if &previewwindow <BAR> Pprev <BAR> else <BAR> Tprev <BAR> endif<CR>
endif


" *******************************************************
" } File browser netrw {
" *******************************************************
" Options
let g:netrw_browse_split = 0  " Use same(0)/prev(4) window
"let g:netrw_altv = 1          " Vertical split right
let g:netrw_liststyle=3       " Tree mode
let g:netrw_special_syntax= 1 " Show special files
let g:netrw_sort_sequence   = "[\/]$,*,\.o$,\.obj$,\.info$,\.swp$,\.bak$,\~$"
let g:netrw_winsize = 20      " Window size

" Workaround
set winfixwidth
set winfixheight

" Keymapping
FnNoremap <silent> <C-e>   :Explore<CR>
FnNoremap <silent> <C-A-e> :Vexplore<CR>

" Open netrw window
function! s:NetrwOpenWnd()
  Vexplore!
  let s:netrw_buf_num = bufnr("%")
endfunction

" Close netrw window
function! s:NetrwCloseWnd()
  if exists("s:netrw_buf_num")
    exec bufwinnr(s:netrw_buf_num) "wincmd c"
    unlet s:netrw_buf_num
  endif
endfunction


" *******************************************************
" } Omnicompletion {
" *******************************************************
" Enable OmniCppComplete
"set omnifunc=cppcomplete#CompleteCPP
"filetype plugin on

" Enable vim completion
set omnifunc=syntaxcomplete#Complete
filetype plugin on

" Set completion options
set completeopt=longest,menuone

" Advanced key mapping to omnicompletion
function! s:CleverTab()
  if pumvisible()
    return "\<C-N>"
  endif
  if strpart( getline('.'), 0, col('.')-1 ) =~ '^\s*$'
    return "\<Tab>"
  elseif exists('&omnifunc') && &omnifunc != ''
    return "\<C-X>\<C-O>"
  else
    return "\<C-N>"
  endif
endfunction

" Key mapping
"inoremap <C-space>  <C-x><C-o>
inoremap <C-space>  <C-R>=<SID>CleverTab()<CR>


" *******************************************************
" } Plugin general management {
" *******************************************************
" Start plugin pathogen
filetype off                " force reloading *after* pathogen loaded
runtime bundle/pathogen/autoload/pathogen.vim
execute pathogen#infect()
filetype plugin indent on   " enable detection, plugins and indenting in one step

" Disable the following plugins
let g:loaded_project = 1
let g:loaded_taglist = 1
"let g:loaded_tagbar = 1
let g:loaded_srcexpl = 1
let g:loaded_nerd_tree = 1
let g:loaded_trinity = 1
let g:ccvext_version = 1
let g:loaded_yankring = 1
"let g:loaded_cctree = 1
let g:command_t_loaded = 1
"let g:loaded_minibufexplorer = 1
"let g:loaded_yaifa = 1
"let g:loaded_ctrlp = 1


" *******************************************************
" } Project plugin {
" *******************************************************
if !exists('g:loaded_project')
  " Options
  set nocompatible
  let g:proj_window_width = 22
  let g:proj_window_increment = 0
  let g:proj_flags = 'GS'
  let g:proj_window_pos = 'L'

  " Toggle ON/OFF
  nmap <localleader>j  :Project<CR>
  nmap <localleader>jj <Plug>ToggleProject
endif


" *******************************************************
" } Taglist plugin {
" *******************************************************
if !exists('g:loaded_taglist')
  " Options
  if !exists('g:Tlist_Use_Right_Window')
    let g:Tlist_Use_Right_Window = 0    " Split to the right side of the screen
  endif
  let g:Tlist_WinWidth = 22             " Set the window width
  let g:Tlist_Sort_Type = "order"       " Sort by the "order" or "name"
  let g:Tlist_Compact_Format = 1        " Display the help info
  let g:Tlist_Exit_OnlyWindow = 1       " If you are the last, kill yourself
  let g:Tlist_File_Fold_Auto_Close = 1  " Close tags for other files
  let g:Tlist_Enable_Fold_Column = 0    " Show folding tree
  let g:Tlist_Show_One_File = 1         " Always display one file tags
  let g:Tlist_Display_Tag_Scope = 0     " Display tag scope (function/constants/variables)
  let g:Tlist_Use_SingleClick = 1       " Single click instead of double

  " Autoload autocommand (may not be necessary)
  " autocmd BufWritePost *.c,*.cc,*.cpp,*.py,*.mk,Makefile :TlistUpdate

  " Toggle ON/OFF
  nmap <localleader>t   :Tlist<CR>
  nmap <localleader>tt  :TlistClose<CR>
endif


" *******************************************************
" } SrcExplorer plugin {
" *******************************************************
if !exists('g:loaded_srcexpl')
  " Options
  let g:SrcExpl_winHeight = 8         " Set the height of Source Explorer window
  let g:SrcExpl_refreshTime = 100     " Set 100 ms for refreshing the Source Explorer
  let g:SrcExpl_jumpKey = "<ENTER>"       " Set key to jump into the exact definition context
  let g:SrcExpl_gobackKey = "<BACKSPACE>" " Set key for back from the definition context
  let g:SrcExpl_searchLocalDef = 0    " Enable/Disable the local definition searching (Warning: side effect Ctrl-O/I stop working)
  let g:SrcExpl_isUpdateTags = 0      " Tag update on file opening
  let g:SrcExpl_updateTagsCmd = ""    " Tag update command
  let g:SrcExpl_updateTagsKey = ""    " Tag update key
  let g:SrcExpl_prevDefKey = "<S-F6>" " Show prev definition in jump list
  let g:SrcExpl_nextDefKey = "<F6>"   " Show next definition in jump list
  let g:SrcExpl_pluginList = g:wndmgr_pluginList " Plugin names that are using buffers

  " Additionnal key maps
  FnNoremap  <C-F6>   <C-O>
  vnoremap <C-F6>   <C-[><C-O>

  " Toggle ON/OFF
  nmap <localleader>s   :SrcExpl<CR>
  nmap <localleader>ss  :SrcExplClose<CR>
endif


" *******************************************************
" } NERDTree plugin {
" *******************************************************
if !exists('g:loaded_nerd_tree')
  " Options
  let g:NERDTreeWinSize = 25            " Set the window width
  let g:NERDTreeWinPos = "right"        " Set the window position
  let g:NERDTreeAutoCenter = 0          " Auto centre
  let g:NERDTreeHighlightCursorline = 0 " Not Highlight the cursor line

  " Toggle ON/OFF
  nmap <localleader>n   :NERDTree<CR>
  nmap <localleader>nn  :NERDTreeClose<CR>
endif


" *******************************************************
" } MiniBufExplorer plugin {
" *******************************************************
if !exists('g:loaded_minibufexplorer')
  " Options
  let g:miniBufExplStatusLineText = ""
  let g:miniBufExplBuffersNeeded = 2
  let g:miniBufExplUseSingleClick = 1
  let g:miniBufExplCycleArround = 1
  let g:miniBufExplShowBufNumbers = 1
  let g:miniBufExplAutoStart = 1
  let g:miniBufExplAutoUpdate = 1
  let g:miniBufExplSplitToEdge = 1
  let g:miniBufExplTabWrap = 1
  let g:miniBufExplMinSize = 1
  let g:miniBufExplMaxSize = 3
  let g:miniBufExplSortBy = 'mru'
  let g:miniBufExplBRSplit = 0

  " Colors
  hi MBENormal               guifg=#FFFFFF guibg=bg
  hi MBEChanged              guifg=#FFFFFF guibg=bg
  hi MBEVisibleNormal        guifg=#FFFFFF guibg=bg
  hi MBEVisibleChanged       guifg=#FFFFFF guibg=bg
  hi MBEVisibleActiveNormal  guifg='cyan'  guibg=bg gui=bold,underline
  hi MBEVisibleActiveChanged guifg=#FF0000 guibg=bg

  " Toggle ON/OFF
  map <localleader>m        :MBEToggle<CR>

  " Overwrite open/close key mapping
  FnMap <C-b>c              :MBEbd<CR>
  if !exists("s:vimrc_useTabs")
    FnMap <C-F4>            :MBEbd<CR>
  endif

  " Cycle through buffers
  FnMap <A-Down>  :MBEbb<CR>
  FnMap <A-Up>    :MBEbf<CR>
  if !exists("s:vimrc_useTabs")
    "FnNoremap <C-Tab>      :MBEbb<CR>
    "FnNoremap <C-S-Tab>    :MBEbf<CR>
    FnNoremap <C-Tab>       :call <SID>MbeSwitch(1)<CR>
    FnNoremap <C-S-Tab>     :call <SID>MbeSwitch(0)<CR>
  endif

  " Switch between 2 buffers
  if !exists('s:vimrc_mbeswitch')
    let s:vimrc_mbeswitch = 0
  endif
  function! s:MbeSwitch(toggle)
    if a:toggle == 1
      let s:vimrc_mbeswitch = !s:vimrc_mbeswitch
    endif
    if s:vimrc_mbeswitch == 1
      MBEbf
    else
      MBEbb
    endif
  endfunction

endif


" *******************************************************
" } CCVext plugin {
" *******************************************************
if !exists('g:ccvext_version')
  " Options
  let g:ccvext_WndHeight = 10
  let g:ccvext_autostart = 0
  " Toggle ON/OFF
  nmap <localleader>c   :CCVext<CR>
  nmap <localleader>cc  :CCVextClose<CR>
endif


" *******************************************************
" } Yaifa plugin {
" *******************************************************
if !exists('g:loaded_yaifa')
  " Options
  let g:yaifa_max_lines=4096
  " Map Yaifa
  nmap <localleader><tab>   :call YAIFA()<CR>
  " autocall when entering file
  if exists("*YAIFA")
    autocmd! BufRead * silent! call YAIFA()
  endif
endif


" *******************************************************
" } Yankring plugin {
" *******************************************************
if !exists('g:loaded_yankring')
  " Options
  let g:yankring_v_key = ""
  let g:yankring_del_v_key = ""
  let g:yankring_paste_n_bkey = ""
  let g:yankring_paste_n_akey = ""
  let g:yankring_paste_v_bkey = ""
  let g:yankring_paste_v_akey = ""
  let g:yankring_replace_n_pkey = ""
  let g:yankring_replace_n_nkey = ""
endif


" *******************************************************
" } CCTree plugin {
" *******************************************************
if !exists('g:loaded_cctree')
  " Options
  let g:CCTreeCscopeDb = "cscope.out, $CSCOPE_DB"
  let g:CCTreeDisplayMode = 2
  let g:CCTreeRecursiveDepth = 3

  " Add any cscope database in the given environment variable
  for db in split(g:CCTreeCscopeDb)
    if filereadable(db)
      exec 'let g:CCTreeCscopeDb =' db
      break
    endif
  endfor

  " Key mappings
  let g:CCTreeKeyTraceReverseTree = '<localleader>x'
  let g:CCTreeKeyTraceForwardTree = '<localleader>xf'
  let g:CCTreeKeyToggleWindow = '<localleader>xx'
  nmap <localleader>xl      :if filereadable(g:CCTreeCscopeDb) <BAR> exec "CCTreeLoadDB" g:CCTreeCscopeDb <BAR> endif
  "nmap <localleader>xl     :if filereadable('xref.out') <BAR> CCTreeLoadXRefDbFromDisk xref.out <BAR> endif
endif


" *******************************************************
" } Command-T plugin {
" *******************************************************
if !exists('g:command_t_loaded')
  " Options
  let g:CommandTWildIgnore="*.o,*.obj,**/tmp/**"
  let g:CommandTMaxDepth = 8
  let g:CommandTMaxCachedDirectories = 2

  " Key mapping
  FnNoremap <C-p>     :CommandT<CR>
endif


" *******************************************************
" } CTRLP plugin {
" *******************************************************
if !exists('g:loaded_ctrlp')
  " Options
  let g:ctrlp_map = '<C-p>'
  let g:ctrlp_cmd = 'CtrlP'
  let g:ctrlp_working_path_mode = '0'
  let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.(git|hg|svn)|tmp)$',
  \ 'file': '\v\.(exe|so|dll|o)$'
  \ }
  " Key mapping
  FnNoremap <C-o>     :CtrlPMRU<CR>
endif


" *******************************************************
" } Tagbar plugin {
" *******************************************************
if !exists('g:loaded_tagbar')
  " Options
  let g:tagbar_left = 1
  let g:tagbar_width = 25
  let g:tagbar_autoshowtag = 0
  let g:tagbar_expand = 1
  let g:tagbar_indent = 1
  let g:tagbar_show_linenumbers = 1
  let g:tagbar_singleclick = 1
  " Toggle ON/OFF
  nmap <localleader>t   :TagbarToggle<CR>
  nmap <localleader>tt  :TagbarClose<CR>
endif


" *******************************************************
" } Hexadecimal display {
" *******************************************************
if !exists('g:vimrc_hexa')
  let g:vimrc_hexa=0
endif

function! s:HexaToggle()
  let g:vimrc_hexa=!g:vimrc_hexa
  if g:vimrc_hexa==1
    exec ":%!xxd"
  else
    exec ":%!xxd -r"
  endif
endfunction

" Key mapping
map <leader>h :call <SID>HexaToggle()<CR>


" *******************************************************
" } Sessions {
" *******************************************************
" Key mapping
FnNoremap <C-F9>      :mksession! ~/.vimsession <CR>
FnNoremap <F9>        :source! ~/.vimsession<CR>


" *******************************************************
" } Alignment function {
" *******************************************************
" Mapping
map <leader>= :call <SID>Vimrc_AlignAssignments()<CR>

" Alignement function
function! s:Vimrc_AlignAssignments ()
  " Patterns needed to locate assignment operators...
  let ASSIGN_OP   = '[-+*/%|&]\?=\@<!=[=~]\@!'
  let ASSIGN_LINE = '^\(.\{-}\)\s*\(' . ASSIGN_OP . '\)'

  " Locate block of code to be considered (same indentation, no blanks)
  let indent_pat = '^' . matchstr(getline('.'), '^\s*') . '\S'
  let firstline  = search('^\%('. indent_pat . '\)\@!','bnW') + 1
  let lastline   = search('^\%('. indent_pat . '\)\@!', 'nW') - 1
  if lastline < 0
    let lastline = line('$')
  endif

  " Find the column at which the operators should be aligned...
  let max_align_col = 0
  let max_op_width  = 0
  for linetext in getline(firstline, lastline)
    " Does this line have an assignment in it?
    let left_width = match(linetext, '\s*' . ASSIGN_OP)

    " If so, track the maximal assignment column and operator width...
    if left_width >= 0
      let max_align_col = max([max_align_col, left_width])
      let op_width      = strlen(matchstr(linetext, ASSIGN_OP))
      let max_op_width  = max([max_op_width, op_width+1])
     endif
  endfor

  " Code needed to reformat lines so as to align operators...
  let FORMATTER = '\=printf("%-*s%*s", max_align_col, submatch(1),
  \                                    max_op_width,  submatch(2))'

  " Reformat lines with operators aligned in the appropriate column...
  for linenum in range(firstline, lastline)
    let oldline = getline(linenum)
    let newline = substitute(oldline, ASSIGN_LINE, FORMATTER, "")
    call setline(linenum, newline)
  endfor
endfunction


" *******************************************************
" } Alignment function {
" *******************************************************

" Increment/decrement numbers
FnNoremap <A-a>   <C-a>
FnNoremap <A-A>   <C-x>


" *******************************************************
" } Environment conclusion {
" *******************************************************

" Security
set secure
set noexrc

" Use after local config
if filereadable(expand("~/.vimrc.after.local"))
    source ~/.vimrc.after.local
endif

" Use after config
if filereadable(expand("~/.vimrc.after"))
    source ~/.vimrc.after
endif

" Load flag
let g:loaded_vimrc = 1

" }
