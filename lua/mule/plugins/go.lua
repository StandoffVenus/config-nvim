return {
	'ray-x/go.nvim',

	-- The author accepted a stupid PR where "if err != nil" becomes unhighlighted.
	-- Not only do I find this annoyingly unhelpful (my err checks now look like comments, awesome!)
	-- it doesn't always work correctly, leading to inconsistent highlighting. This is the last version
	-- before that change.
	commit = 'a3455f4',

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
