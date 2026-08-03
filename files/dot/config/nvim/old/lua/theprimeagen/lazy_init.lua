local dataDir = vim.fn.stdpath("data")
local lazypath = dataDir .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  print("Downloading lazy to ", dataDir)
  vim.cmd("!mkdir -p " .. dataDir)
  vim.cmd("!git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable " ..lazypath)
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = "theprimeagen.lazy",
  change_detection = { notify = false },
})
