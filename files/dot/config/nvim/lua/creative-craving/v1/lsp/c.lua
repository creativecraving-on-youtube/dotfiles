local cc = require("creative-craving.v1.common")
local fns = require("creative-craving.v1.remap.fns")

local function filetype(ev)
    vim.lsp.enable("clangd")
end

cc.autocmd("FileType", {
    group = cc.cc_group,
    pattern = "c",
    callback = filetype,
})
