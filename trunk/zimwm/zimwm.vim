let SessionLoad = 1
if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim
map! <F1> <F1>
map! <F2> <F2>
map! <F3> <F3>
map! <F4> <F4>
map! <S-F1> <S-F1>
map! <S-F2> <S-F2>
map! <S-F3> <S-F3>
map! <S-F4> <S-F4>
map! <End> <End>
map! <Home> <Home>
nmap s :cs find s =expand("<cword>")	
nmap g :cs find g =expand("<cword>")	
nmap c :cs find c =expand("<cword>")	
nmap t :cs find t =expand("<cword>")	
nmap e :cs find e =expand("<cword>")	
nmap f :cs find f =expand("<cfile>")	
nmap i :cs find i ^=expand("<cfile>")$
nmap d :cs find d =expand("<cword>")	
nmap gx <Plug>NetrwBrowseX
map <F1> <F1>
map <F2> <F2>
map <F3> <F3>
map <F4> <F4>
map <S-F1> <S-F1>
map <S-F2> <S-F2>
map <S-F3> <S-F3>
map <S-F4> <S-F4>
map <End> <End>
map <Home> <Home>
nmap <Nul>s :scs find s =expand("<cword>")	
nmap <Nul>g :scs find g =expand("<cword>")	
nmap <Nul>c :scs find c =expand("<cword>")	
nmap <Nul>t :scs find t =expand("<cword>")	
nmap <Nul>e :scs find e =expand("<cword>")	
nmap <Nul>f :scs find f =expand("<cfile>")	
nmap <Nul>i :scs find i ^=expand("<cfile>")$	
nmap <Nul>d :scs find d =expand("<cword>")	
nmap <Nul><Nul>s :vert scs find s =expand("<cword>")
nmap <Nul><Nul>g :vert scs find g =expand("<cword>")
nmap <Nul><Nul>c :vert scs find c =expand("<cword>")
nmap <Nul><Nul>t :vert scs find t =expand("<cword>")
nmap <Nul><Nul>e :vert scs find e =expand("<cword>")
nmap <Nul><Nul>f :vert scs find f =expand("<cfile>")	
nmap <Nul><Nul>i :vert scs find i ^=expand("<cfile>")$	
nmap <Nul><Nul>d :vert scs find d =expand("<cword>")
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#NetBrowseX(expand("<cWORD>"),0)
let &cpo=s:cpo_save
unlet s:cpo_save
set autoindent
set background=dark
set backspace=indent,eol,start
set cindent
set helplang=en
set mouse=a
set omnifunc=ccomplete#Complete
set tags=./tags,tags,~/.vim/systags
set termencoding=utf-8
set visualbell
set window=52
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/zde/berlios/trunk/zimwm
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +186 configure.in
badd +13 README
badd +1 Makefile.am
badd +9 src/Makefile.am
badd +83 src/main.m
badd +32 src/zimwm.h
badd +32 src/events.h
badd +67 src/events.m
badd +52 src/client.h
badd +87 src/client.m
badd +54 TODO
badd +46 src/ewmh.h
badd +89 src/ewmh.m
badd +34 src/client-events.h
badd +36 src/client-events.m
badd +2 data/Makefile.am
badd +6 src/focus.h
badd +38 src/focus.m
badd +31 COMPLIANCE
badd +1 src/vdesk.m
badd +31 src/vdesk.h
badd +1 src/ipc.h
badd +28 src/ipc.m
badd +6 src/zimsh
badd +1 src/ipc_commands.h
badd +1 src/modules.m
badd +1 src/modules.h
args configure.in README
edit README
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
argglobal
edit README
setlocal autoindent
setlocal autoread
setlocal balloonexpr=
setlocal nobinary
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal cindent
setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal comments=s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:-
setlocal commentstring=/*%s*/
setlocal complete=.,w,b,u,t,i
setlocal completefunc=
setlocal nocopyindent
setlocal nocursorcolumn
setlocal nocursorline
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal noexpandtab
if &filetype != ''
setlocal filetype=
endif
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=tcq
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal grepprg=
setlocal iminsert=2
setlocal imsearch=2
setlocal include=
setlocal includeexpr=
setlocal indentexpr=
setlocal indentkeys=0{,0},:,0#,!^F,o,O,e
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
setlocal nolist
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=octal,hex
set number
setlocal nonumber
setlocal numberwidth=4
setlocal omnifunc=ccomplete#Complete
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal noscrollbind
setlocal shiftwidth=8
setlocal noshortname
setlocal nosmartindent
setlocal softtabstop=0
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != ''
setlocal syntax=
endif
setlocal tabstop=8
setlocal tags=
setlocal textwidth=0
setlocal thesaurus=
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 13 - ((12 * winheight(0) + 26) / 52)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
13
normal! 0
if exists('s:wipebuf')
  exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filnxtToO
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . s:sx
endif
let &so = s:so_save | let &siso = s:siso_save
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
