vim.g.mapleader = ' '

-- J oin command returns cursor to the same place it began
vim.keymap.set('n', 'J', "m'J''")

-- Scrolling up or down moves the cursor to the center of the screen
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- Searching: move matched line to center, and unfold until the match is visible
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

--
-- Paste Buffers
--

-- Paste over the selected text without saving it
vim.keymap.set({'n', 'x'}, '<leader>gp', '"_dP')
-- Delete without saving to a paste buffer
vim.keymap.set({'n', 'v'}, '<leader>d', '"_d')

-- Yank into system clipboard
vim.keymap.set({'n', 'v'}, '<leader>y', '"+y')
vim.keymap.set('n', '<leader>Y', '"+Y')

-- Paste from system clipboard
vim.keymap.set({'n', 'v'}, '<leader>p', '"+p')
vim.keymap.set('n', '<leader>P', '"+P')

--
-- Other
--

-- Re-wrap the line to fill textwidth
vim.keymap.set('n', 'Q', 'gq')
-- Open or create a tmux session
vim.keymap.set('n', '<C-f>', '<cmd>silent !tmux new-window tmux-sessionizer<CR>')

-- Source the (current?) file
vim.keymap.set('n', '<leader>so', function() vim.cmd('source') end)
vim.keymap.set('n', '<leader><leader>', '<nop>')

dofile(vim.fn.stdpath('config') .. '/lua/theprimeagen/remap.rust.lua')
