local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})

return {
	'ray-x/go.nvim',

	dependencies = {
		'ray-x/guihua.lua',
		'mfussenegger/nvim-dap',
		'rcarriga/nvim-dap-ui',
		'theHamsta/nvim-dap-virtual-text',
	},

	config = function()
		require('go').setup()

		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern  = "*.go",
			group    = format_sync_grp,
			callback = function() require('go.format').goimport() end,
		})
	end
}
