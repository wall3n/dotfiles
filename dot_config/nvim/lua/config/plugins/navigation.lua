return {
    -- ============================================================
    -- TELESCOPE: Fuzzy finder principal
    -- ============================================================
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            "nvim-telescope/telescope-ui-select.nvim",
        },
        cmd = "Telescope",
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<CR>",                desc = "Buscar archivos" },
            { "<leader>fg", "<cmd>Telescope live_grep<CR>",                 desc = "Buscar en contenido (grep)" },
            { "<leader>fb", "<cmd>Telescope buffers<CR>",                   desc = "Buscar buffers abiertos" },
            { "<leader>fh", "<cmd>Telescope help_tags<CR>",                 desc = "Buscar help" },
            { "<leader>fr", "<cmd>Telescope oldfiles<CR>",                  desc = "Archivos recientes" },
            { "<leader>fw", "<cmd>Telescope grep_string<CR>",               desc = "Buscar palabra bajo cursor" },
            { "<leader>fd", "<cmd>Telescope diagnostics<CR>",               desc = "Diagnósticos LSP" },
            { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>",      desc = "Símbolos del documento" },
            { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<CR>",     desc = "Símbolos del workspace" },
            { "<leader>fc", "<cmd>Telescope git_commits<CR>",               desc = "Commits Git" },
            { "<leader>fC", "<cmd>Telescope git_bcommits<CR>",              desc = "Commits del buffer" },
            -- Búsqueda de clases Java (muy útil en proyectos enterprise)
            { "<leader>fj", function()
                require("telescope.builtin").find_files({
                    prompt_title = "Clases Java",
                    find_command = { "fd", "--type", "f", "--extension", "java" },
                })
            end, desc = "Buscar archivos Java" },
        },
        config = function()
            local telescope = require("telescope")
            local actions = require("telescope.actions")

            telescope.setup({
                defaults = {
                    prompt_prefix = "  ",
                    selection_caret = " ",
                    path_display = { "smart" },
                    file_ignore_patterns = {
                        "node_modules", "%.git/", "target/", ".class",
                        "%.jar", "%.war", "%.ear",
                    },
                    mappings = {
                        i = {
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                            ["<C-s>"] = actions.select_horizontal,
                            ["<C-v>"] = actions.select_vertical,
                            ["<Esc>"] = actions.close,
                        },
                    },
                    layout_config = {
                        horizontal = { preview_width = 0.55 },
                        width = 0.87,
                        height = 0.80,
                    },
                },
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                    },
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown(),
                    },
                },
            })

            telescope.load_extension("fzf")
            telescope.load_extension("ui-select")
        end,
    },

    -- ============================================================
    -- HARPOON 2: Navegación ultrarrápida entre archivos frecuentes
    -- Esencial para Java: alternar entre Service, Controller, Repository
    -- ============================================================
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local harpoon = require("harpoon")
            harpoon:setup({
                settings = {
                    save_on_toggle = true,
                    sync_on_ui_close = true,
                },
            })

            -- Keymaps de Harpoon
            local map = vim.keymap.set

            map("n", "<leader>ha", function() harpoon:list():add() end,
                { desc = "Harpoon: añadir archivo" })
            map("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
                { desc = "Harpoon: menú" })

            -- Navegación rápida 1-4 (los 4 archivos más usados)
            map("n", "<leader>1", function() harpoon:list():select(1) end,
                { desc = "Harpoon: ir a archivo 1" })
            map("n", "<leader>2", function() harpoon:list():select(2) end,
                { desc = "Harpoon: ir a archivo 2" })
            map("n", "<leader>3", function() harpoon:list():select(3) end,
                { desc = "Harpoon: ir a archivo 3" })
            map("n", "<leader>4", function() harpoon:list():select(4) end,
                { desc = "Harpoon: ir a archivo 4" })

            -- Ciclar por la lista de harpoon
            map("n", "<leader>hp", function() harpoon:list():prev() end,
                { desc = "Harpoon: anterior" })
            map("n", "<leader>hn", function() harpoon:list():next() end,
                { desc = "Harpoon: siguiente" })
        end,
    },
}
