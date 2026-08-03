return {
  "folke/zen-mode.nvim",
  config = function ()
    vim.keymap.set('n', '<leader>zz', function ()
      local zen = require('zen-mode')
      zen.setup {
        window = {
          width = 180,
          options = {},
        },
      }

      zen.toggle()
      vim.wo.wrap = false
      vim.wo.number = true
      vim.wo.relativenumber = true
      vim.opt.colorcolumn = "0"
      -- ColorMyPencils()
    end)
  end,
}
