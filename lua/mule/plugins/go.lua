return {
	'ray-x/go.nvim',

	dependencies = {
		'ray-x/guihua.lua',
	},

	ft = { "go", "gomod" },

	config = function()
		require('go').setup()

		local go_format_group = vim.api.nvim_create_augroup("GoFormat", {})
		vim.api.nvim_create_autocmd('BufWritePre', {
			pattern  = '*.go',
			group    = go_format_group,
			callback = function() require('go.format').goimport() end,
		})
	end,
}
