--- @class Window
local Window = {
	_id = -1,
	_bufnr = -1,
}

Window.__index = Window

--- @param opts vim.api.keyset.win_config?
--- @return vim.api.keyset.win_config
local function opts_with_defaults(opts)
	local opts = opts or {}
	opts.height = opts.height or math.floor(vim.o.lines * .85)
	opts.width = opts.width or math.floor(vim.o.columns * .85)

	if opts.relative then
		opts.row = opts.row or math.floor((vim.o.lines - opts.height) / 2)
		opts.col = opts.col or math.floor((vim.o.columns - opts.width) / 2)
	end

	return opts
end

--- Alias for `vim.api.nvim_buf_is_valid`.
---
--- @param bufnr integer?
--- @return boolean
local function is_buf_valid(bufnr)
	return vim.api.nvim_buf_is_valid(bufnr or -1)
end

--- Creates a new window instance. The window is not opened, however. To do so, use Window:open().
---
--- @return Window window The new window. If o was provided, this window will be a subclass of Window.
function Window:new()
	local win = {}
	setmetatable(win, self)
	return win
end

--- Opens the window with the given configuration and enters it. No-op if the window is already opened.
---
--- @param opts vim.api.keyset.win_config? The configuration of the opened window.
function Window:open(opts)
	if not self:is_open() then
		if not is_buf_valid(self._bufnr) then
			self._bufnr = vim.api.nvim_create_buf(false, true)
		end

		opts = opts_with_defaults(opts)
		self._id = vim.api.nvim_open_win(self._bufnr, true, opts)
	end
end

--- Closes the window if opened but does not destroy the buffer.
function Window:close()
	if self:is_open() then
		vim.api.nvim_win_close(self._id, false)
		self._id = -1
	end
end

--- @return boolean open Whether the window is currently open.
function Window:is_open()
	return vim.api.nvim_win_is_valid(self._id)
end

--- @return integer id This window's ID.
function Window:id()
	return self._id
end

--- @return integer bufnr The buffer number associated with this window.
function Window:bufnr()
	return self._bufnr
end

return Window
