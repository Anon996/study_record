set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'majutsushi/tagbar'
Plug 'bling/vim-airline'
Plug 'jlanzarotta/bufexplorer'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'easymotion/vim-easymotion'
Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'
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
let g:ncm2_pyclang#library_path = '/usr/local/Cellar/llvm/10.0.0_1/lib/libclang.dylib'
