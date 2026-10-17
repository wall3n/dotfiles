return {
  -- ============================================================
  -- COLORSCHEMA: Gruvbox Dark Hard (tema unificado del repo)
  -- ============================================================
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      contrast = "hard", -- Gruvbox Dark Hard
      transparent_mode = false,
      terminal_colors = true,
      italic = {
        strings = false,
        comments = true,
        operators = false,
        folds = true,
      },
    },
    config = function(_, opts)
      require("gruvbox").setup(opts)
      vim.o.background = "dark"
      vim.cmd.colorscheme("gruvbox")
    end,
  },

  -- ============================================================
  -- LUALINE: Statusline estilo powerline
  -- ============================================================
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      local function lsp_info()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then return "" end
        local names = {}
        for _, c in ipairs(clients) do
          table.insert(names, c.name)
        end
        return " " .. table.concat(names, ", ")
      end

      require("lualine").setup({
        options = {
          theme = "gruvbox",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
        -- Corta: modo · rama · archivo · diagnósticos ··· LSP · posición
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = { { "filename", path = 1 }, "diagnostics" },
          lualine_x = { lsp_info },
          lualine_y = {},
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- ============================================================
  -- NOICE: UI mejorada para mensajes, cmdline y popupmenu
  -- ============================================================
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {
      -- vim.notify lo gestiona snacks.notifier (ver más abajo)
      notify = { enabled = false },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    },
  },

  -- ============================================================
  -- WHICH-KEY: Muestra los keymaps disponibles
  -- ============================================================
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        plugins = { spelling = true },
        win = { border = "rounded" }, -- era opts.window, ahora es opts.win
      })
      -- Nueva spec de which-key v3+
      wk.add({
        { "<leader>f",  group = "  Buscar" },
        { "<leader>g",  group = "  Git" },
        { "<leader>l",  group = "  LSP" },
        { "<leader>j",  group = "  Java" },
        { "<leader>ha", group = "  Harpoon" },
        { "<leader>s",  group = "  Splits" },
        { "<leader>t",  group = "  Tabs" },
        { "<leader>b",  group = "  Buffers" },
        { "<leader>u",  group = "  Utils" },
        { "<leader>D",  group = "  Debug" }, -- cambiado a D mayúscula
      })
    end,
  },

  -- Iconos
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- ============================================================
  -- SNACKS: picker (sustituye a Telescope), notificaciones, guías de
  -- indentación, vim.ui.input y lazygit flotante. Sin dashboard ni
  -- animaciones (ver CLAUDE.md).
  -- ============================================================
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = false },
      input = { enabled = true },
      notifier = { enabled = true, style = "compact", timeout = 3000 },
      indent = {
        enabled = true,
        animate = { enabled = false },
        scope = { enabled = true },
      },
      -- configure = false: lazygit usa ~/.config/lazygit/config.yml
      -- (LG_CONFIG_FILE) con el tema Gruvbox, no un tema generado
      lazygit = { configure = false },
      picker = {
        enabled = true,
        ui_select = true,
        sources = {
          files = {
            hidden = true,
            exclude = { "node_modules", "target", "*.class", "*.jar", "*.war", "*.ear" },
          },
          grep = {
            hidden = true,
            exclude = { "node_modules", "target", "*.class", "*.jar", "*.war", "*.ear" },
          },
        },
      },
    },
    keys = {
      -- Buscar (mismas teclas que tenía Telescope)
      { "<leader>ff", function() Snacks.picker.files() end,                 desc = "Buscar archivos" },
      { "<leader>fg", function() Snacks.picker.grep() end,                  desc = "Buscar en contenido (grep)" },
      { "<leader>fb", function() Snacks.picker.buffers() end,               desc = "Buscar buffers abiertos" },
      { "<leader>fh", function() Snacks.picker.help() end,                  desc = "Buscar help" },
      { "<leader>fr", function() Snacks.picker.recent() end,                desc = "Archivos recientes" },
      { "<leader>fw", function() Snacks.picker.grep_word() end,             desc = "Buscar palabra bajo cursor", mode = { "n", "x" } },
      { "<leader>fd", function() Snacks.picker.diagnostics() end,           desc = "Diagnósticos LSP" },
      { "<leader>fs", function() Snacks.picker.lsp_symbols() end,           desc = "Símbolos del documento" },
      { "<leader>fS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Símbolos del workspace" },
      { "<leader>fc", function() Snacks.picker.git_log() end,               desc = "Commits Git" },
      { "<leader>fC", function() Snacks.picker.git_log_file() end,          desc = "Commits del buffer" },
      { "<leader>fj", function() Snacks.picker.files({ ft = "java", title = "Clases Java" }) end, desc = "Buscar archivos Java" },
      { "<leader>fk", function() Snacks.picker.keymaps() end,               desc = "Buscar keymaps" },
      { "<leader>f/", function() Snacks.picker.resume() end,                desc = "Reabrir última búsqueda" },
      { "<leader>fn", function() Snacks.picker.notifications() end,         desc = "Historial de notificaciones" },
      -- Git
      { "<leader>gg", function() Snacks.lazygit() end,                      desc = "Lazygit" },
      { "<leader>ge", function() Snacks.picker.git_status() end,            desc = "Git status (picker)" },
    },
  },
}
