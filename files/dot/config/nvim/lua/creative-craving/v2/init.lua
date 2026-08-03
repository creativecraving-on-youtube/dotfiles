require("creative-craving.v2.remap")
local fns = require("creative-craving.v2.fns")
require("creative-craving.v2.misc")

require("creative-craving.v2.language")
if not fns.is_headless() then
    vim.notify(fns.motd())
end
