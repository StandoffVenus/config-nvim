return {
	'hrsh7th/nvim-cmp',

	dependencies = {
		'f3fora/cmp-spell',
		'hrsh7th/cmp-nvim-lsp',
		'saadparwaiz1/cmp_luasnip',
		'L3MON4D3/LuaSnip',
	},

	config = function()
		local cmp = require('cmp')
		local luasnip = require('luasnip')

		local cmp_behavior = { behavior = cmp.SelectBehavior.Select }
		local mappings = cmp.mapping.preset.insert({
			['<C-j>'] = cmp.mapping.select_next_item(cmp_behavior),
			['<C-k>'] = cmp.mapping.select_prev_item(cmp_behavior),
			['<C-CR>'] = cmp.mapping.confirm({ select = false }),
			['<CR>'] = cmp.mapping(function(fb) fb() end),
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
	end
}
