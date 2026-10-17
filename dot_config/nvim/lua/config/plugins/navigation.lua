return {
    -- El buscador (antes Telescope) es snacks.picker: ver plugins/ui.lua

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
