local backup_dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "backups")
vim.fn.mkdir(backup_dir, "p")

local options = {
    backspace = { 'indent', 'eol', 'start' }, -- explicit default
    backup = true,
    backupdir = backup_dir,
    confirm = true, -- confirm dangerous actions instead of asking for !
    exrc = true, -- allow project-level vim config

    -- together with backup, ensures that the first version of the file is
    -- saved, not any intermediate version while vim was open
    --patchmode = ".orig",  -- Disabled, because it doesn't save to backupdir
    shiftwidth = 4,
    softtabstop = 4,
    expandtab = true,
    -- Open splits in a normal fashion
    splitright = true,
    splitbelow = true,

    number = true,
    relativenumber = true,
    scrolloff = 3, -- Number of lines to keep above / below the cursor
    sidescrolloff = 5, -- Number of columns to keep left / right of the cursor
    linebreak = true, -- Sensible linebreaks for viewing (not saving)
    laststatus = 1, -- show the "window status" line only when there are multilpe windows
    gdefault = true, -- global substitution regexes '/g' by default
    display= { "lastline","uhex" }, -- misc text display settings

    completeopt={ "menuone", "popup", "preinsert", --[[ "noinsert" ]] },

    -- enhanced "wild" tab completion
    -- longest - First, compleet the longest common prefix
    --      :full - But, also show the wildmenu
    --  full - If user presses <Tab> again, match the first string in the list
    wildmenu = true,
    wildmode = { "longest:full", "full" },
    encoding = "utf-8", -- default encoding, if all else fails

    wrap = false,
    formatoptions = "tcqjroqn",
        --   t   autowrap text
        --   c   autowrap comments
        --   j   remove comment leader (e.g. //) when joining lines
        --   r   auto insert comment leader with i<Enter>
        --   o   auto insert comment leader with o or O
        --   q   format comments with gq, too
        --   n   wrap lists (e.g. "1.", "1)") (Uses 'formatlistpat')

    -- What gets saved with :mksession command?
    sessionoptions = {
        "blank",    -- empty windows
        "buffers",  -- hidden / unloaded buffers
        "curdir",   -- current dir
        "folds",    -- Manual folds & open/close state
        "help",     -- help windows
        "localoptions", -- Local options (lcd, etc)
        "options",  -- Global options & mappings
        "resize",   -- Vim's size
        "tabpages", -- All tabs. Otherwise, every tab has to have a separate session
        "winpos",   -- Position of window
        "winsize"   -- Size of windows
    },

    nrformats = {"bin", "octal", "hex"},
    shada={
        "!",        -- Store any ALL_UPPERCASE global variables
        "'1000",    -- Save marks (a-z) for 1000 files
        "f1",       -- Save global marks
        "<500",     -- Save up to 500 lines from each register
        "s100",     -- Items bigger than 100 KiB are not saved
        "h",        -- Disable hlsearch highlighting when loading from the shada file
    },
}

for opt, value in pairs(options) do
    vim.opt[opt] = value
end

vim.cmd([[
    let &formatlistpat="^\s*\d\+[\]:.)}\t ]\s*\|^\s*[-*]\s+"
    let &formatlistpat=string(&formatlistpat)
]])

-- Preserve transparent background of terminal
vim.cmd([[
    :highlight Normal guibg=NONE
]])


-- Check if any files need to be reloaded from disk
local autoreload = vim.api.nvim_create_augroup("autoreload", {
    clear = true, -- overwrite existing augroup
})
vim.api.nvim_create_autocmd(
    {
        "FocusGained",
        "CursorHold",   -- No cursor changes in normal mode
        -- "CursorHoldI",  -- No cursor changes in input mode
    },
    {
        group = autoreload,
        pattern = "*",
        command = "checktime"
    }
)

require("creative-craving.v2")
