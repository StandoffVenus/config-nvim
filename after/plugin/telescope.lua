local builtin = require('telescope.builtin')
local themes = require('telescope.themes')

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})

vim.keymap.set('n', '<leader>fs', function()
	builtin.grep_string({ search = vim.fn.input("> ") })
end)

vim.keymap.set('n', '<leader>sc', function()
	builtin.spell_suggest(themes.get_cursor({}))
end)
