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

-- Special tabbing for Terraform files
vim.opt.filetype = 'on'
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'terraform',
    command = [[ setlocal tabstop=2 softtabstop=0 shiftwidth=2 expandtab ]]
})
