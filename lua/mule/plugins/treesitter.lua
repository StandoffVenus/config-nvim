return {
	'nvim-treesitter/nvim-treesitter',

	config = function()
		require('nvim-treesitter.install').update({ with_sync = true })()
		require('nvim-treesitter.configs').setup {
			ensure_installed = { 'lua', 'go', 'make', 'hcl', 'terraform' },
			highlight        = { enable = true },
		}
	end
}
