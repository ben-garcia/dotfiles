execute pathogen#infect()
autocmd vimenter * NERDTree
nmap <C-n> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1 " enable to show hidden files
filetype plugin indent on
"autocmd FileType *.js setlocal shiftwidth=4 tabstop=4 " set tabs for javscript files.
"autocmd BufRead,BufNewFile   *.c,*.h,*.java set noic cin noexpandtab
autocmd BufRead,BufNewFile   *.js set tabstop=4 shiftwidth=4

syntax on
set tabstop=2     " number of visual spaces per TAB
set number        " show line numbers
set relativenumber
set shiftwidth=2  " indenting is 2 spaces
set smartindent   " does the right thing (mostly)
set cursorline    " highlight current line
set showmatch     " highlight matching [{(){]
set noshowmode		" don't show the current mode 
colorscheme codedark
set modifiable 		" modify files directly(NERDTree)
set t_Co=256			" 256 color support(for color schemes)
set incsearch			" start search the moment you start typing
set wrap lbr nolist    " don't breakup works

"recommended settings for Syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:syntastic_html_checkers = ['htmlhint']
let g:syntastic_css_checkers = ['prettycss']
let g:syntastic_javascript_checkers = ['eslint']

" detect jsx code in .js files.
let g:jsx_ext_required = 0
