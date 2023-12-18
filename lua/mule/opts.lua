local function get_env_lang()
	local env_lang = os.getenv('LANG')
	if env_lang then
		-- Some LANG values might be something like "en_us.UTF-8"
		-- We only care about the first portion, so we store the index to the first period
		local period_idx = string.find(env_lang, '%.')
		if period_idx > 0 then
			env_lang = string.sub(env_lang, 0, period_idx - 1)
		end

		env_lang = string.lower(env_lang)
	end

	return env_lang
end

vim.opt.splitright = true -- Always open splits to the right
vim.opt.number = true -- Always enable line numbers

-- Enable spell check
local lang = get_env_lang() or 'en_us'
vim.opt.spell = true
vim.opt.spelllang = { lang }

-- Special file settings
vim.opt.filetype = 'on'
local filetypes = {
	'terraform',
	'proto',
	'sql',
}

for p, ft in pairs(filetypes) do
	if type(p) == 'number' then
		p = ft
		ft = nil
	end

	local tab_stop = ft and ft.tab_stop or 2
	local soft_tab_stop = ft and ft.soft_tab_stop or 0
	local shift_width = ft and ft.shift_width or 2
	local expand_tab = ft and ft.expand_tab or true

	local command = string.format('setlocal tabstop=%d softtabstop=%d shiftwidth=%d',
		tab_stop,
		soft_tab_stop,
		shift_width)
	if expand_tab then
		command = command .. ' expandtab'
	end

	vim.api.nvim_create_autocmd('FileType', {
		pattern = p,
		command = command,
	})
end
