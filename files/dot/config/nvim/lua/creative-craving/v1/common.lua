local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local yank_group = augroup("HighlightYank", {})
local cc_group = augroup("CreativeCraving", {})

return {
    augroup = augroup,
    autocmd = autocmd,
    yank_group = yank_group,
    cc_group = cc_group,
}
