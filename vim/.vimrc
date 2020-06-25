
call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'majutsushi/tagbar'
Plug 'bling/vim-airline'
Plug 'jlanzarotta/bufexplorer'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'easymotion/vim-easymotion'
Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-path'
Plug 'ncm2/ncm2-github'
Plug 'ncm2/ncm2-tagprefix'
Plug 'ncm2/ncm2-gtags'
Plug 'ncm2/ncm2-syntax'
Plug 'ncm2/ncm2-jedi'
Plug 'ncm2/ncm2-pyclang'
Plug 'ObserverOfTime/ncm2-jc2'
Plug 'davidhalter/jedi-vim'
Plug 'Shougo/neco-syntax'
call plug#end()



"nmap <Leader>tb :TagbarToggle<CR>        "快捷键设置
let g:tagbar_ctags_bin='ctags'            "ctags程序的路径
let g:tagbar_width=30                    "窗口宽度的设置
map <F3> :Tagbar<CR>
autocmd BufReadPost *.cpp,*.c,*.h,*.hpp,*.cc,*.cxx call tagbar#autoopen()	"如果是c语言的程序的话，tagbar自动开启

let NERDTreeWinPos='left'
let NERDTreeWinSize=30
let NERDTreeIgnore=['\~$', '\.pyc$', '\.swp$', '\.o$', '\.d$[[file]]', '__pycache__$']
map <F2> :NERDTreeToggle<CR>

set laststatus=2

let g:bufExplorerShowRelativePath=1  " Show relative paths.


let g:ctrlp_map = 'fp'
let g:ctrlp_cmd = 'CtrlP'
map <leader>f :CtrlPMRU<CR>
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/]\.(git|hg|svn|rvm)$',
    \ 'file': '\v\.(exe|so|dll|zip|tar|tar.gz|pyc|d|swn|o|swp)$',
    \ }
let g:ctrlp_working_path_mode='r'
let g:ctrlp_match_window_bottom=1
let g:ctrlp_max_height=15
let g:ctrlp_match_window_reversed=0
let g:ctrlp_mruf_max=500
let g:ctrlp_follow_symlinks=1
let g:ctrlp_max_depth = 40
let g:ctrlp_max_files = 0

" enable ncm2 for all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()

" IMPORTANT: :help Ncm2PopupOpen for more information
set completeopt=noinsert,menuone,noselect
" suppress the annoying 'match x of y', 'The only match' and 'Pattern not
" found' messages
set shortmess+=c

" CTRL-C doesn't trigger the InsertLeave autocmd . map to <ESC> instead.
inoremap <c-c> <ESC>

" When the <Enter> key is pressed while the popup menu is visible, it only
" hides the menu. Use this mapping to close the menu and also start a new
" line.
inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")

" Use <TAB> to select the popup menu:
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" wrap existing omnifunc
" Note that omnifunc does not run in background and may probably block the
" editor. If you don't want to be blocked by omnifunc too often, you could
" add 180ms delay before the omni wrapper:
"  'on_complete': ['ncm2#on_complete#delay', 180,
"               \ 'ncm2#on_complete#omni', 'csscomplete#CompleteCSS'],
au User Ncm2Plugin call ncm2#register_source({
    \ 'name' : 'css',
    \ 'priority': 9,
    \ 'subscope_enable': 1,
    \ 'scope': ['css','scss'],
    \ 'mark': 'css',
    \ 'word_pattern': '[\w\-]+',
    \ 'complete_pattern': ':\s*',
    \ 'on_complete': ['ncm2#on_complete#omni', 'csscomplete#CompleteCSS'],
    \ })

let g:ncm2_pyclang#library_path = '/usr/local/Cellar/llvm/10.0.0_3/lib/libclang.dylib'
let g:python3_host_prog='/usr/bin/python3'


