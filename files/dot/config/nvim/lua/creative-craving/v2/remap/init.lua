local fns = require("creative-craving.v2.remap.fns")

vim.g.mapleader = " "

local bindings = {
  -- { modes, rhs, lhs, { desc = "documentation" } }
  { "n", "zz", function() fns.scroll_cursor_line_to_sweet_spot(0.25) end, { desc = "Scroll the cursor line into the sweet spot" }},
  { "n", "Q", "gq", { desc = "Reformat text" }},
  -- { {"n", "v"}, "<leader>d", "\"_d", { desc = "Delete text without saving it" }},
  { "n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostics in a popup" }},
  { "n", "<leader>DH", vim.diagnostic.hide, { desc = "Hide diagnostics" }},
  { "n", "<leader>DD", vim.diagnostic.show, { desc = "Unhide diagnostics" }},
  { "n", "n", "nzzzv", { desc = "Move match to center & unfold to make match visible" }},
  { "n", "N", "Nzzzv", { desc = "Move match to center & unfold to make match visible" }},
  { {"n", "i"}, "<F1>", function() vim.cmd("tab help") end, { desc = "Open help in a new tab" }},
  { {"n", "v"}, "<leader>gf", function() vim.cmd([[tab edit <cfile>]]) end, { desc = "Open the file under cursor in a new tab" }},
  { {"n", "v"}, "<leader>ll", function() vim.cmd([[checkhealth vim.lsp]]) end, { desc = "Check lsp status" }},
  { {"n", "v"}, "<leader>le", function() vim.cmd([[lsp enable]]) end, { desc = "Enable LSP for current and future buffers" }},
  { {"n", "v"}, "<leader>ld", function() vim.cmd([[lsp disable]]) end, { desc = "Disable LSP for current and future buffers" }},
  { {"n", "v"}, "<leader>ls", function() vim.cmd([[lsp stop]]) end, { desc = "Stop all LSP servers for this buffer" }},
  { {"n", "v"}, "<leader>lr", function() vim.cmd([[lsp restart]]) end, { desc = "Restart all LSP servers for this buffer" }},
}

local lsp_bindings = {
  -- { modes, rhs, lhs, { desc = "documentation" } }
  { "n", "gd", vim.lsp.buf.definition, { desc = "Jump to definition" }},
  { "n", "gi", vim.lsp.buf.implementation, { desc = "List impls, or go to the only one" }},
  { "n", "gr", vim.lsp.buf.references, { desc = "List impls, or go to the only one" }},
  { "n", "<leader>gt", vim.lsp.buf.type_definition, { desc = "Go to the type used by this symbol" }},
  { "n", "K", vim.lsp.buf.hover, { desc = "Hover docs for symbol under cursor" }},
  { "n", "<leader>vws", vim.lsp.buf.workspace_symbol, { desc = "List all symbols (quickfix)" }},
  { "n", "<leader>.", vim.lsp.buf.code_action, { desc = "Code fix at cursor" }},
  { "n", "<C-F12>", vim.lsp.buf.implementation, { desc = "List impls, or go to the only one" }},
  { "n", "<F24>", vim.lsp.buf.references, { desc = "List references to symbol (quickfix, <S-12>)" }},

    -- TODO: Make a rename-in-place UI using vim.lsp.util.rename
  { "n", "<leader>r", vim.lsp.buf.rename, { desc = "Rename symobl under cursor" }},
  { "i", "<C-h>", vim.lsp.buf.signature_help, { desc = "Show symbol's signature info (popup)" }},
  { "n", "[d", function() vim.diagnostic.jump({count=1, float=true}) end, { desc = "Go to next diagnostic" }},
  { "n", "]d", function() vim.diagnostic.jump({count=-1, float=true}) end, { desc = "Go to previous diagnostic" }},
  { {"n", "v"}, "<leader>lti", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, { desc = "Toggle inlay hints" }},
  { {"n", "v"}, "<leader>ltc", function() vim.lsp.codelens.enable(not vim.lsp.codelens.is_enabled()) end, { desc = "Toggle inlay hints" }},
}

local function keybindings_usage(with_lsp)
  local spec = {}
  spec["Bindings"] = bindings
  if with_lsp then
    spec["LSP Bindings"] = lsp_bindings
  end
  fns.keybindings_usage_for(spec)
end

-- table.insert(bindings, {
--   "n",
--   "<leader>?",
--   function() keybindings_usage(true) end,
--   { desc = "Summarize custom keybindings" }
-- })
fns.bind_keys(bindings)
--fns.bind_keys(lsp_bindings)

local cc = require("creative-craving.v2.common")
cc.autocmd('LspAttach', {
    group = cc.cc_group,
    callback = function(ev)
        fns.bind_keys(lsp_bindings, { buffer = ev.buf })
    end
})
