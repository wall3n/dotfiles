return {
  -- ============================================================
  -- OIL: editar el sistema de archivos como si fuera un buffer
  -- Complementa a neo-tree: neo-tree para el árbol lateral, oil para
  -- renombrar/mover/crear en masa con los mismos comandos de vim.
  -- ============================================================
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false, -- necesario para poder abrir `nvim <directorio>`
    keys = {
      { "-",          "<cmd>Oil<CR>",                desc = "Oil: abrir directorio padre" },
      { "<leader>eo", "<cmd>Oil --float<CR>",        desc = "Oil: abrir en ventana flotante" },
    },
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = { show_hidden = true },
      float = { padding = 4, max_width = 100, max_height = 30 },
      keymaps = {
        ["q"] = "actions.close",
        ["<C-h>"] = false, -- liberado para vim-tmux-navigator
        ["<C-l>"] = false, -- liberado para vim-tmux-navigator
        ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
        ["<C-v>"] = { "actions.select", opts = { vertical = true } },
      },
    },
  },

  -- ============================================================
  -- VIM-TMUX-NAVIGATOR: C-h/j/k/l cruza la frontera nvim <-> tmux
  -- Sin esto, al llegar al borde de un split de nvim el cursor se queda
  -- atascado en lugar de saltar al pane de tmux contiguo.
  -- Necesita el plugin gemelo en tmux.conf (christoomey/vim-tmux-navigator).
  -- ============================================================
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<CR>",     desc = "Ir a split/pane izquierda" },
      { "<C-j>", "<cmd>TmuxNavigateDown<CR>",     desc = "Ir a split/pane abajo" },
      { "<C-k>", "<cmd>TmuxNavigateUp<CR>",       desc = "Ir a split/pane arriba" },
      { "<C-l>", "<cmd>TmuxNavigateRight<CR>",    desc = "Ir a split/pane derecha" },
      { "<C-\\>", "<cmd>TmuxNavigatePrevious<CR>", desc = "Ir al split/pane anterior" },
    },
  },
}
