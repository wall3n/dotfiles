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
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
-- Borde redondeado para todas las ventanas flotantes (hover, diagnósticos,
-- signature help, plugins que no fijan el suyo). nvim >= 0.11
opt.winborder = "rounded"

-- Splits: apertura natural
opt.splitbelow = true
opt.splitright = true

-- Archivos
opt.swapfile = false
opt.backup = false
opt.undodir = vim.fn.stdpath("state") .. "/undodir"
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

-- Netrw desactivado (oil.nvim es el explorador)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Asegurar que el directorio de undo existe (mkdir nativo: sin fork de shell
-- en cada arranque, y funciona igual en macOS y en Linux)
vim.fn.mkdir(vim.fn.stdpath("state") .. "/undodir", "p")

-- El log de LSP crecía sin límite (llegó a 371 MB con jdtls). OFF en uso normal;
-- súbelo a "warn"/"debug" a mano cuando haga falta depurar un servidor.
-- nvim 0.12 movió la API: vim.lsp.set_log_level -> vim.lsp.log.set_level.
if vim.lsp.log and vim.lsp.log.set_level then
    vim.lsp.log.set_level("OFF")
else
    vim.lsp.set_log_level("OFF")
end

-- Proveedores de lenguaje que no usamos. Sin esto :checkhealth avisa por cada
-- uno (perl, ruby, python-host, node-host) y nvim los busca en cada arranque.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
