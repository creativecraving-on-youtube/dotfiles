require("creative-craving.v1.remap")
local fns = require("creative-craving.v1.fns")
require("creative-craving.v1.lsp")
require("creative-craving.v1.misc")
if not fns.is_headless() then
    vim.notify(fns.motd())
end
