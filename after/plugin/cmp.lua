local cmp = require('cmp')
local luasnip = require('luasnip')

local cmp_behavior = { behavior = cmp.SelectBehavior.Select }
local mappings = cmp.mapping.preset.insert({
	['<C-j>'] = cmp.mapping.select_next_item(cmp_behavior),
	['<C-k>'] = cmp.mapping.select_prev_item(cmp_behavior),
	['<C-CR>'] = cmp.mapping.confirm({ select = false }),
	['<CR>'] = cmp.mapping(function(fb) fb() end), -- If enter is pressed, always insert, don't accept completion
})

local sources = {
	{ name = 'nvim_lsp' },
	{ name = 'luasnip' },
}

cmp.setup({
	mapping = mappings,
	sources = sources,
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	}
})
