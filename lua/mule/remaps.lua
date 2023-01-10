vim.g.mapleader = " "

vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

-- Keep cursor centered when scrolling
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
-- Open terminal in vertical split
vim.keymap.set('n', '<leader>sh', function()
	vim.cmd('set splitright')
	vim.cmd('vs +te')
end)