"====基本配置==============================================================i=======
set nocompatible            " 关闭 vi 兼容模式
syntax on                   " 自动语法高亮
set number                  " 显示行号
set cursorline              " 突出显示当前行
set ruler                   " 打开状态栏标尺
set shiftwidth=4            " 设定 << 和 >> 命令移动时的宽度为 4
set softtabstop=4           " 使得按退格键时可以一次删掉 4 个空格
set tabstop=4               " 设定 tab 长度为 4
set expandtab
set nobackup                " 覆盖文件时不备份
set showcmd         " 输入的命令显示出来，看的清楚些
filetype plugin indent on   " 开启插件
set backupcopy=yes          " 设置备份时的行为为覆盖
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ %{strftime(\"%d/%m/%y\ -\ %H:%M\")}   "状态行显示的内容
"set autochdir               " 自动切换当前目录为当前文件所在的目录
set wildmenu				" 增强模式中的命令行自动完成操作
set completeopt=longest,menu
""set ignorecase smartcase    " 搜索时忽略大小写，但在有一个或以上大写字母时仍保持对大小写敏感
set nowrapscan              " 禁止在搜索到文件两端时重新搜索
set incsearch               " 输入搜索内容时就显示搜索结果
set hlsearch                " 搜索时高亮显示被找到的文本
set noerrorbells            " 关闭错误信息响铃
set novisualbell            " 关闭使用可视响铃代替呼叫
set t_vb=                   " 置空错误铃声的终端代码
set showmatch               " 插入括号时，短暂地跳转到匹配的对应括号
set matchtime=2             " 短暂跳转到匹配括号的时间
set magic                   " 设置魔术
set hidden                  " 允许在有未保存的修改时切换缓冲区，此时的修改由 vim 负责保存
set guioptions-=T           " 隐藏工具栏
set guioptions-=m           " 隐藏菜单栏
set smartindent             " 开启新行时使用智能自动缩进
set backspace=indent,eol,start
                            " 不设定在插入状态无法用退格键和 Delete 键删除回车符
set cmdheight=1             " 设定命令行的行数为 1
set laststatus=2            " 显示状态栏 (默认值为 1, 无法显示状态栏)

set pastetoggle=<F11>

"系统剪贴板
if has('clipboard')
        if has('unnamedplus')  " When possible use + register for copy-paste
            set clipboard=unnamed,unnamedplus
        else         " On mac and Windows, use * register for copy-paste
            set clipboard=unnamed
        endif
endif
set encoding=utf-8 fileencodings=ucs-bom,utf-8,cp936
"====按键映射=========================================================================================
inoremap ( ()<ESC>i
inoremap [ []<ESC>i
inoremap { {}<ESC>i
inoremap ' ''<ESC>i
inoremap " ""<ESC>i
inoremap < <><ESC>i
nmap  t= :resize+3<CR>
nmap  t- :resize-3<CR>
nmap  t, :vertical resize-3<CR>
nmap  t. :vertical resize+3<CR>

"窗口分割时,进行切换的按键热键需要连接两次,比如从下方窗口移动
"光标到上方窗口,需要<c-w><c-w>k,非常麻烦,现在重映射为<c-k>,切换的
"时候会变得非常方便.
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

nmap <C-n> :cnext<CR>
nmap <C-p> :cprev<CR>
"open quickfix window on the bottom
map qf :botright cw<CR>

let mapleader = ','

"====gnu global config=========================================================================================================
set cscopetag
set cscopeprg=gtags-cscope
set cscopequickfix=c-,d-,e-,f-,g0,i-,s-,t-
let g:Gtags_No_Auto_Jump = 1 "不要自动跳到第一个找到的地方
command! -nargs=+ -complete=dir FindFiles :call FindFiles(<f-args>)

"查找C语言符号，即查找函数名、宏、枚举值等出现的地方
nmap fs :Gtags -ga <C-R>=expand("<cword>")<CR><CR>
"查找grep
nmap fe :Gtags -sa <C-R>=expand("<cword>")<CR><CR>
"查找调用本函数的函数
nmap fc :Gtags -rxa <C-R>=expand("<cword>")<CR><CR>
"查找函数、宏、枚举等定义的位置
nmap fg :Gtags -a <C-R>=expand("<cword>")<CR><CR>
"查找文件
nmap ff :Gtags -P <C-R>=expand("<cword>")<CR><CR>

au VimEnter * call VimEnterCallback()
au BufAdd *.[ch] call FindGtags(expand('<afile>'))
au BufWritePost *.[ch] call UpdateGtags(expand('<afile>'))
au BufWritePost *.cpp call UpdateGtags(expand('<afile>'))

function! FindFiles(pat, ...)
	let path = ''
	for str in a:000
	   let path .= str . ','
	endfor

	if path == ''
	   let path = &path
	endif

	echo 'finding...'
	redraw
	call append(line('$'), split(globpath(path, a:pat), '\n'))
	echo 'finding...done!'
	redraw
endfunc

function! VimEnterCallback()
	for f in argv()
	  if fnamemodify(f, ':e') != 'c' && fnamemodify(f, ':e') != 'h'
		   continue
	  endif

	  call FindGtags(f)
	endfor
endfunc

function! FindGtags(f)
	let dir = fnamemodify(a:f, ':p:h')
	while 1
		let tmp = dir . '/GTAGS'
		if filereadable(tmp)
			exe 'cs add ' . tmp . ' ' . dir
		elseif dir == '/'
			break
		endif

		let dir = fnamemodify(dir, ":h")
	endwhile
endfunc

function! UpdateGtags(f)
	let dir = fnamemodify(a:f, ':p:h')
	exe 'silent !cd ' . dir . ' && global -u &> /dev/null &'
endfunction

"====colors and theme=========================================================================================================
syntax enable
"set background=dark
set t_Co=256
colorscheme  molokai "Tomorrow-Night-Bright

"====Open the file and return to the last closed position=========================================================================================================
au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

"====add program head comment=========================================================================================================
autocmd BufNewFile *.[ch],*.hpp,*.cpp exec ":call SetTitle()"
autocmd FileWritePre,BufWritePre *.[ch],*.hpp,*.cpp exec ":call SetLastModify()"

func SetTitle()
    call setline(1,"/*********************************************************************************")
    call append(1, " *Copyright(C),2015-".strftime("%Y").", Robsense Tech. All rights reserved.")
    call append(2, " *FileName:    ".expand("%:t"))
    call append(3, " *Author:      HeBin")
    call append(4, " *Version:     0.1")
    call append(5, " *Date:        ".strftime("%Y-%m-%d %H:%M:%S"))
    call append(6, " *Last Modify: ".strftime("%Y-%m-%d %H:%M:%S"))
    call append(7, " *Description: ")
    call append(8, "**********************************************************************************/")
    call append(9, "")
    call append(10, "")
endfunc

func SetLastModify()
"    call cursor(7,1)
    if search ('Last Modify') != 0
"        let line = line('.')
        call setline(7, ' *Last Modify: '.strftime("%Y-%m-%d %H:%M:%S"))
    endif
endfunc

autocmd BufNewFile *.sh,*py,Makefile,*.mk exec ":call SetScriptTitle()"
autocmd FileWritePre,BufWritePre *.sh,*py,Makefile,*.mk exec ":call SetScriptLastModify()"

func SetScriptTitle()
    call setline(1,"#*********************************************************************************")
    call append(1, "#Copyright(C),2015-".strftime("%Y").", Robsense. All rights reserved.")
    call append(2, "#FileName:    ".expand("%:t"))
    call append(3, "#Author:      HeBin")
    call append(4, "#Version:     0.1")
    call append(5, "#Date:        ".strftime("%Y-%m-%d %H:%M:%S"))
    call append(6, "#Last Modify: ".strftime("%Y-%m-%d %H:%M:%S"))
    call append(7, "#Description: ")
    call append(8, "#**********************************************************************************")
    call append(9, "")
    call append(10, "")
endfunc

func SetScriptLastModify()
"    call cursor(7,1)
    if search ('Last Modify') != 0
"        let line = line('.')
        call setline(7, '#Last Modify: '.strftime("%Y-%m-%d %H:%M:%S"))
    endif
endfunc


"====add program main func=========================================================================================================
autocmd BufNewFile *main.c exec ":call SetMainFunc()"

func SetMainFunc()
    call append(11, "int main()")
    call append(12, "{")
    call append(13, "")
    call append(14, "   return 0;")
    call append(15, "}")
endfunc

set keymodel=startsel

