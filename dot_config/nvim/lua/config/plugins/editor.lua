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
      { "<leader>ft", function() Snacks.picker.todo_comments() end,                                   desc = "Buscar TODOs" },
      { "<leader>fT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Buscar TODO/FIX" },
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
    -- blink.cmp añade los paréntesis al confirmar una función (auto_brackets),
    -- así que ya no hace falta la integración que tenía con nvim-cmp.
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

  -- COMMENT: nativo desde nvim 0.10 (gcc línea, gc{motion}). Sin plugin.

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
  -- GRUG-FAR: Búsqueda y reemplazo global en el proyecto
  -- (Muy útil para refactoring en proyectos enterprise)
  -- ============================================================
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      { "<leader>sr", function() require("grug-far").open() end,                        desc = "Buscar/reemplazar en proyecto" },
      { "<leader>sw", function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } }) end, mode = { "n", "x" }, desc = "Buscar/reemplazar palabra" },
      { "<leader>sf", function() require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } }) end,        desc = "Buscar/reemplazar en archivo" },
    },
    opts = { headerMaxWidth = 80 },
  },

  -- ============================================================
  -- FLASH: Salto rápido por el texto (sustituye a leap)
  -- Mejora sobre leap: etiqueta también f/t/F/T y las búsquedas con /
  -- ============================================================
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        char = { jump_labels = true },
      },
    },
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash: saltar" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash: seleccionar nodo treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Flash: operador remoto" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end,  desc = "Flash: buscar treesitter" },
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Flash: alternar en búsqueda" },
    },
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
