local Window = require('mule.window')

vim.g.mapleader = " "

-- Keep cursor centered when it jumps, such as ctrl+d or previous/next match
vim.api.nvim_create_autocmd(
	"CursorMoved",
	{
		command = [[ :exec "norm zz" ]],
	})

-- Open floating terminal
local win_term = Window:new()
vim.keymap.set('n', '<leader>sh', function()
	win_term:open({
		relative = 'editor',
		style = 'minimal',
		border = 'shadow',
	})

	if vim.bo[win_term:bufnr()].buftype ~= 'terminal' then
		vim.cmd.terminal()
	end
end)

--- Open a read-only, temporary terminal in a split and
--- feed it a user-supplied command.
---
--- @param args vim.api.keyset.create_user_command.command_args
local function cmd_term_split(args)
	--- @type vim.api.keyset.win_config
	local opts = {
		split = 'right',
		height = vim.o.lines,
		width = math.floor(vim.o.columns * .35),
	}

	local win = Window:new()
	win:open(opts)
	vim.fn.jobstart(args.args, { term = true })
end

vim.api.nvim_create_user_command('TermSplit', cmd_term_split, { nargs = '+' })

vim.keymap.set(
	'v',
	'<leader>yy',
	'"+y',
	{ remap = true })
