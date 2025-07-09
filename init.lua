local DEBUG = vim.log.levels.DEBUG
local ERROR = vim.log.levels.ERROR

--- @generic T
--- @param o T
--- @return T
local function copy(o, seen)
	seen = seen or {}
	if o == nil then return nil end
	if seen[o] then return seen[o] end

	local no
	if type(o) == 'table' then
		no = {}
		seen[o] = no

		for k, v in next, o, nil do
			no[copy(k, seen)] = copy(v, seen)
		end
		setmetatable(no, copy(getmetatable(o), seen))
	else -- number, string, boolean, etc
		no = o
	end

	return no
end

if not table.copy then
	--- @param t table?
	--- @return table?
	function table.copy(t, seen)
		seen = seen or {}
		if t == nil then return nil end
		if seen[t] then return seen[t] end


		local no = {}
		seen[t] = no
		setmetatable(no, copy(getmetatable(t), seen))

		for k, v in next, t, nil do
			k = (type(k) == 'table') and table.copy(k, seen) or k
			v = (type(v) == 'table') and table.copy(v, seen) or v
			no[k] = v
		end
		return no
	end
end

if not table.reverse then
	--- @generic T
	--- @param t T[]
	--- @return T[]
	function table.reverse(t)
		local r = {}
		for _, v in ipairs(t) do
			table.insert(r, 1, v)
		end

		return r
	end
end


if not table.pack then
	if not pack then
		--- @param ... any
		--- @return table
		pack = function(...)
			local tbl = { ... } --[[@type table]]
			tbl.n = select('#', ...) --[[@type integer]]
			return tbl
		end
	end

	table.pack = pack
end

--- @type ('/'|'\\') sep The separator for file paths on this system.
local filepath_seperator = package.config:sub(1, 1)

--- @param ... string
local function join_filepath(...)
	local tbl = table.pack(...)
	return vim.fn.resolve(table.concat(tbl, filepath_seperator))
end

--- @param n string The file name.
--- @return (0|1)
local matches_lua_file = function(n) return n:match('.lua$') and 1 or 0 end

--- @generic T
--- @param elems T[]
--- @param  ... T The values to find and move to the front of the list. The values are moved in a stack order (FILO)
local function move_to_front(elems, ...)
	local args = table.reverse({ ... })
	for _, match_v in ipairs(args) do
		for i, elems_v in ipairs(elems) do
			if match_v == elems_v then
				local v = table.remove(elems, i)
				table.insert(elems, 1, v)
				break
			end
		end
	end
end

local config_dir = vim.fn.stdpath('config')
local mod_base = 'mule'
local modules_dir = join_filepath(config_dir, 'lua', mod_base)
local lua_files = vim.fn.readdir(modules_dir, matches_lua_file)

local modules = {}
for _, name in ipairs(lua_files) do
	local trimmed_name = name:gsub('%.lua', '')
	table.insert(modules, trimmed_name)
end

move_to_front(modules, 'theme', 'remaps')

for _, mod in ipairs(modules) do
	local full_name = mod_base .. '.' .. mod
	local ok, err = pcall(require, full_name)
	if not ok then
		vim.notify('failed to load module ' .. full_name .. ': ' .. tostring(err), ERROR)
	else
		vim.notify('loaded module ' .. full_name, DEBUG)
	end
end
