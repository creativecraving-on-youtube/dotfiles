local cc = require("creative-craving.v2.common")

local function config_diagnostics()
    local diagnostic_config = {
        float = {
            focasable = false,
            style = "minimal",
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
        },
    }
    vim.diagnostic.config(diagnostic_config)
end

local function config_capabilities()
    local capabilities = vim.tbl_deep_extend(
        "force", {},
        vim.lsp.protocol.make_client_capabilities()
    )
    vim.lsp.config("*", {
        capabilities = capabilities,
    })
end

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

local function lsp_generic(ev)
    vim.lsp.codelens.enable(true, {
        bufnr = ev.buf,
    })

    vim.lsp.inlay_hint.enable(true, {
        bufnr = ev.buf,
    })
end

--[[
vim.o.statusline = "%{luaeval('vim.lsp.status()')}"

-- Ensure it refreshes when progress updates arrive
vim.api.nvim_create_autocmd("LspProgress", {
  callback = function()
    vim.cmd("redrawstatus")
  end,
})
--]]


--[[
local lsp_status = ""
local function get_lsp_status()
    return lsp_status
end

vim.o.statusline = vim.o.statusline .. "%=" .. "%{v:lua.get_lsp_status()}"
_ = get_lsp_status


local function on_lsp_progress(ev)
    _ = ev
    local value = ev.data.params.value
    local status = value.kind ~= "end" and "running" or "success"
    lsp_status = (value.message or "done")
        .. (value.percentage and (
            " (" .. value.percentage .. "%)"
        ) or "")
        .. (value.title and (
            " [" .. value.title .. "]"
        ) or "")
    vim.cmd("redrawstatus")
end
--]]

cc.autocmd("LspProgress", {
    group = cc.cc_group,
    buffer = 0,
    callback = on_lsp_progress,
})


cc.autocmd("LspAttach", {
    group = cc.cc_group,
    pattern = '*',
    callback = lsp_generic,
})

config_diagnostics()
config_capabilities()
