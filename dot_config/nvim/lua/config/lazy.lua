-- Bootstrap: descarga lazy.nvim si no existe
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Cargar plugins desde la carpeta plugins/
require("lazy").setup("config.plugins", {
    change_detection = {
        notify = false,
    },
    -- Ningún plugin de esta config necesita luarocks. Sin esto, lazy intenta
    -- montar hererocks + lua 5.1 en cada :checkhealth y falla con un ERROR.
    rocks = {
        enabled = false,
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})
