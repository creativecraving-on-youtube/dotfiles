local cc = require("creative-craving.v1.common")
local function filetype_lua()
    vim.lsp.enable("lua_ls")
end

cc.autocmd("FileType", {
    group = cc.cc_group,
    pattern = "lua",
    callback = filetype_lua,
})

local function lsp_attach(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    if client.name == "lua_ls" and client:supports_method("textDocument/completion") then
        vim.lsp.completion.enable(true, client.id, ev.buf, {
            autotrigger = true
        })
    end
end

cc.autocmd("LspAttach", {
    group = cc.cc_group,
    pattern = "*.lua",
    callback = lsp_attach,
})
