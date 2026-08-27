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
      -- NOTA: jdtls NO va aquí, se gestiona con nvim-jdtls
      ensure_installed = {
        "ts_ls",  -- TypeScript/JavaScript
        "html",   -- HTML
        "cssls",  -- CSS
        "jsonls", -- JSON
        "lua_ls", -- Lua
        "yamlls", -- YAML
        "eslint", -- ESLint
      },
      automatic_installation = true,
      -- mason-lspconfig v2 auto-activa (vim.lsp.enable) TODOS los servidores de
      -- Mason. jdtls debe quedar excluido: lo gestiona nvim-jdtls con una
      -- invocación propia. Si no, arrancan dos instancias de jdtls que chocan
      -- en el workspace y la segunda muere con "exit code 13".
      automatic_enable = {
        exclude = { "jdtls" },
      },
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
      "hrsh7th/cmp-nvim-lsp",
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = { library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } } },
      },
    },
    config = function()
      -- Capacidades extendidas para autocompletado
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Función on_attach: keymaps que se activan SOLO cuando hay LSP activo
      local on_attach = function(_, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
        end

        -- Navegación de código
        map("gd", vim.lsp.buf.definition, "Ir a definición")
        map("gD", vim.lsp.buf.declaration, "Ir a declaración")
        map("gr", require("telescope.builtin").lsp_references, "Ver referencias")
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
        map("<leader>lD", "<cmd>Telescope diagnostics bufnr=0<CR>", "Diagnósticos del buffer")

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
  -- AUTOCOMPLETADO: nvim-cmp
  -- ============================================================
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"]     = cmp.mapping.select_next_item(),
          ["<C-p>"]     = cmp.mapping.select_prev_item(),
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer", keyword_length = 3 },
        }),
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
          { { name = "path" } },
          { { name = "cmdline" } }
        ),
        matching = { disallow_symbol_nonprefix_matching = false },
      })
    end,
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
      },
      format_on_save = {
        timeout_ms = 2000,
        lsp_format = "fallback",
      },
    },
  },
}
