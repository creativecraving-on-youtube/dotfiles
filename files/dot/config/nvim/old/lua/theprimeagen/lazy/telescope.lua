return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.5",

  dependencies = {
    "nvim-lua/plenary.nvim"
  },

  config = function ()
    require('telescope').setup({})
    local builtin = require('telescope.builtin')
    -- Search git files
    vim.keymap.set('n', '<C-p>', builtin.git_files, {})
    -- Search misc files
    vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
    -- Search help documentation
    vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})

    vim.keymap.set('n', '<leader>pws', function ()
      local word = vim.fn.expand("<cword>")
      builtin.grep_string({ search = word })
    end)
    vim.keymap.set('n', '<leader>pWs', function ()
      local word = vim.fn.expand("<cWORD>")
      builtin.grep_string({ search = word })
    end)
    vim.keymap.set('n', '<leader>ps', function ()
      local word = vim.fn.input("Grep> ")
      builtin.grep_string({ search = word })
    end)

  end,
}
