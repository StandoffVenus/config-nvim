require("mule.remaps")
require("mule.packer")

-- Always enable line numbers
vim.cmd('set number')

-- Format before saving Lua and Go files
vim.cmd('autocmd BufWritePre *.go,*.lua lua vim.lsp.buf.formatting_sync()')
