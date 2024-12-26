set relativenumber
set number
set nowrap
set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
set smartcase
set ignorecase

syntax on

inoremap jk <ESC>
vnoremap > >gv
vnoremap < <gv
nnoremap < <<
nnoremap > >>

" Windows copy and paste
" vnoremap <C-c> "*y
" vnoremap <C-v> "*p
" inoremap <C-v> a<ESC>v"*pa
nmap <C-s> :w<ENTER>
nmap <C-q> :q<ENTER>