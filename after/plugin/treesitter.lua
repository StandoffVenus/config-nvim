require('nvim-treesitter.configs').setup {
    ensure_installed = {
        'lua',
        'go',
        'make',
    },

    sync_install = false,
    auto_install = true,

    highlight = {
        enable = true,
    },
}
