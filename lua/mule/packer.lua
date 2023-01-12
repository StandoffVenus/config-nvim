vim.cmd('packadd packer.nvim')

local __print = print
local debug = false

local function get_plugin_name(p)
	if type(p) == 'string' then
		return p
	end

	if type(p) == 'table' then
		return p[1]
	end

	return tostring(p)
end

local plugins = {
	'wbthomason/packer.nvim', -- Packer can manage itself
	'preservim/nerdtree',
	'tpope/vim-fugitive',
	'ray-x/go.nvim',
	'ray-x/guihua.lua',
	'williamboman/mason.nvim',
	'williamboman/mason-lspconfig.nvim',
	'neovim/nvim-lspconfig',
	'hrsh7th/nvim-cmp',
	'hrsh7th/cmp-nvim-lsp',
	'saadparwaiz1/cmp_luasnip',
	'L3MON4D3/LuaSnip',
	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.0',
		requires = { { 'nvim-lua/plenary.nvim' } }
	},
	{
		'nvim-treesitter/nvim-treesitter',
		run = function()
			require('nvim-treesitter.install').update({ with_sync = true })()
		end
	},
	{
		'rose-pine/neovim',
		as = 'rose-pine',
		config = function()
			vim.cmd('colorscheme rose-pine')
		end
	},
}

local function print(s)
	if debug then __print(s) end
end

return require('packer').startup(function(use)
	print('plugins: {')
	for _, p in pairs(plugins) do
		use(p)
		print('  ' .. get_plugin_name(p) .. ',')
	end

	print('}')
end)
