-- Aliases for language to LSP
local docker      = 'dockerls'
local lua         = 'lua_ls'
local protobuf    = 'buf_ls'
local gleam       = 'gleam'
local go          = 'gopls'
local java        = 'jdtls'
local terraform   = 'terraformls'
local zig         = 'zls'

local lsp_servers = {
	protobuf,
	docker,
	gleam,
	go,
	java,
	terraform,
	zig,
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

	require('mason').setup()
	require('mason-lspconfig').setup()

	local cmp_lsp = require('cmp_nvim_lsp')
	local cmp_capabilities = cmp_lsp.default_capabilities()

	-- Set up all the LSP servers
	for k, v in pairs(lsp_servers) do
		local settings
		local lsp

		-- If the key is a string, that means we have a configured server
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
