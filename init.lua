local DEBUG = vim.log.levels.DEBUG
local ERROR = vim.log.levels.ERROR

local modules = {
	'theme', -- Gotta look pretty first
	'remaps', -- Remaps have to happen before Lazy is loaded
	'lazy',
	'filetypes',
	'lsp_extensions',
	'opts',
}

local config_dir = vim.fn.stdpath('config')
vim.fn.readdir(config_dir, function(name)
	vim.notify('read file ' .. name, DEBUG)
end)

local mod_base = 'mule'
local loaded_mods = {}
for _, mod_name in pairs(modules) do
	local mod = mod_base .. '.' .. mod_name
	local ok, err = pcall(require, mod)
	if not ok then
		vim.notify('failed to load module "' .. mod .. '": ' .. tostring(err), ERROR)
	else
		table.insert(loaded_mods, mod)
	end
end

for order, mod in pairs(loaded_mods) do
	local msg = 'loaded module ' .. tostring(order) .. '. "' .. mod .. '"'
	vim.notify(msg, DEBUG)
end
