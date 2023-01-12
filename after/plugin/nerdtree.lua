vim.g.NERDTreeHijackNetrw = 1 -- Use NERDTree instead of netrw

vim.keymap.set('n', '<leader>tt', vim.cmd.NERDTreeFind)
vim.keymap.set('n', '<leader>tr', vim.cmd.NERDTreeRefreshRoot)
