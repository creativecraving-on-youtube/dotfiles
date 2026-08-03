require("creative-craving.v1.lsp.help")
require("creative-craving.v1.lsp.lua")
require("creative-craving.v1.lsp.markdown")
require("creative-craving.v1.lsp.rust")
require("creative-craving.v1.lsp.c")
local cc = require("creative-craving.v1.common")

local data_dir = vim.fn.stdpath("data")
local lazy_path = data_dir .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazy_path) then
    print("Downloading lazy to", data_dir)
    vim.cmd("!mkdir -p " .. data_dir)
    vim.cmd("!git clone --filter=blob:none gh:folke/lazy.nvim --branch=stable " .. lazy_path)
end

vim.opt.rtp:prepend(lazy_path)
require("lazy").setup({
    spec = "creative-craving.v1.lazy",
    change_detection = { notify = false },
})

local function on_lsp_progress(ev)
    local value = ev.data.params.value
    local status = value.kind ~= "end" and "running" or "success"
    vim.api.nvim_echo({{ value.message or "done" }}, false, {
        -- Message ID to update in history
        id = "lsp." .. ev.data.params.token,
        kind = "progress",
        source = "vim.lsp",
        title = value.title,
        status = status,
        percent = value.percentage,
    })
end

cc.autocmd("LspProgress", {
    group = cc.cc_group,
    buffer = 0,
    callback = on_lsp_progress,
})

local function lsp_generic(ev)
    vim.lsp.codelens.enable(true, {
        bufnr = ev.buf,
    })

    vim.lsp.inlay_hint.enable(true, {
        bufnr = ev.buf,
    })
end

cc.autocmd("LspAttach", {
    group = cc.cc_group,
    pattern = '*',
    callback = lsp_generic,
})
