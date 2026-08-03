local cc = require("creative-craving.v2.common")
local fns = require("creative-craving.v2.remap.fns")
local bindings = {
  --{ "n", "<leader>cc", function() run_cargo("clippy") end, { desc = "cargo clippy" }},
  --{ "n", "<leader>ct", function() run_cargo("test") end, { desc = "cargo test" }},
  --{ "n", "<leader>cb", function() run_cargo("build") end, { desc = "cargo build" }},
}


local function lsp_attach_rust(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then
        vim.notify("lsp_attach (lua): no client found", vim.log.levels.ERROR)
        return
    end
    if client:supports_method("textDocument/foldingRange") then
        local win = vim.api.nvim_get_current_win()
        vim.wo[win][0].foldmethod = "expr"
        vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
        vim.wo[win][0].foldlevel = 2 -- start with most folds closed
    end

    if client:supports_method("textDocument/completion") then
        vim.lsp.completion.enable(true, client.id, args.buf, {
            autotrigger = true
        })
    end
end

local function filetype_rust(args)
    vim.lsp.enable("rust_analyzer")
    local options = {
        buffer = args.buf,
        silent = true,
    }

    local _bindings = {}
    for _, binding in pairs(bindings) do
        binding[4] = vim.tbl_extend("keep", binding[4], options)
        table.insert(_bindings, binding)
    end
    fns.bind_keys(_bindings)
end

cc.autocmd("LspAttach", {
    group = cc.cc_group,
    pattern = '*.rs',
    callback = lsp_attach_rust,
})

cc.autocmd("FileType", {
    group = cc.cc_group,
    pattern = "rust",
    callback = filetype_rust,
})

local __enable = { enable = true }
local __disable = { enable = false }
local settings = {
    assist = {
        preferSelf = true,
    },
    cargo = {
        allTargets = true,
        features = "all",
        targetDir = "target/target.nvim", -- Use a custom target dir under target/
        --cfgs = { }, -- List of configs to enable by default
    },
    checkOnSave = true,
    check = {
        command = "clippy",
        allTargets = true,
        features = "all",
    },
    completion = {
        fullFunctionSignatures = __enable,
        privateEditable = __enable,
    },
    diagnostics = {
        experimental = __disable,
        styleLints = __enable,
    },
    gotoImplementations = {
        filterAdjacentDerives = true,
    },
    hover = {
        actions = {
            debug = __disable,
            run = __disable,
        },
        show = {
            traitAssocItems = 5,
        },
    },
    imports = {
        granularity = {
            group = "module",
        },
        preferPrelude = true,
        prefix = "self",
    },
    inlayHints = {
        bindingModeHints = __enable,
        closureCaptureHints = __enable,
        closureReturnTypeHints = { enable = "always" },
        closureStyle = "rust_analyzer",
        discriminantHints = { enable = "always" },
        expressionAdjustmentHints = { enable = "always" },
        implicitDrops = __enable,
        implicitSizedBoundHints = __enable,
        lifetimeElisionHints = {
            enable = "skip_trivial",
            useParameterNames = true,
        },
        parameterHints = {
            missingArguments = __enable,
            rangeExclusiveHints = __enable,
        }
    },
    lens = {
        enable = true,
        location = "above_whole_item",
        references = {
            adt = __enable,
            enumVariant = __enable,
            method = __enable,
            trait = __enable,
        },
        run = __disable,
    },
    references = {
        excludeImports = true,
        excludeTests = true,
    },

    typing = {
        triggerChars = "=.{<>"
    }
}
vim.lsp.config("rust_analyzer", {
    cmd = { "rust-analyzer" },
    root_markers = {
        { "Cargo.lock" },
        ".git",
    },
    cmd_env = {
        RA_LOG = "rust_analyzer=info",
    },
    -- Reference: https://rust-analyzer.github.io/book/configuration.html
    init_options = settings,
    settings = settings,
    capabilities = vim.lsp.config["*"].capabilities,
})
