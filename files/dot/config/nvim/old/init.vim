set backspace=indent,eol,start

call mkdir(expand("~/.cache/nvim/backups"), "p")
set backup		" keep a backup file
set backupdir=~/.cache/nvim/backups,. " put the backup out of the way
set confirm             " confirm dangerous actions instead of asking for a !
set exrc                " Allow a .vimrc file in the current directory
set patchmode=".orig"	" Only backup the original
set history=10000	" keep lots of command-line history
set textwidth=72
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
set hlsearch            " Turn on search highlighting
set shiftwidth=2	" Indent amount = 4 spaces
set softtabstop=2	" <tab> is the same, but doesn't affect real tabs.
set expandtab		" Arrg! Python finally bit me!
set splitright splitbelow " Make new windows come up idiosyncronously.
set number relativenumber " Line numbering--Oh!
set autoread
set hidden		" Buffers prefer to be hidden, instead of inactive
set scrolloff=2		" Number of lines to keep above or below the cursor onscreen
set linebreak		" word-wrap long lines instead of char-wrapping
set laststatus=1        " Status line only for multiple windows
                        " This is the default in Vim, but not NeoVim
set gdefault            " %s/// replaces all matches; /g turns it back off
"set tildeop		" ~ command accepts a motion (like delete or change do)
set display=lastline,uhex " A few display settings
set ttyfast             " More performant scrolling, but with heavier
                        " tty usage
set wildmenu            " Enhanced command-line completion
set wildmode=longest:full,full
"   longest     First, complete the longest common match
"   :full       But, also show the wildmenu
"   full        If user pressses <Tab> again, match the first full
"               string in the list, instead of longest common substring

" Prefer UTF-8 encoding
set encoding=utf-8
" As I understand it, encoding is variable is only used if none of the
" encodings in 'fileencodings' works; Loading a file with utf-8 encoding
" will not corrupt it, even it it is from a different encoding.

" Doesn't UTF-16 files, fails for ASCII.
" set fileencodings=ucs-bom,utf-16le,utf-8

set formatoptions=tcqjroqn
"   t   autowrap text
"   c   autowrap comments
"   j   remove comment leader (e.g. //) when joining lines
"   r   auto insert comment leader with i<Enter>
"   o   auto insert comment leader with o or O
"   q   format comments with gq, too
"   n   wrap lists (e.g. "1.", "1)") (Uses 'formatlistpat')

let &formatlistpat="^\s*\d\+[\]:.)}\t ]\s*\|^\s*[-*]\s+"
let &formatlistpat=string(&formatlistpat)
" Pattern used to find lists for set fo+=n, above. This adds bullet
" lists (beginning with * or -) to the default numbered lists


" What gets saved with ':mksession' command?
set sessionoptions=blank,buffers,curdir,folds,help,localoptions,options,resize,tabpages,winpos,winsize
" blank     empty windows
" buffers   hidden/unloaded buffers (those not in a window currently)
" curdir    current dir
" folds     Manually created folds, as well as open/close state
" help      Help window(s)
" locaoptions Local options (e.g. lcd)
" options   Global options/mappings
" resize    Size of Vim
" tabpages  All tabs; without this, you can (must) save each tab separately
" winpos    Window position of Vim
" winsize   Size of windows


augroup autoreload
  autocmd!
  autocmd FocusGained * checktime
  autocmd CursorHold * checktime
augroup END

" NeoVim-only settings
if has("nvim")
    :highlight Normal guibg=NONE " Preserve transparent background of ghostty
    set nrformats=bin,octal,hex " Which number formats work with ^A and ^X?
    set shada=!,'1000,f1,<500,s100,h
    "   !       Store certain global variables (ALL_CAPS)
    "   'n      Save marks (a-z) for n files
    "   f1      Save global marks
    "   <n      Save up to n lines from each register
    "   sn      Items bigger than n KiB are not saved
    "   h       Disable hlsearch highlighting
end

" Lua init (.config/nvim/lua/init.lua)
lua require('init')
