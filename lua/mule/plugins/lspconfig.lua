-- Aliases for language to LSP
local docker    = 'dockerls'
local lua       = 'lua_ls'
local gleam     = 'gleam'
local go        = 'gopls'
local java      = 'jdtls'
local terraform = 'terraformls'
local zig       = 'zls'
local protobuf  = 'buf_ls'

--- Serializes a value into a string, recursively iterating table fields.
--- @param val any The value to serialize.
--- @param name? string The name of a table field. Should not be set by callers; reserved for recursion.
--- @param depth? number The depth of recursion. Should not be set by callers; reserved for recursion.
--- @return string serialized The serialization of the value.
local function table_tostring(val, name, depth)
	depth = depth or 0
	local tmp = string.rep(" ", depth)
	if name then tmp = tmp .. name .. " = " end

	local typeOfVal = type(val)
	if typeOfVal == "table" then
		tmp = tmp .. "{" .. "\n"
		for k, v in pairs(val) do
			tmp = tmp .. table_tostring(v, k, depth + 1) .. ",\n"
		end

		tmp = tmp .. string.rep(" ", depth) .. "}"
	elseif typeOfVal == "number" or type(val) == "boolean" then
		tmp = tmp .. tostring(val)
	elseif typeOfVal == "string" then
		tmp = tmp .. string.format("%q", val)
	else
		tmp = tmp .. "\"[inserializeable datatype:" .. typeOfVal .. "]\""
	end

	return tmp
end

--- Serializes a table into a more human-readable string.
--- If the table is `nil`, an empty string is returned.
--- @param tbl table The table to serialize.
--- @return string serialized The serialization of the table.
function table.to_pretty_string(tbl)
	if tbl then
		return table_tostring(tbl)
	end

	return ""
end

local lsp_servers = {
	docker,
	gleam,
	go,
	java,
	terraform,
	zig,
	[protobuf] = {
		cmd = { 'buf', 'beta', 'lsp', '--timeout=0', '--log-format=text', '--debug' },
	},
	[lua] = {
		Lua = {
			runtime = {
				version = 'LuaJIT'
			},
			diagnostics = {
				globals = { 'vim' },
			},
			workspace = {
				library = {
					vim.api.nvim_get_runtime_file('', true),
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
				},
			},
			telemetry = {
				enable = false
			},
		},
	},
}

local on_attach   = function(_, bufnr)
	local bufopts = {
		noremap = true,
		silent = true,
		buffer = bufnr,
	}

	vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, bufopts)
	vim.keymap.set('n', '<leader>ga', vim.lsp.buf.code_action, bufopts)
	vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, bufopts)
	vim.keymap.set('n', '<leader>gn', vim.lsp.buf.rename, bufopts)

	vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
	vim.keymap.set('i', '<C-K>', vim.lsp.buf.signature_help, bufopts)
end

local config      = function()
	local lspconfig = require('lspconfig')
	vim.lsp.set_log_level('debug')

	require('mason').setup()
	require('mason-lspconfig').setup()

	local cmp_lsp = require('cmp_nvim_lsp')
	local cmp_capabilities = cmp_lsp.default_capabilities()

	-- Set up all the LSP servers
	for k, v in pairs(lsp_servers) do
		local settings
		local lsp

		-- As we iterate, we'll either have integers/numbers (indices)
		-- or we'll have strings (keys). If the key is a string, that
		-- means we have a configured server
		if type(k) == 'string' then
			lsp = k
			settings = v
		else
			lsp = v
		end

		lspconfig[lsp].setup {
			on_attach = on_attach,
			capabilities = cmp_capabilities,
			settings = settings,
		}

		-- FOR DEBUGGING
		--local msg = "Loaded LSP configuration:" .. lsp
		--if settings then
		--	msg = msg .. "\n" .. table_tostring(settings)
		--end
		--vim.notify(msg)
	end

	vim.api.nvim_create_autocmd('BufWritePre', {
		pattern = '*.lua',
		callback = function()
			vim.lsp.buf.format({ async = false })
		end,
	})

	vim.api.nvim_create_autocmd({ "BufWritePre" }, {
		pattern = { "*.tf", "*.tfvars" },
		callback = function()
			vim.lsp.buf.format({ async = false })
		end,
	})

	-- Diagnostics
	vim.keymap.set('n', '<leader>K', vim.diagnostic.open_float)
	vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
	vim.keymap.set('n', ']d', vim.diagnostic.goto_next)

	vim.diagnostic.config({
		virtual_text = true,
		update_in_insert = true,
		float = true,
	})
end

return {
	'neovim/nvim-lspconfig',

	dependencies = {
		'williamboman/mason.nvim',
		'williamboman/mason-lspconfig.nvim',
	},

	config = config,
}
