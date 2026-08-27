return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master", -- API estable (configs.setup). El branch main es el rewrite experimental.
    build = ":TSUpdate",
    lazy = false, -- cargar al inicio, no lazy
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "java", "javascript", "typescript", "tsx",
          "html", "css", "json", "jsonc", "yaml", "toml", "xml",
          "lua", "luadoc", "bash", "markdown", "markdown_inline",
          "regex", "sql", "dockerfile",
          -- Sistemas / universidad
          "c", "cpp", "python", "go", "rust", "make", "cmake", "asm",
          -- Meta: necesarios para :checkhealth y para editar la propia config
          "vim", "vimdoc", "query", "diff", "gitcommit", "gitignore",
        },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        -- En el branch master los textobjects se configuran aquí dentro
        textobjects = {
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
        },
      })
    end,
  },
}
