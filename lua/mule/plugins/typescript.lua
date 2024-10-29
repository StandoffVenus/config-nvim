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

local config    = function()
	-- typescript-tools module requires the Terraform Language Server executable
	-- so we'll ensure that Mason installs it
	-- require('mason-lspconfig').setup({
	-- 	ensure_installed = { 'tsserver' },
	-- })

	local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
	local lsp_utils = require("lspconfig.util")
	local ts_error_formatter = require("format-ts-errors")

	require('typescript-tools').setup({
		capabilities = lsp_capabilities,
		on_attach = on_attach,
		root_dir = lsp_utils.root_pattern(".git"),
		handlers = {
			["textDocument/publishDiagnostics"] = function(_, result, context, config)
				if result.diagnostics == nil then
					return
				end

				local ids = 1

				while ids <= #result.diagnostics do
					local entry = result.diagnostics[ids]

					local formatter = ts_error_formatter[entry.code]

					entry.message = formatter and formatter(entry.message) or entry.message

					ids = ids + 1
				end

				vim.lsp.diagnostic.on_publish_diagnostics(_, result, context, config)
			end,
		},
		settings = {
			expose_as_code_action = {
				"add_missing_imports",
				"remove_unused_imports",
			},
			tsserver_file_preferences = {
				quotePreference = "single",
			},
		},
	})
end

return {
	"pmizio/typescript-tools.nvim",

	dependencies = {
		"nvim-lua/plenary.nvim",
		"neovim/nvim-lspconfig",
		{
			"davidosomething/format-ts-errors.nvim",
			ft = {
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
			},
		},
	},

	config = config,
}
