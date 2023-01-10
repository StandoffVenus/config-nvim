local lsp = require('lsp-zero')
local cmp = require('cmp')

lsp.preset('recommended')

local cmp_behavior = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
	['<C-j>'] = cmp.mapping.select_next_item(cmp_behavior),
	['<C-k>'] = cmp.mapping.select_prev_item(cmp_behavior),
	['<C-CR>'] = cmp.mapping.confirm({ select = false }),
	['<CR>'] = cmp.mapping(function(fb) fb() end), -- If enter is pressed, always insert, don't accept completion
})

local cmp_config = {
	mapping = cmp_mappings,
}

lsp.setup_nvim_cmp(cmp_config)

lsp.ensure_installed({
	'sumneko_lua',
	'gopls',
})

-- Fix Undefined global 'vim'
lsp.configure('sumneko_lua', {
	settings = {
		Lua = {
			diagnostics = {
				globals = { 'vim' }
			}
		}
	}
})

lsp.configure('gopls', {
	settings = {
		gopls = {
			buildFlags = { '-tags=it' }
		}
	}
})

lsp.on_attach(function(client, bufnr)
	local opts = { buffer = bufnr, remap = false }

	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<leader>ga", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "<leader>K", vim.diagnostic.open_float, opts)
end)

vim.diagnostic.config({
	virtual_test = true,
	update_in_insert = true,
	float = true,
})

lsp.setup()
