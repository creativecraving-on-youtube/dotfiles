require("creative-craving.v1.fns")

local function run_terminal(command, cwd)
    local buffer = vim.api.nvim_create_buf(false, true)
    local specs = get_floating_win_specs(0)
    local win = vim.api.nvim_open_win(buffer, true, {
        relative = "editor",
        width = specs.width,
        height = specs.height,
        row = specs.row,
        col = specs.col,
        style = "minimal",
    })

    local env = vim.tbl_extend('force', vim.fn.environ(), {
        CARGO_TARGET_DIR = 'target.nvim',
    })

    vim.fn.termopen(command, {
        cwd = cwd,
        env = env,
    })

    vim.keymap.set("n", "q",
        function()
            if vim.api.nvim_win_is_valid(window) then
                vim.api.nvim_win_close(window, true)
            end
        end, {
            buffer = buffer,
            silent = true
        })
    -- vim.cmd("startinsert")
end

local function find_cargo_root()
    local current_file = vim.api.nvim_buf_get_name(0)
    local start_path = vim.fs.dirname(current_file)
    if current_file == "" then
        start_path = vim.fn.getcwd()
    end

    local cargo_file = vim.fs.find("Cargo.toml", {
        upward = true,
        path = start_path,
    })[1]

    return vim.fs.dirname(cargo_file)
end

function run_cargo(command)
    local cargo_root = find_cargo_root()
    if not cargo_root then
        vim.notify("No Cargo.toml found for current buffer", vim.log.levels.WARN)
        return
    end

    run_terminal("cargo " .. command, cargo_root)
end
