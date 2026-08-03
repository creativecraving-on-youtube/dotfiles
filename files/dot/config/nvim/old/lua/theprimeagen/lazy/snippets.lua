return {
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },

    config = function ()
      local ls = require("luasnip")
      ls.filetype_extend('javascript', { 'jsdoc' })

      -- expand snippet at cursor
      vim.keymap.set({"i"}, "<C-s>e", function() ls.expand() end, { silent = true })

      -- jump back and forward in the snippet
      vim.keymap.set({ "i", "s"}, "<C-s>;", function() ls.jump(1) end, { silent = true })
      vim.keymap.set({ "i", "s"}, "<C-s>,", function() ls.jump(-1) end, { silent = true })

      -- Change choice
      vim.keymap.set({"i", "s"}, "<C-s>n", function ()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, { silent = true })
    end,
  }
}
