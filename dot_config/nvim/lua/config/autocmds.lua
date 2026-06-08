local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ============================================================
-- INDENTACIÓN POR TIPO DE ARCHIVO
-- ============================================================
local indentGroup = augroup("IndentSettings", { clear = true })

autocmd("FileType", {
    group = indentGroup,
    pattern = { "javascript", "typescript", "typescriptreact", "javascriptreact", "json", "html", "css", "scss", "yaml", "lua" },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
})

autocmd("FileType", {
    group = indentGroup,
    pattern = { "java", "xml" },
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.softtabstop = 4
        vim.opt_local.shiftwidth = 4
    end,
})

-- ============================================================
-- RESALTAR AL COPIAR
-- ============================================================
local yankGroup = augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
    group = yankGroup,
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
    end,
})

-- ============================================================
-- ELIMINAR ESPACIOS EN BLANCO AL GUARDAR
-- ============================================================
local trimGroup = augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
    group = trimGroup,
    pattern = { "*.java", "*.ts", "*.js", "*.lua", "*.tsx", "*.jsx" },
    callback = function()
        local save = vim.fn.winsaveview()
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.winrestview(save)
    end,
})

-- NOTA: El arranque de jdtls para archivos Java se registra dentro de
-- lua/config/plugins/java.lua (donde M.setup está en alcance). Antes se
-- intentaba aquí con require("config.plugins.java").setup(), pero ese módulo
-- devuelve la spec de plugins (no M), así que la llamada fallaba siempre.

-- ============================================================
-- CERRAR VENTANAS AUXILIARES CON 'q'
-- ============================================================
local closeGroup = augroup("CloseWithQ", { clear = true })
autocmd("FileType", {
    group = closeGroup,
    pattern = { "help", "qf", "lspinfo", "man", "checkhealth", "fugitive" },
    callback = function()
        vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, silent = true })
    end,
})
