local function config_diagnostics()
    local diagnostic_config = {
        float = {
            focasable = false,
            style = "minimal",
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
        },
    }
    vim.diagnostic.config(diagnostic_config)
end

local function config_perl()
    vim.lsp.config("perlnavigator", {
        settings = {
            perlnavigator = {
                perlPath = "perl",
                enableWarnings = true,
                perlcriticEnabled = true,
            },
        },
    })
end

local function config_cmp()
    local cmp = require("cmp")
    local cmp_select = { behavior = cmp.SelectBehavior.Select }
    local cmp_config = {
        mapping = cmp.mapping.preset.insert({
            ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
            ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
            ["<C-y>"] = cmp.mapping.confirm({ select = true }),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = cmp.mapping.confirm({ select = true }),
            ["<C-Space>"] = cmp.mapping.complete(),
        }),

        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            -- { name = "luasnip" },
        }, {
            { name = "buffer" },
        }),
    }
    cmp.setup(cmp_config)
end

local function config_mason()
    local cmp_lsp = require("cmp_nvim_lsp")
    local capabilities = vim.tbl_deep_extend(
        "force", {},
        vim.lsp.protocol.make_client_capabilities(),
        cmp_lsp.default_capabilities()
    )

    vim.lsp.config("*", {
        capabilities = capabilities,
    })
    local root_markers = vim.lsp.config.lua_ls.root_markers
    table.insert(root_markers, 1, ".neovim-lua-root-marker")
    vim.lsp.config("lua_ls", {
        root_markers = root_markers,
        capabilities = capabilities,
        settings = {
            Lua = {
                diagnostics = {
                    globals = {
                        "vim", "it", "describe", "before_each", "after_each",
                    },
                }
            }
        },
    })

    vim.lsp.config("rust_analyzer", {
        capabilities = capabilities,
        settings = {
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
    })

    require("mason").setup()
end

local function config_lsp()
    config_diagnostics()
    config_cmp()
    config_mason()
    config_perl()
end



return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "mason-org/mason.nvim",

        -- Completion engine
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",

        -- Snippets
        -- "L3MON4D3/LuaSnip",
        -- "saadparwaiz1/cmp_luasnip",

        -- Pretty LSP UI
        -- "j-hui/fidget.nvim", -- broken for some reason
    },

    config = config_lsp,
}
