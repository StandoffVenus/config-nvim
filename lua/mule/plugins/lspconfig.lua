local lsp_servers = {
	-- Docker
	'dockerls',

	-- Gleam
	'gleam',

	-- Go
	'gopls',

	-- Java
	'jdtls',

	-- Lua
	['lua_ls'] = {
		Lua = {
			runtime = {
				version = 'LuaJIT',
				path = {
					'lua/?.lua',
					'lua/?/init.lua',
				},
			},
			diagnostics = {
				enable = true,
				globals = { 'vim' },
			},
			workspace = {
				checkThirdParty = true,
				library = {
					vim.env.VIMRUNTIME,
					unpack(vim.api.nvim_get_runtime_file('', true)),
				},
			},
			telemetry = { enable = false },
		},
	},

	-- Protobuf
	['buf_ls'] = {
		cmd = {
			'buf', 'beta', 'lsp',
			'--timeout=0',
			'--log-format=text',
			'--debug'
		},
	},

	-- Terraform
	'terraformls',

	-- Zig
	'zls',
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
	vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, bufopts)

	vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
	vim.keymap.set('i', '<C-K>', vim.lsp.buf.signature_help, bufopts)
end

local config      = function()
	local lspconfig = require('lspconfig')

	local mason = require('mason')
	mason.setup()

	local cmp_lsp = require('cmp_nvim_lsp')
	local cmp_capabilities = cmp_lsp.default_capabilities()

	-- Set up all the LSP servers
	for k, v in pairs(lsp_servers) do
		local settings
		local lsp

		-- As we iterate, we'll either have integers/numbers (indices)
		-- or we'll have strings (keys). If the key is a string, that
		-- means we have a configured server and the value should a
		-- table of settings.
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
	local bind_diagnostic_jump = function(opts)
		return function() vim.diagnostic.jump(opts) end
	end
	vim.keymap.set('n', '<leader>K', vim.diagnostic.open_float)
	vim.keymap.set('n', ']d', bind_diagnostic_jump({ count = 1 }))
	vim.keymap.set('n', '[d', bind_diagnostic_jump({ count = -1 }))

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
