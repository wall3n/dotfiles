-- ============================================================
-- SERVIDORES LSP ACTIVOS
-- Fuente única de verdad: mason-lspconfig los instala y los activa.
-- Añadir uno aquí es lo único necesario para habilitarlo.
-- (jdtls se excluye a propósito: lo arranca nvim-jdtls.)
-- ============================================================
local SERVERS = {
  "ts_ls",    -- TypeScript / JavaScript
  "html",     -- HTML
  "cssls",    -- CSS
  "jsonls",   -- JSON
  "lua_ls",   -- Lua (config de nvim)
  "yamlls",   -- YAML
  "eslint",   -- ESLint
  "clangd",   -- C / C++ / ensamblador
  "marksman", -- Markdown
}

return {
  -- ============================================================
  -- MASON: Gestor de LSP servers, formatters, linters
  -- ============================================================
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>lm", "<cmd>Mason<CR>", desc = "Abrir Mason" } },
    build = ":MasonUpdate",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
        border = "rounded",
      },
    },
  },

  -- Bridge entre mason y lspconfig
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      -- Lista única y explícita de servidores. jdtls NO va aquí: lo gestiona
      -- nvim-jdtls con su propia invocación.
      ensure_installed = SERVERS,
      -- Desactivado a propósito: con automatic_installation, mason-lspconfig
      -- instala un servidor por cada filetype que abras, y la lista crece sola.
      automatic_installation = false,
      -- mason-lspconfig v2 llama a vim.lsp.enable() por cada paquete de Mason
      -- que tenga mapeo lspconfig. Eso activaba servidores que no usamos e
      -- incluso formateadores (stylua), generando warnings de "config not found".
      -- Con una lista explícita solo se activa lo que está en SERVERS.
      automatic_enable = SERVERS,
    },
  },

  -- ============================================================
  -- NVIM-LSPCONFIG: Configuración de los LSP
  -- ============================================================
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = { library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } } },
      },
    },
    config = function()
      -- Capacidades extendidas para autocompletado
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Función on_attach: keymaps que se activan SOLO cuando hay LSP activo
      local on_attach = function(_, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
        end

        -- Navegación de código
        map("gd", vim.lsp.buf.definition, "Ir a definición")
        map("gD", vim.lsp.buf.declaration, "Ir a declaración")
        map("gr", function() Snacks.picker.lsp_references() end, "Ver referencias")
        map("gI", vim.lsp.buf.implementation, "Ir a implementación")
        map("gt", vim.lsp.buf.type_definition, "Ir a tipo")

        -- Información
        map("K", vim.lsp.buf.hover, "Hover documentation")
        map("<leader>ls", vim.lsp.buf.signature_help, "Signature help")

        -- Acciones
        map("<leader>la", vim.lsp.buf.code_action, "Code action")
        map("<leader>lr", vim.lsp.buf.rename, "Renombrar símbolo")
        map("<leader>lf", function()
          vim.lsp.buf.format({ async = true })
        end, "Formatear archivo")

        -- Diagnósticos
        map("<leader>ld", vim.diagnostic.open_float, "Ver diagnóstico")
        map("[d", vim.diagnostic.goto_prev, "Diagnóstico anterior")
        map("]d", vim.diagnostic.goto_next, "Diagnóstico siguiente")
        map("<leader>lD", function() Snacks.picker.diagnostics_buffer() end, "Diagnósticos del buffer")

        -- Workspace (útil para Java multi-módulo)
        map("<leader>lwa", vim.lsp.buf.add_workspace_folder, "Añadir carpeta workspace")
        map("<leader>lwr", vim.lsp.buf.remove_workspace_folder, "Quitar carpeta workspace")
        map("<leader>lwl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, "Listar carpetas workspace")
      end

      -- on_attach global vía LspAttach (jdtls añade el suyo aparte)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          on_attach(client, args.buf)
        end,
      })

      -- Capacidades por defecto para todos los servidores (API nativa 0.11)
      vim.lsp.config("*", { capabilities = capabilities })

      -- Diagnósticos visual config
      vim.diagnostic.config({
        virtual_text = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN]  = "",
            [vim.diagnostic.severity.HINT]  = "󰠠",
            [vim.diagnostic.severity.INFO]  = "",
          },
        },
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      -- TypeScript / JavaScript
      vim.lsp.config("ts_ls", {
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
            },
          },
        },
      })

      -- ESLint: auto-fix al guardar
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "eslint" then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = args.buf,
              command = "EslintFixAll",
            })
          end
        end,
      })

      -- Lua (con soporte para nvim API)
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })

      -- mason-lspconfig (automatic_enable) llama a vim.lsp.enable por cada
      -- servidor instalado. html/cssls/jsonls/yamlls/eslint no necesitan
      -- config extra: heredan capabilities de "*" y on_attach del LspAttach.
    end,
  },

  -- ============================================================
  -- AUTOCOMPLETADO: blink.cmp (sustituye a nvim-cmp y sus 5 fuentes)
  -- version "1.*" descarga el binario Rust de fuzzy matching ya compilado.
  -- ============================================================
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
    },
    opts = {
      -- Mismo comportamiento que con nvim-cmp: <CR> confirma solo si hay
      -- algo seleccionado, <Tab>/<S-Tab> recorren la lista y los snippets.
      keymap = {
        preset = "enter",
        ["<C-n>"]   = { "select_next", "fallback" },
        ["<C-p>"]   = { "select_prev", "fallback" },
        ["<C-b>"]   = { "scroll_documentation_up", "fallback" },
        ["<C-f>"]   = { "scroll_documentation_down", "fallback" },
        ["<Tab>"]   = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        list = { selection = { preselect = false, auto_insert = false } },
        menu = {
          border = "rounded",
          draw = { treesitter = { "lsp" } },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = "rounded" },
        },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      snippets = { preset = "luasnip" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          buffer = { min_keyword_length = 3 },
        },
      },
      cmdline = { enabled = true },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },

  -- Formateo automático
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      { "<leader>lF", function() require("conform").format({ async = true }) end, desc = "Formatear (conform)" },
    },
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        lua = { "stylua" },
        java = { "google-java-format" },
        markdown = { "prettier" },
        sh = { "shfmt" },
        bash = { "shfmt" },
      },
      format_on_save = {
        timeout_ms = 2000,
        lsp_format = "fallback",
      },
    },
  },
}
