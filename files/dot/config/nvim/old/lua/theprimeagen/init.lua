-- require("theprimeagen.set") --vim opts / settings
require("theprimeagen.remap")
require("theprimeagen.lazy_init")

function R(name)
  require("plenary.reload").reload_module(name)
end

--[[
vim.filetype.add({
  extension = {
    temp1 = 'temp1',
  }
})
--]]

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local yank_group = augroup('HighlightYank', {})
local ThePrimeagenGroup = augroup('ThePrimeagen', {})

-- Highlight text after yanking
autocmd('TextYankPost', {
  group = yank_group,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({
      higroup = 'IncSearch',
      timeout = 40,
    })
  end,
})

-- Remove trailing spaces before saving
autocmd({'BufWritePre'}, {
  group = ThePrimeagenGroup,
  pattern = '*',
  command = [[%s/\v\s+$//e]],
})


-- Use LSP folding (rust_analyzer foldingRange) for Rust files
autocmd('LspAttach', {
  group = ThePrimeagenGroup,
  pattern = '*.rs',
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.supports_method('textDocument/foldingRange') then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win][0].foldmethod = 'expr'
      vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
      vim.wo[win][0].foldlevel = 99  -- start with all folds open
    end
  end,
})

-- Close Quickfix window with q, but only when inside the quickfix buffer
autocmd('FileType', {
  group = ThePrimeagenGroup,
  pattern = 'qf',
  callback = function()
    vim.keymap.set('n', 'q', '<cmd>cclose<CR>', { buffer = true, silent = true })
  end,
})

autocmd('FileType', {
  group = ThePrimeagenGroup,
  pattern = 'rust',
  callback = function()
    vim.opt_local.wrap = false
  end,
})

-- Show LSP keybindings help in a floating window
local lsp_help_lines = {
  "  LSP Keybindings",
  " ══════════════════════════════════════════",
  "  gd            Go to definition",
  "  K             Hover docs for symbol",
  "  <leader>vws   List workspace symbols (Quickfix)",
  "  <leader>vd    Show diagnostics popup",
  "  <leader>d     Show diagnostics popup",
  "  <A-Enter>     Code action",
  "  <leader>.     Code action",
  "  <C-.>         Code action",
  "  <F24>         List references (Quickfix)",
  "  <leader><C-R> Rename all references",
  "  <C-h>         Signature help (insert mode)",
  "  [d            Go to next diagnostic",
  "  ]d            Go to previous diagnostic",
  " ──────────────────────────────────────────",
  "  Trouble",
  "  <leader>tt    Toggle Trouble list",
  "  [t / ]t       Next / previous Trouble item",
  " ──────────────────────────────────────────",
  "  Cargo (Rust buffers only)",
  "  <leader>cc    cargo check",
  "  <leader>cf    cargo fmt",
  "  <leader>ct    cargo test",
  "  <leader>cl    cargo clippy",
  " ══════════════════════════════════════════",
  "  Press q or <Esc> to close",
}

function lsp_usage()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lsp_help_lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = 'wipe'

  local width = 48
  local height = #lsp_help_lines
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  })

  for _, key in ipairs({ 'q', '<Esc>' }) do
    vim.keymap.set('n', key, function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end, { buffer = buf, silent = true })
  end
end


-- Move the line under the cursor to the top 1/3rd or so of the current window.
-- Try to hit that sweet spot where it looks natural
function move_current_line_to_top_area()
  local view = vim.fn.winsaveview()
  local height = vim.api.nvim_win_get_height(0)
  local offset = math.floor(height / 4)
  view.topline = math.max(1, view.lnum - offset)
  vim.fn.winrestview(view)
end

vim.keymap.set('n', 'zz', move_current_line_to_top_area, {
  desc = "Move the line under cursor to that sweet spot where it looks natural"
})

-- Redefine code completion and code navigation keymaps when the LSP is
-- available
autocmd('LspAttach', {
  group = ThePrimeagenGroup,
  callback = function(e)
    local opts = { buffer = e.buf }

    function type_out(text)
      text_encoded = vim.api.nvim_replace_termcodes(text, true, false, true)
      vim.api.nvim_feedkeys(text_encoded, 'n', false)
    end

    vim.keymap.set('n', '<leader>?', lsp_usage, { desc = 'Show LSP keybindings help' })

    -- Go to definition
    vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, opts)
    -- Show hover docs for the symbol under cursor
    vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, opts)
    -- List all symbols in Quickfix window
    vim.keymap.set('n', '<leader>vws', function() vim.lsp.buf.workspace_symbol() end)
    -- Show neovim diagnostics in a popup
    vim.keymap.set('n', '<leader>d', function() vim.diagnostic.open_float() end, opts)
    -- Select some code action at current cursor position
    vim.keymap.set('n', '<A-Enter>', function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set('n', '<leader>.', function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set('n', '<C-.>', function() vim.lsp.buf.code_action() end, opts)
    -- List all references to symbol under cursor in the the Quickfix window
    vim.keymap.set('n', '<F24>', function() vim.lsp.buf.references() end, opts)
    -- Rename all references to symbol under cursor
    vim.keymap.set('n', '<leader><C-R>', function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set('n', '<leader>r', function() vim.lsp.buf.rename() end, opts)
    -- TODO: Make a rename-in-place action using vim.lsp.util.rename



    -- Display symbol's signature info in a popup
    vim.keymap.set('i', '<C-h>', function() vim.lsp.buf.signature_help() end, opts)
    -- Go to next diagnostic / error
    vim.keymap.set('n', '[d', function() vim.diagnostic.goto_next() end, opts)
    -- Go to previous diagnostic / error
    vim.keymap.set('n', ']d', function() vim.diagnostic.goto_prev() end, opts)
  end,
})
