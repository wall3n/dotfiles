return {
    -- ============================================================
    -- VIM-FUGITIVE: Git integrado en nvim (el clásico imprescindible)
    -- ============================================================
    {
        "tpope/vim-fugitive",
        cmd = { "Git", "Gstatus", "Gblame", "Gpush", "Gpull" },
        keys = {
            { "<leader>gs", "<cmd>Git<CR>",                        desc = "Git status (fugitive)" },
            { "<leader>gc", "<cmd>Git commit<CR>",                 desc = "Git commit" },
            { "<leader>gp", "<cmd>Git push<CR>",                   desc = "Git push" },
            { "<leader>gP", "<cmd>Git pull<CR>",                   desc = "Git pull" },
            { "<leader>gb", "<cmd>Git blame<CR>",                  desc = "Git blame" },
            { "<leader>gd", "<cmd>Gvdiffsplit<CR>",                desc = "Git diff (split)" },
            { "<leader>gl", "<cmd>Git log --oneline<CR>",          desc = "Git log" },
            { "<leader>gL", "<cmd>Git log --oneline --all<CR>",    desc = "Git log todos" },
            { "<leader>gr", "<cmd>Git rebase -i HEAD~5<CR>",       desc = "Git rebase interactivo" },
        },
    },

    -- ============================================================
    -- GITSIGNS: Indicadores de cambios en el gutter + blame inline
    -- ============================================================
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            signs = {
                add          = { text = "▎" },
                change       = { text = "▎" },
                delete       = { text = "" },
                topdelete    = { text = "" },
                changedelete = { text = "▎" },
                untracked    = { text = "▎" },
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local map = function(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
                end

                -- Navegar entre hunks
                map("n", "]h", gs.next_hunk, "Siguiente hunk git")
                map("n", "[h", gs.prev_hunk, "Hunk anterior git")

                -- Acciones sobre hunks
                map("n", "<leader>ghs", gs.stage_hunk, "Stage hunk")
                map("n", "<leader>ghr", gs.reset_hunk, "Reset hunk")
                map("v", "<leader>ghs", function()
                    gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, "Stage hunk selección")
                map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer completo")
                map("n", "<leader>ghu", gs.undo_stage_hunk, "Deshacer stage hunk")
                map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer completo")
                map("n", "<leader>ghp", gs.preview_hunk, "Preview hunk")
                map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame línea")
                map("n", "<leader>ghB", gs.toggle_current_line_blame, "Toggle blame inline")
                map("n", "<leader>ghd", gs.diffthis, "Diff this")
            end,
        },
    },
}
