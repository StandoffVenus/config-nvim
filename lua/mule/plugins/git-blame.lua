return {
	"FabijanZulj/blame.nvim",
	config = function()
		require('blame').setup {}
		vim.keymap.set('n', '<leader>gb', vim.cmd.BlameToggle)
	end,
}
