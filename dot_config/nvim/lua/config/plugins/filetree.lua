return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        cmd = "Neotree",
        keys = {
            { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Árbol de archivos" },
            { "<leader>o", "<cmd>Neotree focus<CR>", desc = "Focus árbol de archivos" },
            { "<leader>ge", "<cmd>Neotree git_status<CR>", desc = "Git status en árbol" },
        },
        config = function()
            require("neo-tree").setup({
                close_if_last_window = true,
                window = {
                    width = 35,
                    mappings = {
                        ["<space>"] = "none",
                        ["o"] = "open",
                        ["a"] = "add",
                        ["d"] = "delete",
                        ["r"] = "rename",
                        ["c"] = "copy",
                        ["m"] = "move",
                        ["Y"] = function(state)
                            local node = state.tree:get_node()
                            local path = node:get_id()
                            vim.fn.setreg("+", path, "c")
                            vim.notify("Copiado: " .. path)
                        end,
                    },
                },
                filesystem = {
                    filtered_items = {
                        visible = false,
                        hide_dotfiles = false,
                        hide_gitignored = true,
                        hide_by_name = { ".git", "node_modules", ".cache", "target" },
                    },
                    follow_current_file = {
                        enabled = true,
                        leave_dirs_open = true,
                    },
                    use_libuv_file_watcher = true,
                },
                -- MUY IMPORTANTE para Java: mostrar estructura de paquetes
                -- com.empresa.proyecto aparece como árbol anidado
                default_component_configs = {
                    icon = {
                        folder_closed = "",
                        folder_open = "",
                        folder_empty = "",
                    },
                    git_status = {
                        symbols = {
                            added     = "",
                            modified  = "",
                            deleted   = "✖",
                            renamed   = "󰁕",
                            untracked = "",
                            ignored   = "",
                            unstaged  = "󰄱",
                            staged    = "",
                            conflict  = "",
                        },
                    },
                },
            })
        end,
    },
}
