local cc = require("creative-craving.v2.common")
local fns = require("creative-craving.v2.remap.fns")

local bindings = {
  { "n", "<leader>ct", function() vim.cmd([[!nvim --headless +q]]) end, { desc = "Test vim config for errors" }},
}

local function filetype_lua(ev)
    vim.lsp.enable("lua_ls")

    local options = {
        silent = true,
    }
    local _bindings = {}
    for _, binding in pairs(bindings) do
        binding[4] = vim.tbl_extend("keep", binding[4], options)
        table.insert(_bindings, binding)
    end
    fns.bind_keys(_bindings, { buffer = 0 })
end

cc.autocmd("FileType", {
    group = cc.cc_group,
    pattern = "lua",
    callback = filetype_lua,
})

local function lsp_attach(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client == nil then
        vim.notify("lsp_attach (lua): no client found", vim.log.levels.ERROR)
        return
    end

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

vim.lsp.config["lua_ls"] = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = {
        { ".luarc.json", ".neovim-lua-root-marker" },
        ".git",
    },
    settings = {
        Lua = {
            diagnostics = {
                globals = {
                    "vim", "it", "describe", "before_each", "after_each",
                },
            }
        },
    },
    capabilities = vim.lsp.config["*"].capabilities,
}
