require("theprimeagen")

--[[

local lazyPath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazyPath) then
  vim.fn.system({
    "git", "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazyPath,
  })
end
vim.opt.rtp:prepend(lazyPath)

-- Completion options -- used by hrsh7th/nvim-cmp
vim.opt.completeopt = {'menuone', 'preview', 'longest', }
vim.opt.shortmess = vim.opt.shortmess + { c = true }

local lazyPlugins = {
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  "neovim/nvim-lspconfig",
  "simrat39/rust-tools.nvim",
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-nvim-lua",
  "VonHeikemen/lsp-zero.nvim",
}


function setupLazyPlugins()
  if not plugin_lazy_loaded then
    -- lazy only supports loading once, for whatever reason
    require("lazy").setup(lazyPlugins)
    plugin_lazy_loaded = true
  end
end

setupLazyPlugins()

local lsp = require("lsp-zero")
lsp.preset("recommended")
lsp.setup()


require("mason").setup()
require("mason-lspconfig").setup()

local rustTools = require("rust-tools")
rustTools.setup({
  server = {
    on_attach = function(_, bufferNo)
      -- Hover actions
      vim.keymap.set("n", "<C-space>",
          rustTools.hover_actions.hover_actions, { buffer = bufferNo })
      vim.keymap.set("n", "<Leader>a",
          rustTools.code_action_group.code_action_group, { buffer = bufferNo })
    end,
  },
})

-- NVim Diagnostics config
vim.diagnostic.config({
  virtual_text = false,
  update_in_insert = true,
  --signs = true,
  -- underline = true,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  }
})

-- Show rust/LSP error messages in the left column
vim.api.nvim_set_option_value('signcolumn', 'yes', {scope = "global"})

-- Set amount of time NVim waits before triggering the CurserHold event in ms
-- Also sets the amount of time between writes to the swap file
vim.api.nvim_set_option_value('updatetime', 500, {scope = "global"})

-- Show full rust/LSP error messages when the cursor pauses at over an error'd line
vim.api.nvim_create_autocmd('CursorHold', {
  pattern = '*',
  callback= function ()
    if not vim.diagnostic.open_float then return end
    vim.diagnostic.open_float(nil, { focusable = false })
  end
})

function setupCmp()
  local cmp = require('cmp')
  if not cmp then return end

  local commonKeywordLength = 3
  cmp.setup({
    mapping = {
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<Tab>'] = cmp.mapping.select_next_item(),
      ['<S-Tab>'] = cmp.mapping.select_prev_item(),

      ['<C-Space>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      })
    },

    sources = {
      { name = 'nvim_lsp', keyword_length = commonKeywordLength },
      { name = 'buffer', keyword_length = commonKeywordLength },
      { name = 'nvim_lua', keyword_length = commonKeywordLength },
    },

    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },

    formatting = {
      fields = {'menu', 'abbr', 'kind'},
      format = function(entry, item)
        -- Set item format based on completion source
        local menuIcon = {
          nvim_lsp = 'λ',
          buffer = 'Ω',
          nvim_lua = '𝑙',
        }
        item.menu = menuIcon[entry.source.name]
        return item
      end,
    },
  })
end
--]]
