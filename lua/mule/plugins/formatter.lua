local config = function()
	local javascripty_formatters = {
		"eslint_d",
		"prettierd",
	}

	require("conform").setup({
		formatters_by_ft = {
			javascript = { javascripty_formatters },
			typescript = { javascripty_formatters },
			javascriptreact = { javascripty_formatters },
			typescriptreact = { javascripty_formatters },
		},
		format_on_save = {
			timeout_ms = 500,
			lsp_fallback = true,
		},
	})
end

return {
	'stevearc/conform.nvim',
	config = config,
	opts = {},
}
