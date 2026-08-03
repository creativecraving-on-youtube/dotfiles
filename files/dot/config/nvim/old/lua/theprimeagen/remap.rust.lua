local rust_cargo_group = vim.api.nvim_create_augroup('RustCargoFloatTerm', { clear = true })

local function open_floating_terminal(command, cwd)
	local buffer = vim.api.nvim_create_buf(false, true)
	local width = math.floor(vim.o.columns * 0.9)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local window = vim.api.nvim_open_win(buffer, true, {
		relative = 'editor',
		width = width,
		height = height,
		row = row,
		col = col,
		style = 'minimal',
		border = 'rounded',
	})

	local env = vim.tbl_extend('force', vim.fn.environ(), {
		CARGO_TARGET_DIR = 'target.nvim',
	})

	vim.fn.termopen(command, {
		cwd = cwd,
		env = env,
	})

	vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], { buffer = buffer, silent = true })
	vim.keymap.set('n', 'q', function()
		if vim.api.nvim_win_is_valid(window) then
			vim.api.nvim_win_close(window, true)
		end
	end, { buffer = buffer, silent = true })

	vim.cmd('startinsert')
end

local function find_cargo_root()
	local current_file = vim.api.nvim_buf_get_name(0)
	local start_path = current_file ~= '' and vim.fs.dirname(current_file) or vim.fn.getcwd()
	local cargo_file = vim.fs.find('Cargo.toml', { upward = true, path = start_path })[1]

	if not cargo_file then
		return nil
	end

	return vim.fs.dirname(cargo_file)
end

local function run_rust_cargo(command)
	local cargo_root = find_cargo_root()

	if not cargo_root then
		vim.notify('No Cargo.toml found for current buffer', vim.log.levels.WARN)
		return
	end

	open_floating_terminal('cargo ' .. command, cargo_root)
end

vim.api.nvim_create_autocmd('FileType', {
	group = rust_cargo_group,
	pattern = 'rust',
	callback = function(event)
		local options = { buffer = event.buf, silent = true }

		vim.keymap.set('n', '<leader>cc', function() run_rust_cargo('check') end,
			vim.tbl_extend('force', options, { desc = 'Cargo check (float)' }))
		vim.keymap.set('n', '<leader>cf', function() run_rust_cargo('fmt') end,
			vim.tbl_extend('force', options, { desc = 'Cargo fmt (float)' }))
		vim.keymap.set('n', '<leader>ct', function() run_rust_cargo('test') end,
			vim.tbl_extend('force', options, { desc = 'Cargo test (float)' }))
		vim.keymap.set('n', '<leader>cl', function() run_rust_cargo('clippy') end,
			vim.tbl_extend('force', options, { desc = 'Cargo clippy (float)' }))
	end,
})
