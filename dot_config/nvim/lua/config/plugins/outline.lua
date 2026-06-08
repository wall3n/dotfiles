return {
  -- Symbol outline (clases, métodos, campos) en panel derecho.
  -- Backend LSP para Java (jdtls) y treesitter para el resto de lenguajes.
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
    keys = {
      { "<leader>cs", "<cmd>AerialToggle right<CR>", desc = "Symbols: outline (derecha)" },
      { "{", "<cmd>AerialPrev<CR>", desc = "Symbol anterior" },
      { "}", "<cmd>AerialNext<CR>", desc = "Symbol siguiente" },
    },
    opts = {
      backends = { "lsp", "treesitter", "markdown", "man" },
      layout = { default_direction = "right", min_width = 30 },
      attach_mode = "global",
      show_guides = true,
      filter_kind = false, -- mostrar todos los tipos de símbolo
    },
  },
}
