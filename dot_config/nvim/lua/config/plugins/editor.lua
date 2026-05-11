return {
  -- ============================================================
  -- UNDOTREE: Historial de cambios visual (imprescindible)
  -- ============================================================
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = {
      { "<leader>uu", "<cmd>UndotreeToggle<CR>", desc = "Toggle Undotree" },
    },
    config = function()
      vim.g.undotree_WindowLayout = 2
      vim.g.undotree_ShortIndicators = 1
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },

  -- ============================================================
  -- TODO-COMMENTS: Gestor de TODO/FIXME/HACK/NOTE en el código
  -- ============================================================
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<CR>",                            desc = "Buscar TODOs" },
      { "<leader>fT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<CR>",    desc = "Buscar TODO/FIX" },
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Siguiente TODO" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "TODO anterior" },
    },
    opts = {
      signs = true,
      sign_priority = 8,
      keywords = {
        FIX  = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
    },
  },

  -- ============================================================
  -- AUTOPAIRS: Cierre automático de paréntesis, llaves, etc.
  -- ============================================================
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true, -- Usa treesitter para contexto
      ts_config = {
        lua = { "string" },
        java = { "string" },
      },
    },
    config = function(_, opts)
      local autopairs = require("nvim-autopairs")
      autopairs.setup(opts)
      -- Integración con nvim-cmp
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- ============================================================
  -- SURROUND: Rodear texto con comillas, etiquetas, etc.
  -- ============================================================
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    version = "*",
    opts = {},
    -- Uso: ys{motion}{char}, cs{old}{new}, ds{char}
    -- Ejemplo: ysiw" -> rodear palabra con comillas
    -- cs"' -> cambiar " por '
  },

  -- ============================================================
  -- COMMENT: Comentar/descomentar rápido
  -- ============================================================
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    -- gcc -> comentar línea
    -- gc{motion} -> comentar movimiento
    -- gb -> comentar bloque
  },

  -- ============================================================
  -- TROUBLE: Lista de diagnósticos, referencias, quickfix mejorada
  -- ============================================================
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "Trouble" },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>",                   desc = "Trouble toggle" },
      { "<leader>xw", "<cmd>Trouble diagnostics toggle<CR>",                   desc = "Trouble workspace" },
      { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",      desc = "Trouble documento" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<CR>",                        desc = "Trouble quickfix" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<CR>",                       desc = "Trouble loclist" },
      { "gR",         "<cmd>Trouble lsp_references toggle<CR>",                desc = "Trouble referencias" },
    },
    opts = {},
  },

  -- ============================================================
  -- SPECTRE: Búsqueda y reemplazo global en el proyecto
  -- (Muy útil para refactoring en proyectos enterprise)
  -- ============================================================
  {
    "nvim-pack/nvim-spectre",
    build = false,
    cmd = "Spectre",
    keys = {
      { "<leader>sr", function() require("spectre").open() end,                              desc = "Spectre: buscar/reemplazar" },
      { "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, desc = "Spectre: buscar palabra" },
      { "<leader>sf", function() require("spectre").open_file_search() end,                  desc = "Spectre: buscar en archivo" },
    },
    opts = { open_cmd = "noswapfile vnew" },
  },

  -- ============================================================
  -- LEAP: Navegación super rápida por el texto (reemplaza easymotion)
  -- ============================================================
  {
    url = "https://codeberg.org/andyg/leap.nvim",
    event = "VeryLazy",
    config = function()
      -- Nueva API de mappings (no deprecated)
      vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)")
      vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)")
      vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-from-window)")
    end,
  },
  -- ============================================================
  -- STAY-IN-PLACE: Mantener posición al indentar
  -- ============================================================
  {
    "gbprod/stay-in-place.nvim",
    event = "VeryLazy",
    opts = {},
  },
}
