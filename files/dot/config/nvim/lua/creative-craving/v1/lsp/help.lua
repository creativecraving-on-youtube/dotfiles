local cc = require("creative-craving.v1.common")
local fns = require("creative-craving.v1.remap.fns")

local bindings = {
    {{ "n", "v"}, "<leader><C-]>", fns.tag_under_cursor_in_new_tab, { desc = "open tag under cursor" }},
}

local function filetype_help()
    fns.bind_keys(bindings)
end

cc.autocmd("FileType", {
    group = cc.cc_group,
    pattern = "help",
    callback = filetype_help,
})
