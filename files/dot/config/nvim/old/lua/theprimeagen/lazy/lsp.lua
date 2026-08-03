return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",

    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/nvim-cmp",
    "L3MON4D3/LuaSnip", -- pull snippets from LSP server
    "saadparwaiz1/cmp_luasnip", -- LuaSnip completion tool
    "j-hui/fidget.nvim",
  },

  config = function()
    local cmp = require('cmp')
    local cmp_lsp = require('cmp_nvim_lsp')
    local capabilities = vim.tbl_deep_extend(
        'force', {},
        vim.lsp.protocol.make_client_capabilities(),
        cmp_lsp.default_capabilities())

    local lspconfig = require('lspconfig')

    local mason_lspconfig_config = {
      ensure_installed = {
        "lua_ls",
        "rust_analyzer",
        "tsserver",
        "perlnavigator",
      },

      handlers = {
        -- default handler (optional)
        function(server_name)
          lspconfig[server_name].setup {
            capabilities = capabilities
          }
        end,

        ["lua_ls"] = function()
          lspconfig.lua_ls.setup {
            settings = {
              Lua = {
                diagnostics = {
                  globals = {
                    "vim", "it", "describe", "before_each", "after_each",
                  },
                },
              },
            },
          }
        end,

        ["rust_analyzer"] = function()
          lspconfig.rust_analyzer.setup {
            capabilities = capabilities,
            settings = {
              ["rust-analyzer"] = {
                cargo = {
                  allFeatures = true,
                  targetDir = "target.nvim",
                },
                checkOnSave = {
                  command = "clippy",
                },
                procMacro = {
                  enable = true,
                },
              },
            },
          }
        end,
      }
    }

    local cmp_select = { behavior = cmp.SelectBehavior.Select }
    local cmp_config = {
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },

      mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
      }),

      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
      }, {
        { name = 'buffer' },
      }),
    }

    local diagnostic_config = {
      -- update_in_insert = true,
      float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
    }

    -- It's broken for some reason
    --require("fidget").setup({})
    require("mason").setup()
    require("mason-lspconfig").setup(mason_lspconfig_config)

    lspconfig.perlnavigator.setup({
      settings = {
        perlnavigator = {
          perlPath = 'perl',
          enableWarnings = true,
          perlcriticEnabled = true,
        },
      },
    })

    cmp.setup(cmp_config)
    vim.diagnostic.config(diagnostic_config)
  end,
}
