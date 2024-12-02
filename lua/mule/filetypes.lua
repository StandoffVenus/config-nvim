vim.opt.filetype = 'on'

local terraform = 'terraform,terraform-vars,hcl'

local filetypes = {
	[terraform] = {},
	sql         = {},
	proto       = {},
	json        = {},
}

for pattern, opts in pairs(filetypes) do
	local defaults = {
		tabstop     = 2,
		softtabstop = 0,
		shiftwidth  = 2,
	}

	local merged_opts = defaults
	for idx, value in pairs(opts) do
		merged_opts[idx] = value
	end

	local command = string.format([[ setlocal tabstop=%d softtabstop=%d shiftwidth=%d expandtab ]],
		merged_opts.tabstop,
		merged_opts.softtabstop,
		merged_opts.shiftwidth)

	vim.api.nvim_create_autocmd('FileType', {
		pattern = pattern,
		command = command,
	})
end
