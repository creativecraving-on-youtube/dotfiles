return {
  "danymat/neogen",
  -- Use any _stable_ verison
  version = "*",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "L3MON4D3/LuaSnip",
  },

  config = function ()
    local neogen = require("neogen")
    neogen.setup({
      snippet_engine = "luasnip",
    })

    vim.keymap.set('n', '<leader>nf', function()
      neogen.generate({ type = "func" })
    end)

    vim.keymap.set('n', '<leader>nt', function ()
      neogen.generate({ type = "type" })
    end)
  end,
}
