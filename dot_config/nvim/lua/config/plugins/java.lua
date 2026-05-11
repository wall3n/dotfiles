-- Este archivo tiene doble función:
-- 1. Declarar el plugin nvim-jdtls para lazy.nvim (return al final)
-- 2. Exportar la función setup() que llama autocmds.lua

local M = {}

M.setup = function()
    local jdtls = require("jdtls")
    local jdtls_setup = require("jdtls.setup")

    -- Ruta donde Mason instala jdtls
    local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
    local jdtls_path = mason_packages .. "/jdtls"

    -- Plataforma del sistema operativo
    local os_config = "linux"
    if vim.fn.has("mac") == 1 then
        os_config = "mac"
    elseif vim.fn.has("win32") == 1 then
        os_config = "win"
    end

    -- Carpeta de datos por proyecto (evita conflictos entre proyectos)
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

    -- Ruta al launcher de jdtls
    local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

    -- Configuración del servidor
    local config = {
        cmd = {
            "java",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-Xmx2g",  -- Memoria para proyectos enterprise (ajustar según RAM)
            "--add-modules=ALL-SYSTEM",
            "--add-opens", "java.base/java.util=ALL-UNNAMED",
            "--add-opens", "java.base/java.lang=ALL-UNNAMED",
            "-jar", launcher,
            "-configuration", jdtls_path .. "/config_" .. os_config,
            "-data", workspace_dir,
        },

        -- Directorio raíz del proyecto
        root_dir = jdtls_setup.find_root({
            "pom.xml", "build.gradle", "build.gradle.kts",
            ".git", "mvnw", "gradlew",
        }),

        -- Capacidades con autocompletado
        capabilities = require("cmp_nvim_lsp").default_capabilities(),

        settings = {
            java = {
                -- Compilación
                eclipse = { downloadSources = true },
                configuration = {
                    updateBuildConfiguration = "interactive",
                    runtimes = {
                        { name = "JavaSE-17", path = "/usr/lib/jvm/java-17-openjdk-amd64" },
                        { name = "JavaSE-21", path = "/usr/lib/jvm/java-21-openjdk-amd64" },
                    },
                },
                -- Maven
                maven = { downloadSources = true },
                -- Completado
                completion = {
                    favoriteStaticMembers = {
                        "org.junit.Assert.*",
                        "org.junit.jupiter.api.Assertions.*",
                        "org.mockito.Mockito.*",
                        "org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*",
                    },
                    importOrder = { "java", "javax", "com", "org" },
                },
                -- Inlay hints (parámetros de métodos visibles)
                inlayHints = {
                    parameterNames = { enabled = "all" },
                },
                -- Formateo
                format = {
                    enabled = true,
                    settings = {
                        url = "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml",
                        profile = "GoogleStyle",
                    },
                },
                -- Refactoring avanzado
                saveActions = {
                    organizeImports = true,
                },
                sources = {
                    organizeImports = {
                        starThreshold = 9999,
                        staticStarThreshold = 9999,
                    },
                },
                -- Code lens (ver implementaciones, referencias inline)
                referencesCodeLens = { enabled = true },
                implementationsCodeLens = { enabled = true },
                signatureHelp = { enabled = true },
            },
        },

        -- Bundles adicionales (debugger DAP)
        init_options = {
            bundles = {},
        },

        on_attach = function(client, bufnr)
            -- Keymaps específicos de Java
            local map = function(keys, func, desc)
                vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "Java: " .. desc })
            end

            -- LSP base
            map("gd", vim.lsp.buf.definition, "Ir a definición")
            map("gD", vim.lsp.buf.declaration, "Declaración")
            map("gr", require("telescope.builtin").lsp_references, "Referencias")
            map("gI", vim.lsp.buf.implementation, "Implementación")
            map("K", vim.lsp.buf.hover, "Hover docs")
            map("<leader>la", vim.lsp.buf.code_action, "Code action")
            map("<leader>lr", vim.lsp.buf.rename, "Renombrar")
            map("<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Formatear")
            map("[d", vim.diagnostic.goto_prev, "Diagnóstico anterior")
            map("]d", vim.diagnostic.goto_next, "Diagnóstico siguiente")

            -- Acciones específicas de Java con jdtls
            map("<leader>jo", jdtls.organize_imports, "Organizar imports")
            map("<leader>jv", jdtls.extract_variable, "Extraer variable")
            map("<leader>jc", jdtls.extract_constant, "Extraer constante")
            map("<leader>jt", jdtls.test_nearest_method, "Ejecutar test método")
            map("<leader>jT", jdtls.test_class, "Ejecutar tests de clase")
            map("<leader>ju", "<cmd>JdtUpdateConfig<CR>", "Actualizar config jdtls")
            map("<leader>jb", "<cmd>JdtBytecode<CR>", "Ver bytecode")

            -- Extraer método en visual mode
            vim.keymap.set("v", "<leader>jm", function()
                jdtls.extract_method(true)
            end, { buffer = bufnr, desc = "Java: Extraer método" })

            -- Code lens
            jdtls.setup_dap({ hotcodereplace = "auto" })
            require("jdtls.setup").add_commands()
            vim.lsp.codelens.refresh()
        end,
    }

    jdtls.start_or_attach(config)
end

-- Declaración del plugin para lazy.nvim
return {
    {
        "mfussenegger/nvim-jdtls",
        ft = "java",  -- Solo se carga para archivos Java
    },
    -- DAP para debugging Java
    {
        "mfussenegger/nvim-dap",
        optional = true,
        keys = {
            { "<leader>db", "<cmd>DapToggleBreakpoint<CR>", desc = "Toggle breakpoint" },
            { "<leader>dc", "<cmd>DapContinue<CR>",         desc = "Debug continuar" },
            { "<leader>ds", "<cmd>DapStepOver<CR>",         desc = "Debug step over" },
            { "<leader>di", "<cmd>DapStepInto<CR>",         desc = "Debug step into" },
            { "<leader>do", "<cmd>DapStepOut<CR>",          desc = "Debug step out" },
            { "<leader>dq", "<cmd>DapTerminate<CR>",        desc = "Debug terminar" },
        },
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        keys = {
            { "<leader>du", function() require("dapui").toggle() end, desc = "Debug UI toggle" },
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            dapui.setup()
            dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
            dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
        end,
    },
}
