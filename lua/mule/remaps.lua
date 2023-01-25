vim.g.mapleader = " "

vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

-- Keep cursor centered when it jumps, such as ctrl+d or previous/next match
vim.api.nvim_create_autocmd(
	"CursorMoved",
	{
		command = [[ :exec "norm zz" ]],
	})

-- Open terminal in current window
vim.keymap.set('n', '<leader>sh', function()
	vim.cmd('te')
end)
