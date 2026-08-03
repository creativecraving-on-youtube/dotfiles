
local cc = require("creative-craving.v1.common")

local options = {
    textwidth = 0,
    wrap = true,
    formatoptions = "jro",
}

local function filetype_markdown(event)
    for opt, value in pairs(options) do
        vim.opt_local[opt] = value
    end
end

cc.autocmd("FileType", {
    group = cc.cc_group,
    pattern = "markdown",
    callback = filetype_markdown,
})
