-- Aliases for language to LSP
local docker = 'dockerls'
local lua = 'sumneko_lua'
local protobuf = 'bufls'
local go = 'gopls'

require('mason').setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		go,
		docker,
		lua,
	},
})

local lspconfig = require('lspconfig')
local cmp_lsp = require('cmp_nvim_lsp')

local lsp_servers = {
	protobuf,
	docker,
	go,
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

local cmp_capabilities = cmp_lsp.default_capabilities()
local on_attach = function(client, bufnr)
	local bufopts = {
		noremap = true,
		silent = true,
		buffer = bufnr,
	}

	vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, bufopts)
	vim.keymap.set('n', '<leader>ga', vim.lsp.buf.code_action, bufopts)
	vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, bufopts)

	vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
	vim.keymap.set('n', '<C-K>', vim.lsp.buf.signature_help, bufopts)
end

-- Set up all the LSP servers
for k, v in pairs(lsp_servers) do
	local settings = nil
	local lsp = v -- Assume that value is the LSP server name (initially)

	-- If the key is a string, that means we have a configured server
	if type(k) == 'string' then
		lsp = k
		settings = v
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

-- Diagnostics
vim.keymap.set('n', '<leader>K', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)

vim.diagnostic.config({
	virtual_text = true,
	update_in_insert = true,
	float = true,
})
