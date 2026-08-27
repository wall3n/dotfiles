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

    -- Plataforma: jdtls trae una carpeta de configuración OSGi por SO **y por
    -- arquitectura** (config_mac vs config_mac_arm, config_linux vs
    -- config_linux_arm). Usar la de x86_64 en un Mac ARM arranca la JVM pero
    -- luego falla al activar bundles (m2e, NoClassDefFoundError) y jdtls muere
    -- con "exit code 13". Hay que elegir la variante correcta.
    local os_config
    if vim.fn.has("mac") == 1 then
        os_config = "mac"
    elseif vim.fn.has("win32") == 1 then
        os_config = "win"
    else
        os_config = "linux"
    end

    local arch = vim.uv.os_uname().machine
    if os_config ~= "win" and (arch == "arm64" or arch == "aarch64") then
        os_config = os_config .. "_arm"
    end

    -- Si la carpeta calculada no existe (versiones antiguas de jdtls solo traían
    -- config_mac / config_linux), cae a la variante sin sufijo.
    if vim.fn.isdirectory(jdtls_path .. "/config_" .. os_config) == 0 then
        os_config = os_config:gsub("_arm$", "")
    end

    -- Carpeta de datos por proyecto (evita conflictos entre proyectos).
    -- getcwd() no lleva barra final, así que ":t" da el nombre del propio
    -- directorio del proyecto. (Antes ":p:h:t" devolvía el directorio PADRE,
    -- haciendo que todos los proyectos de una misma carpeta compartieran workspace.)
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

    -- Ruta al launcher de jdtls
    local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

    -- Detección dinámica de JDKs instalados (cross-platform).
    -- Evita rutas hardcodeadas que rompen entre macOS y Linux.
    local function detect_runtimes()
        local runtimes = {}
        local roots
        if vim.fn.has("mac") == 1 then
            roots = vim.fn.glob("/Library/Java/JavaVirtualMachines/*/Contents/Home", true, true)
        else
            roots = vim.fn.glob("/usr/lib/jvm/*", true, true)
        end
        -- JAVA_HOME tiene prioridad si está definido
        local java_home = os.getenv("JAVA_HOME")
        if java_home and vim.fn.isdirectory(java_home) == 1 then
            table.insert(roots, 1, java_home)
        end
        for _, path in ipairs(roots) do
            if vim.fn.isdirectory(path .. "/bin") == 1 then
                -- jdtls exige nombres tipo "JavaSE-21"; intentamos extraer la versión mayor
                local release = vim.fn.glob(path .. "/release")
                local major
                if release ~= "" then
                    for line in io.lines(release) do
                        local v = line:match('JAVA_VERSION="(%d+)')
                        if v then major = tonumber(v) end
                    end
                end
                local name = major and ("JavaSE-" .. major) or nil
                if name then
                    table.insert(runtimes, { name = name, path = path })
                end
            end
        end
        return runtimes
    end

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
                    -- Runtimes detectados en tiempo de ejecución (ver detect_runtimes arriba)
                    runtimes = detect_runtimes(),
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

        -- Bundles del debugger (java-debug-adapter) y tests (java-test),
        -- instalados vía Mason. Necesarios para DAP y ejecución de tests.
        init_options = {
            bundles = (function()
                local bundles = {}
                vim.list_extend(bundles, vim.split(vim.fn.glob(
                    mason_packages .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", true), "\n"))
                vim.list_extend(bundles, vim.split(vim.fn.glob(
                    mason_packages .. "/java-test/extension/server/*.jar", true), "\n"))
                -- Excluye los jars que NO son bundles OSGi (rompen jdtls al arrancar):
                -- el runner empaquetado y el agente de cobertura jacoco.
                return vim.tbl_filter(function(j)
                    return j ~= ""
                        and not j:match("runner%-jar%-with%-dependencies")
                        and not j:match("jacocoagent")
                end, bundles)
            end)(),
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

-- Arranca jdtls en cada buffer Java.
-- NOTA: este archivo se 'require'-a por lazy y DEVUELVE la spec de plugins,
-- por lo que `require(...).setup()` desde fuera no funciona (M no se retorna).
-- Registramos el autocmd aquí, donde M.setup sí está en alcance.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("JavaJdtls", { clear = true }),
    pattern = "java",
    callback = function()
        M.setup()
    end,
})

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
