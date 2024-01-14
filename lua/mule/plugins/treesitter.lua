return {
	'nvim-treesitter/nvim-treesitter',

	config = function()
		require('nvim-treesitter.install').update({ with_sync = true })()
		require('nvim-treesitter.configs').setup {
			ensure_installed = { 'lua', 'go', 'make' },
			sync_install     = false,
			auto_install     = true,
			highlight        = { enable = true },
		}
	end
}
