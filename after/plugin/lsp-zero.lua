local lsp = require('lsp-zero')
local cmp = require('cmp')

local cmp_behavior = { behavior = cmp.SelectBehavior.Insert }
local cmp_mappings = lsp.defaults.cmp_mappings({
	['j'] = cmp.mapping.select_next_item(cmp_behavior),
	['k'] = cmp.mapping.select_prev_item(cmp_behavior),
})

lsp.preset('recommended')

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

lsp.setup_nvim_cmp({ mapping = cmp_mappings })

lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>ga", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>K", vim.diagnostic.open_float, opts)
end)

lsp.setup()

vim.diagnostic.config({
	virtual_test = true,
	update_in_insert = true,
	float = true,
})
