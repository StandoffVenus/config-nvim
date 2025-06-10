--- @class window
--- @field id integer The window's handle.
--- @field bufnr integer The window's buffer handle.
local current_window = {}

--- open_singleton_window will open a window with a unique identifier (or reopen
--- said window if it's already been created), also hiding any other windows
--- opened by this function.
---
--- @param opts? vim.api.keyset.win_config The window's configuration.
--- @return window window The opened window.
local function open_singleton_window(opts)
	opts = opts or {}
	opts.height = opts.height or math.floor(vim.o.lines * .75)
	opts.width = opts.width or math.floor(vim.o.columns * .75)
	opts.row = opts.row or math.floor((vim.o.lines - opts.height) / 2)
	opts.col = opts.col or math.floor((vim.o.columns - opts.width) / 2)

	if not vim.api.nvim_win_is_valid(current_window.id or -1) then
		if not vim.api.nvim_buf_is_valid(current_window.bufnr or -1) then
			current_window.bufnr = vim.api.nvim_create_buf(false, true)
		end

		current_window.id = vim.api.nvim_open_win(current_window.bufnr, true, opts)
	end


	return current_window
end

--- Opens the singleton window as a floating window if not already opened.
---
--- @param opts? vim.api.keyset.win_config The window's configuration. Some fields will be overwritten for floating purposes.
--- @return window window The opened window.
local function open_floating_window(opts)
	opts = opts or {}
	opts.relative = 'editor'
	opts.style = 'minimal'
	opts.border = 'shadow'

	return open_singleton_window(opts)
end

vim.g.mapleader = " "

-- Keep cursor centered when it jumps, such as ctrl+d or previous/next match
vim.api.nvim_create_autocmd(
	"CursorMoved",
	{
		command = [[ :exec "norm zz" ]],
	})

-- Open terminal in current window
vim.keymap.set('n', '<leader>sh', function()
	local win = open_floating_window()
	if vim.bo[win.bufnr].buftype ~= 'terminal' then
		vim.cmd.terminal()
	end
end)

vim.keymap.set(
	'v',
	'<leader>yy',
	'"+y',
	{ remap = true })
