--- @class Window
local Window = {
	_id = -1,
	_bufnr = -1,
	_opts = nil, --[[@type vim.api.keyset.win_config?]]
}

Window.__index = Window

--- Sets reasonable default options when unspecified.
---
--- @param opts vim.api.keyset.win_config?
--- @return vim.api.keyset.win_config
function Window.opts_with_defaults(opts)
	opts = opts or {}
	if opts.relative then
		opts.height = opts.height or math.floor(vim.o.lines * .85)
		opts.width = opts.width or math.floor(vim.o.columns * .85)
		opts.row = opts.row or math.floor((vim.o.lines - opts.height) / 2)
		opts.col = opts.col or math.floor((vim.o.columns - opts.width) / 2)
	else
		opts.height = opts.height or vim.o.lines
		opts.width = opts.width or vim.o.columns
	end

	return opts
end

--- Creates a new window instance. The window is not opened, however. To do so, use Window:open().
---
--- @return Window window The new window.
function Window:new()
	local win = {}
	setmetatable(win, self)
	return win
end

--- Focuses the window if it is open.
function Window:focus()
	if self:is_open() then
		vim.api.nvim_set_current_win(self._id)
	end
end

--- Resizes the window if it is open.
---
--- @param opts vim.api.keyset.win_config? The config to resize to. If not provided, existing window config is assumed.
function Window:resize(opts)
	if self:is_open() then
		opts = opts or table.copy(self._opts)
		opts.height = nil
		opts.width = nil
		opts.row = nil
		opts.col = nil
		self._opts = Window.opts_with_defaults(opts)

		vim.api.nvim_win_set_config(self._id, self._opts)
	end
end

--- If the window is not open, opens the window with the given configuration and enters it.
---
--- @param opts vim.api.keyset.win_config? The configuration of the opened window.
function Window:open(opts)
	if not self:is_open() then
		if not vim.api.nvim_buf_is_valid(self:bufnr()) then
			self._bufnr = vim.api.nvim_create_buf(false, true)
		end

		self._opts = Window.opts_with_defaults(opts)
		self._id = vim.api.nvim_open_win(self._bufnr, true, self._opts)
	end

	self:focus()
end

--- If the window is open, closes the window while preserving the buffer.
function Window:close()
	if self:is_open() then
		vim.api.nvim_win_close(self._id, false)
		self._id = -1
	end
end

--- @return boolean open Whether the window is currently open.
function Window:is_open()
	return vim.api.nvim_win_is_valid(self:id())
end

--- @return integer id This window's ID.
function Window:id()
	return self._id or -1
end

--- @return integer bufnr The buffer number associated with this window.
function Window:bufnr()
	return self._bufnr or -1
end

return Window
