require('go').setup({
	goimport = 'goimports',
	test_runner = 'richgo',
})

vim.api.nvim_create_autocmd('BufWritePre', {
	pattern = '*.go',
	callback = function()
		require('go.format').goimport()
	end,
})
