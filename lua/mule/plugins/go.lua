return {
	'ray-x/go.nvim',

	dependencies = {
		'ray-x/guihua.lua',
		'mfussenegger/nvim-dap',
		'rcarriga/nvim-dap-ui',
		'theHamsta/nvim-dap-virtual-text',
	},

	config = function()
		require('go').setup({
			goimport = 'goimports',
			test_runner = 'richgo',
			icons = {
				breakpoint = 'ⓑ',
				current_pos = '➤',
			},
		})

		vim.api.nvim_create_autocmd('BufWritePre', {
			pattern = '*.go',
			callback = function() require('go.format').goimport() end,
		})
	end
}
