local opt = vim.opt

-- Leader key: ESPACIO (debe definirse ANTES de lazy)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Números de línea
opt.number = true
opt.relativenumber = true

-- Indentación
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- Para frontend (JS/TS usamos 2 espacios via autocmd)
-- Se configura en autocmds.lua

-- Búsqueda
opt.hlsearch = false
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Visual
opt.termguicolors = true
opt.signcolumn = "yes"
opt.colorcolumn = "120"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false

-- Splits: apertura natural
opt.splitbelow = true
opt.splitright = true

-- Archivos
opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true

-- Performance
opt.updatetime = 50
opt.timeoutlen = 300

-- Clipboard del sistema
opt.clipboard = "unnamedplus"

-- Completions
opt.completeopt = "menuone,noselect"

-- Folding con treesitter (desactivado por defecto, activar con zc/zo)
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99

-- Netrw desactivado (usamos neo-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Asegurar que el directorio de undo existe
vim.fn.system({ "mkdir", "-p", os.getenv("HOME") .. "/.vim/undodir" })
