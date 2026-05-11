return {
  -- ============================================================
  -- COLORSCHEMA: Tokyonight (rendimiento excelente, muy popular)
  -- Alternativa: catppuccin, rose-pine
  -- ============================================================
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        sidebars = "dark",
        floats = "dark",
      },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-night")
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
          theme = "tokyonight",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { lsp_info, "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
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
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
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
        { "<leader>f",  group = "  Buscar/Telescope" },
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

  -- Indentación visual
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope = { enabled = true },
    },
  },
}
