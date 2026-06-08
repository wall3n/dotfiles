# Package view + symbol outline — design

Date: 2026-06-08

## Goal

Two command-triggered side panels in Neovim:

- **Left — Java package explorer:** browse project structure (Java packages = nested
  directories) on demand.
- **Right — symbol outline:** structural outline of the current file (classes, methods,
  fields), navigable by jumping.

## Decisions

- **Left panel = reuse existing `neo-tree`.** No dedicated Java-package-explorer plugin
  exists in the minimal nvim ecosystem; Java packages are directories, and `neo-tree`
  already renders them as a nested tree (`filetree.lua`). Honors minimal-deps principle —
  zero new plugins.
- **Right panel = `stevearc/aerial.nvim`.** Lightweight, treesitter + LSP backends
  (jdtls drives Java symbols; treesitter covers other langs). Opens on the right. One new
  plugin.

## Changes

### 1. New plugin file (chezmoi source / target)

- Source: `~/.local/share/chezmoi/dot_config/nvim/lua/config/plugins/outline.lua`
- Target: `~/.config/nvim/lua/config/plugins/outline.lua`

Spec (`aerial.nvim`):

```lua
return {
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
```

Notes:
- `{` / `}` symbol nav uses `AerialPrev`/`AerialNext` (no-op when outline closed; aerial
  guards this). If this feels intrusive, drop those two keys — `<leader>cs` is the core.
- Gruvbox: aerial inherits the active colorscheme highlight groups; no extra theming.

### 2. Neo-tree keybind — package explorer

Add one entry to the `keys` table in `filetree.lua`:

```lua
{ "<leader>jp", "<cmd>Neotree filesystem left reveal<CR>", desc = "Java: explorador de paquetes" },
```

Reveals the current file inside the left tree. Reuses the already-configured neo-tree
instance — no behavioral change to existing `<leader>e` / `<leader>o` / `<leader>ge`.

## Keybindings (new)

| Key          | Action                          | Side  |
|--------------|---------------------------------|-------|
| `<leader>jp` | Package explorer (neo-tree)     | left  |
| `<leader>cs` | Symbol outline (aerial)         | right |
| `}` / `{`    | Next / prev symbol (aerial)     | —     |

No collisions: `<leader>jp` is free in the Java group; `<leader>cs` is free (`<leader>cx`
is chmod). `<leader>e/o/ge` unchanged.

## Verification

- `<leader>jp` opens neo-tree on left, current file revealed.
- `<leader>cs` toggles aerial on right; in a `.java` file symbols come from jdtls, in
  `.lua`/`.ts` from treesitter/LSP.
- `}` / `{` jump between symbols when aerial is open.
- `:checkhealth aerial` clean.
- Existing neo-tree bindings still behave as before.

## Out of scope

- No second file tree, no neo-tree replacement.
- No new which-key group (`<leader>j` and `<leader>c` already exist).
