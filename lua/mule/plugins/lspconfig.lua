-- Aliases for language to LSP
local docker      = 'dockerls'
local lua         = 'lua_ls'
local protobuf    = 'bufls'
local go          = 'gopls'
local typescript  = 'tsserver'
local java        = 'jdtls'
local terraform   = 'terraformls'

local lsp_servers = {
	protobuf,
	docker,
	go,
	typescript,
	java,
	terraform,
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

local config      = function()
	local lspconfig = require('lspconfig')
	local cmp_lsp = require('cmp_nvim_lsp')
	local mason = require('mason')
	local mason_lspconfig = require('mason-lspconfig')

	mason.setup()
	mason_lspconfig.setup({
		ensure_installed = {
			docker,
			lua,
		},
	})

	local cmp_capabilities = cmp_lsp.default_capabilities()
	local on_attach = function(_, bufnr)
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

	local notify = require('notify')
	notify('LSP config loaded', 'debug')
end

return {
	'neovim/nvim-lspconfig',

	dependencies = {
		'williamboman/mason.nvim',
		'williamboman/mason-lspconfig.nvim',
	},

	config = config,
}
