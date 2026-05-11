return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false, -- cargar al inicio, no lazy
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      -- Nueva API de nvim-treesitter v1.0+
      -- Ya no usa require("nvim-treesitter.configs").setup()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "java", "javascript", "typescript", "tsx",
          "html", "css", "json", "yaml", "xml",
          "lua", "bash", "markdown", "markdown_inline",
          "regex", "sql", "dockerfile",
        },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
      })

      -- Textobjects se configura por separado en v1.0
      require("nvim-treesitter-textobjects").setup({
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
          },
        },
      })
    end,
  },
}
