local cc = require("creative-craving.v2.common")

-- Highlight text after yanking
cc.autocmd("TextYankPost", {
    group = cc.yank_group,
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch",
            timeout = 80,
        })
    end,
})

local function format_buffer()
    -- Remove trailing spaces
    vim.cmd([[
        %s/\v\s+$//e
    ]])
end

-- Format text before saving
cc.autocmd("BufWritePre", {
    group = cc.cc_group,
    pattern = "*",
    callback = format_buffer,
})

cc.autocmd('FileType', {
    group = cc.cc_group,
    pattern = 'qf',
    callback = function ()
        vim.keymap.set(
            'n',
            'q',
            '<cmd>cclose<CR>', {
                buffer = true,
                silent = true,
            })
    end,
})
