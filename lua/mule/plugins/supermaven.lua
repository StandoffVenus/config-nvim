--- once will execute a function only once for a user. It achieves this by allocating an atomic resource
--- (i.e. once is "thread safe") and if the resource does not already exist, the function is run.
---
--- @param id string A unique ID to the backing resource once utilizes to determine atomicity.
--- @param fn function Any function to run only once for the user.
local function once(id, fn)
	local path = vim.fn.stdpath('data') .. '/' .. id
	if pcall(vim.fn.mkdir, path, '', '0o200') then
		fn()
	end
end

local function config()
	require('supermaven-nvim').setup({})

	local supermaven_api = require('supermaven-nvim.api')
	once('supermaven-first-activation', supermaven_api.use_free_version)

	vim.keymap.set('n', '<leader>sm', supermaven_api.toggle, {})
end

return {
	{
		'supermaven-inc/supermaven-nvim',
		config = config,
	},
}
