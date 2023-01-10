require("mule.remaps")
require("mule.packer")

-- Always open splits to the right
vim.cmd('set splitright')

-- Always enable line numbers
vim.cmd('set number')

local function vim_cmd(...)
	local args = { ... }

	return vim.cmd(table.concat(args, ' '))
end

local function vim_autocmd(on_cmd, group, do_cmd)
	return vim_cmd('autocmd', on_cmd, group, do_cmd)
end

-- Format before saving Lua and Go files
vim_autocmd('BufWritePre', '*.go,*.lua', 'lua vim.lsp.buf.formatting_sync()')
