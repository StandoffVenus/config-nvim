local DEBUG = vim.log.levels.DEBUG
local ERROR = vim.log.levels.ERROR

local modules = {
	'opts',
	'remaps',
	'lazy',
	'filetypes',
	'lsp_extensions',
	'path',
}

local config_dir = vim.fn.expand('~')
if not config_dir then
	local err --[[@as string]]
	config_dir, err = vim.uv.os_homedir()
	if not config_dir then
		error(err)
	end
end

local mod_base = 'mule'
for _, mod_name in pairs(modules) do
	local mod = mod_base .. '.' .. mod_name
	local ok, err = pcall(require, mod)
	if not ok then
		vim.notify('failed to load module "' .. mod .. '": ' .. tostring(err), ERROR)
	else
		vim.notify('loaded module "' .. mod .. '"', DEBUG)
	end
end
