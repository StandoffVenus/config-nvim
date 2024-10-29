local go_format_group = vim.api.nvim_create_augroup("GoFormat", {})

return {
	'ray-x/go.nvim',

	dependencies = {
		'ray-x/guihua.lua',
		'mfussenegger/nvim-dap',
		'rcarriga/nvim-dap-ui',
		'theHamsta/nvim-dap-virtual-text',
	},

	ft = { "go", "gomod" },

	config = function()
		require('go').setup()

		vim.api.nvim_create_autocmd('BufWritePre', {
			pattern  = '*.go',
			group    = go_format_group,
			callback = function() require('go.format').goimport() end,
		})
	end,
}
