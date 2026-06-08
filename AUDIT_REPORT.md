# Dotfiles Audit Report
Generated: 2026-06-08
Machine: Franciscos-MacBook-Pro-3 (macOS / darwin arm64)

## Executive Summary

| Tool       | Health | Startup | Issues Found | Priority Items |
|------------|--------|---------|--------------|----------------|
| Neovim     | 🔴     | ~98ms   | 12           | 4 (P0/P1)      |
| Tmux       | 🟡     | —       | 6            | 2              |
| Zsh        | 🟢     | ~30ms   | 5            | 1              |
| Alacritty  | ⚪ N/A | —       | 1            | 0              |
| Chezmoi    | 🟡     | —       | 5            | 3              |

🟢 Good  🟡 Needs attention  🔴 Broken or missing  ⚪ Not applicable

**Headline findings**

1. **Treesitter is broken** — errors on every startup, zero parsers installed, no syntax highlighting. This is the single most important fix.
2. **The repo is Catppuccin Mocha everywhere, not Gruvbox.** Ghostty, Starship, Tokyonight (Neovim), Tmux (Solarized-ish 256-color) and the README all diverge from the CLAUDE.md "Gruvbox Dark Hard" goal. This is a strategic decision to confirm, not a bug.
3. **The terminal is Ghostty, not Alacritty.** No Alacritty config exists anywhere (source or target). CLAUDE.md Goal 2/5 Alacritty work is moot unless you intend to switch terminals.
4. **Java debugging is non-functional.** `java-debug-adapter` and `vscode-java-test` are not installed; `init_options.bundles` is empty. `jdtls` JDK runtimes are hardcoded to Linux paths and will not resolve on macOS.

---

## Update — 2026-06-08 (implementation session: Gruvbox direction chosen, P0 + quick wins applied)

**Decisions:** theme direction = **Gruvbox** (full colorscheme conversion deferred as the next, large task); executed **P0 fixes + quick wins**.

### Fixed and verified
- **Treesitter** — repointed `nvim-treesitter` + `-textobjects` to `branch = "master"`, restored the classic `require("nvim-treesitter.configs").setup{}` API (textobjects nested inside). Ran `:Lazy sync` + parser installs. **Verified:** clean `nvim --headless +qall` (exit 0, no error), **16/16 parsers** installed, `ft=java ts=true` (highlighting active).
- **Tmux** — added `xterm-ghostty:RGB` true-color override. Applied.
- **Ghostty** — font → `JetBrainsMono Nerd Font` (icons). Applied. (Theme line still `Catppuccin Mocha` — changes in the Gruvbox task.)
- **Zsh** — added `autoload -Uz compinit && compinit -C`; fixed `alias cd='z'` to run *after* zoxide init. **Verified:** `cd=z` now set; clean interactive startup.
- **Chezmoi** — removed the Antigravity-injected duplicate `$PATH` lines (applied `.zshrc`/`.zprofile`); added `CLAUDE.md` + `AUDIT_REPORT.md` to `.chezmoiignore` (they would otherwise be written to `~/`); re-added `lazy-lock.json` to lock the working plugin pins. `chezmoi status` now clean except the (intentionally untriggered) `run_onchange` installer.
- **Install script** — dropped deprecated `tap "homebrew/cask-fonts"`; added `fd` (mac + linux), macOS `KeyRepeat`, and a headless Mason bootstrap (`jdtls java-debug-adapter java-test prettier google-java-format stylua`).
- **Tooling** — `brew install fd`; Mason-installed `java-debug-adapter`, `java-test`, `prettier`, `google-java-format` (note: correct Mason name is **`java-test`**, not `vscode-java-test`). All present.

### Newly discovered during implementation (not in the original static audit)
- **[P0, fixed] jdtls was never actually starting.** `plugins/java.lua` returns the plugin-spec array, so `require("config.plugins.java").setup()` (called from `autocmds.lua`) resolved `.setup` to `nil` and threw on every `FileType java`. Moved the `FileType` autocmd *into* `java.lua` (where `M.setup` is in scope) and removed the broken one from `autocmds.lua`.
- **[P0, fixed] Double jdtls instance → `exit code 13`.** `mason-lspconfig` v2 auto-enables (`vim.lsp.enable`) **every** installed Mason server, including `jdtls`, racing nvim-jdtls on the workspace. Added `automatic_enable = { exclude = { "jdtls" } }`. **Verified:** enabled-config list no longer contains jdtls; only the nvim-jdtls (`"java"`) process launches and initializes (logback/spifly in the LSP log).
- **[bug, fixed] Workspace name collision.** `project_name` used `fnamemodify(getcwd(), ":p:h:t")` → the *grandparent* dir name, so all projects under one folder shared a workspace. Changed to `":t"`.
- **[P1, fixed] DAP/test bundles** now globbed from Mason into `init_options.bundles`, filtering out the non-OSGi `runner-jar-with-dependencies` and `jacocoagent` jars.
- **[P2, open] `nvim-lspconfig` deprecation.** `lsp.lua:126` uses the deprecated `require('lspconfig')` framework (removed in nvim-lspconfig v3). Emits a warning on Java buffers. Migrate to `vim.lsp.config`/`vim.lsp.enable`.

### Not verifiable in this environment
- **Final jdtls *attach*** could not be confirmed: `nvim --headless` is not a valid harness for jdtls (even a minimal config fails to attach after 75s; the java process launches and initializes but the LSP handshake doesn't complete headless). The structural blockers are removed and the process starts cleanly as a single instance — **the user must confirm attach by opening a real Java project interactively** (`:LspInfo` should show `jdtls`).

### Gruvbox conversion — DONE (2026-06-08)
All 5 surfaces converted to **Gruvbox Dark Hard** and verified:
- **Ghostty** — `theme = Gruvbox Dark Hard` (built-in; `ghostty +show-config` confirms).
- **Starship** — palette `gruvbox_dark` with standard color-name keys, so existing `bold green`/`bold red` styles resolve to Gruvbox hues. `starship print-config` parses OK.
- **Neovim** — replaced `tokyonight.nvim` with `ellisonleao/gruvbox.nvim` (`contrast = "hard"`, `background = "dark"`); lualine theme → `gruvbox`. Verified `vim.g.colors_name == "gruvbox"`, `background == "dark"`, clean startup. tokyonight removed from lazy.
- **Tmux** — status bg `#1d2021`, active window `#d79921`, pane border `#504945` / active `#689d6a`, message accent orange `#d65d0e`.
- **README** — "Catppuccin Mocha" → "Gruvbox Dark Hard".

**Note for the user:** running sessions need a reload to pick up the theme — new shell (Starship), Ghostty reload (`Cmd/Ctrl+Shift+,`), tmux `<prefix> r`. Neovim already on Gruvbox.

### Still open (recommended next)
1. Remaining Java spec items (Goal 3): `<leader>jb` build / `<leader>jr` run / `<leader>jg` getters, Maven/Gradle autodetect, Lombok `-javaagent`.
2. which-key group reconciliation + `<leader>d` collision; `nvim-lspconfig` v3 migration.
3. markdown/markdown_inline parsers initially failed on a transient upstream tarball error but **auto-installed on a later run** — now present.

---

## Prioritized Action List

### 🔴 P0 — Fix immediately (broken or blocking)

- [ ] **[Neovim]** Treesitter throws on startup and has no parsers installed.
      Current: `nvim-treesitter` is on the `main` branch (experimental rewrite), but `treesitter.lua` calls `require("nvim-treesitter").setup{...}` and `require("nvim-treesitter-textobjects").setup{...}` — neither `.setup()` exists on `main`. Error: `treesitter.lua:28: attempt to call field 'setup' (a nil value)`. Parser dir `~/.local/share/nvim/lazy/nvim-treesitter/parser/` is **empty**.
      Fix: Pin both plugins to `branch = "master"` (classic, stable API) and use `require("nvim-treesitter.configs").setup{...}` + `require("nvim-treesitter.configs").setup{textobjects=...}`. Then `:TSUpdate`. (Alternatively migrate the config to the new `main` API, but `master` is lower-risk and matches the written config style.)
      File: `dot_config/nvim/lua/config/plugins/treesitter.lua`

- [ ] **[Neovim]** jdtls JDK runtimes hardcoded to Linux paths — Java LSP will fail to find a JDK on macOS.
      Current: `runtimes = { JavaSE-17 = "/usr/lib/jvm/java-17-openjdk-amd64", JavaSE-21 = "/usr/lib/jvm/..." }` (java.lua:63-66). This machine has OpenJDK **26** at `/usr/bin/java`; neither path exists.
      Fix: Detect JDKs dynamically (e.g. `/Library/Java/JavaVirtualMachines/*/Contents/Home` on macOS, `/usr/lib/jvm/*` on Linux) or drop the explicit `runtimes` block and let `JAVA_HOME` drive it. Add a chezmoi-templated or `vim.fn.has("mac")` branch.
      File: `dot_config/nvim/lua/config/plugins/java.lua`

### 🟡 P1 — High value improvements

- [ ] **[Neovim]** Java DAP is wired up but cannot run — debug adapter bundles are missing.
      Current: `init_options.bundles = {}` (java.lua:111) and `jdtls.setup_dap()` is called, but `java-debug-adapter` and `vscode-java-test` are **not** in Mason. `<leader>db`/`dc`/… keys exist but do nothing useful.
      Suggestion: `:MasonInstall java-debug-adapter vscode-java-test`, then populate `bundles` from the Mason install dirs (glob the `com.microsoft.java.debug.plugin-*.jar` and the test `*.jar` bundles).
      File: `dot_config/nvim/lua/config/plugins/java.lua`
      Effort: M

- [ ] **[Neovim]** `conform.nvim` formatters not installed → `format_on_save` falls back/fails silently.
      Current: formatters declared for `prettier`, `google-java-format`, `stylua` (lsp.lua:274-286). Installed: only `stylua` (via Mason). `prettier` and `google-java-format` are **MISSING** from PATH and Mason.
      Suggestion: `:MasonInstall prettier google-java-format` (or install via brew/npm), or remove the entries you don't want auto-running.
      File: `dot_config/nvim/lua/config/plugins/lsp.lua`
      Effort: S

- [ ] **[Neovim]** `fd` not installed but Telescope depends on it.
      Current: `<leader>fj` uses `find_command = { "fd", ... }` (navigation.lua:30); `fd` is **MISSING** on this Mac. The install script never installs `fd` on either platform.
      Suggestion: `brew install fd`; add `fd` to the brew bundle and to the Linux apt list (as `fd-find` + alias).
      File: `run_onchange_install-packages.sh.tmpl`, `dot_config/nvim/lua/config/plugins/navigation.lua`
      Effort: S

- [ ] **[Neovim]** Java spec gaps vs CLAUDE.md Goal 3: no `<leader>jb` *build*, `<leader>jr` run, `<leader>jd` debug-main, `<leader>jg` getters/setters; `<leader>jb` is currently *bytecode view*; no `neotest`; no Lombok `-javaagent` detection; no Maven/Gradle autodetect.
      Suggestion: Implement build-system detection (`pom.xml` → mvn, `build.gradle[.kts]` → gradle) behind `<leader>jb`/`<leader>jr`, add `<leader>jg` via `jdtls` source actions, add Lombok jar detection in the `cmd`. Decide whether `neotest` is wanted (current `jdtls.test_*` covers nearest/class already).
      File: `dot_config/nvim/lua/config/plugins/java.lua`
      Effort: L

- [ ] **[Tmux]** No true-color override for Ghostty (the actual terminal).
      Current: overrides set for `xterm-256color`, `alacritty`, `kitty` only (tmux.conf). Ghostty reports `xterm-ghostty`/`xterm-256color`; colors may be flat depending on `$TERM`.
      Suggestion: add `set -ag terminal-overrides ",xterm-ghostty:RGB"`.
      File: `dot_config/tmux/tmux.conf`
      Effort: S

- [ ] **[Zsh]** `compinit` is never called → completion system not initialized; `-C` cache flag absent.
      Current: `.zshrc` sources `zsh-autosuggestions`, `starship`, `zoxide` but never runs `compinit`. Tab-completion for many commands is degraded.
      Suggestion (additive): append before plugin sources — `autoload -Uz compinit && compinit -C`.
      File: `empty_dot_zshrc.tmpl`
      Effort: S

- [ ] **[Chezmoi]** Pending dirty targets — `chezmoi status` shows `MM` on `.zshrc`, `.zprofile`, `.config/nvim/lazy-lock.json`.
      Current: target `.zshrc`/`.zprofile` carry duplicate `export PATH="…/.local/bin"` lines injected by "Antigravity CLI installer"; the source has already removed them. `lazy-lock.json` drifted from plugin updates.
      Suggestion: review `chezmoi diff` then `chezmoi apply` (zshrc/zprofile) and `chezmoi re-add` the lazy-lock if you want the updated pins tracked.
      File: target `.zshrc`, `.zprofile`, `.config/nvim/lazy-lock.json`
      Effort: S

- [ ] **[Chezmoi]** Install script gaps vs Goal 5.
      Current: `run_onchange_install-packages.sh.tmpl` has no Mason headless bootstrap, no `fd`, no macOS key-repeat tweak, and uses the deprecated `tap "homebrew/cask-fonts"` (fonts are in the main cask repo now).
      Suggestion: add `nvim --headless "+MasonInstall jdtls java-debug-adapter vscode-java-test prettier google-java-format" +qall`; add `fd`; add `defaults write -g KeyRepeat -int 1`; drop the cask-fonts tap line.
      File: `run_onchange_install-packages.sh.tmpl`
      Effort: M

### 🟢 P2 — Nice to have

- [ ] **[Neovim]** which-key groups are stale/mismatched. `<leader>D` registered for Debug but real keys are lowercase `<leader>d{b,c,s,i,o,q}`; `<leader>x` (Trouble), `<leader>r`, `<leader>e`, `<leader>c` groups unregistered; `<leader>s` mixes Splits + Spectre.
      Suggestion: align group labels with actual bindings.
      File: `dot_config/nvim/lua/config/plugins/ui.lua`
      Effort: S

- [ ] **[Neovim]** `<leader>d` is bound to "delete without register" (keymaps.lua:30) *and* used as the Debug prefix (`<leader>db…`). The operator works but adds `timeoutlen` lag and muddies which-key.
      Suggestion: move debug keys under a dedicated prefix (e.g. `<leader>D…`) to match the registered group, or move delete elsewhere.
      File: `dot_config/nvim/lua/config/plugins/java.lua`, `keymaps.lua`
      Effort: S

- [ ] **[Neovim]** `indent-blankline.nvim` replicates a 0.10+ built-in (`vim.opt.list` + `listchars`).
      Suggestion: optional — drop the plugin to reduce sprawl.
      Effort: S

- [ ] **[Neovim]** Mason has `clangd` and `marksman` installed but neither is configured in `lspconfig`.
      Suggestion: configure or uninstall to avoid drift.
      Effort: S

- [ ] **[Zsh]** `alias cd='z'` never takes effect — the `command -v z` guard (line 66) runs *before* `zoxide init` (line 108), so `z` isn't defined yet.
      Suggestion: move the zoxide alias after the `eval "$(zoxide init zsh)"` line, or use `alias cd='z'` unconditionally there.
      File: `empty_dot_zshrc.tmpl`
      Effort: S

- [ ] **[Zsh]** `nvm` is sourced eagerly (lines 93-95). Harmless here (nvm not installed) but adds ~hundreds of ms on machines that have it.
      Suggestion: lazy-load nvm on first `nvm`/`node`/`npm` call.
      File: `empty_dot_zshrc.tmpl`
      Effort: S

- [ ] **[Tmux]** Two session managers coexist: `tmux-sessionizer` (`prefix f`) and `tmux-sessionx` (`prefix o`). Redundant in function.
      Suggestion: keep one.
      Effort: S

- [ ] **[Tmux]** `tmux-thumbs` hardcodes `xclip` (`@thumbs-command`) — broken on macOS (no xclip).
      Suggestion: template the clipboard command (`pbcopy` on darwin, `xclip` on linux) or use `tmux-yank`'s buffer.
      File: `dot_config/tmux/tmux.conf`
      Effort: S

- [ ] **[Chezmoi]** `.gitconfig` / `.gitignore_global` / `.stCommitMsg` are not tracked by chezmoi.
      Suggestion: `chezmoi add ~/.gitconfig` (templatize the Sourcetree/macOS-specific paths) if you want git config synced cross-platform.
      Effort: S

---

## Neovim — Detailed Findings

### Startup Performance
- Total startup time: **~98ms** (acceptable; benchmark <80ms good, >150ms bad). Inflated by the treesitter error path and `lazy=false` treesitter loading at boot.
- Top contributors (from `--startuptime`):
  1. `require('config.lazy')` — ~80ms (plugin loading)
  2. tokyonight colorscheme — ~3.8ms
  3. harpoon — ~7ms
  4. mason — ~6.8ms
  5. nvim-treesitter-textobjects sourcing — ~7.7ms (then errors)
- Note: the treesitter `config` function aborts midway, so highlight/indent never initialize.

### Plugin Inventory
44 plugins (healthy count; benchmark <30 is "focused" but this set is deliberate).

| Plugin | Purpose | Status |
|--------|---------|--------|
| tokyonight.nvim | Colorscheme (active) | **Diverges** — CLAUDE goal is Gruvbox |
| nvim-treesitter (+textobjects) | Syntax/indent | **Broken** — wrong branch, no parsers |
| nvim-lspconfig, mason, mason-lspconfig | LSP stack | Essential |
| nvim-cmp + cmp-* + LuaSnip + friendly-snippets | Completion | Essential |
| nvim-jdtls | Java LSP | Essential (misconfigured paths) |
| nvim-dap, nvim-dap-ui, nvim-nio | Debug | Essential (Java bundles missing) |
| conform.nvim | Formatting | Essential (formatters missing) |
| telescope + fzf-native + ui-select | Fuzzy find | Essential |
| harpoon (harpoon2) | File pinning | Essential |
| neo-tree.nvim | File tree | Essential (note: CLAUDE.md "What NOT to do" says no NERDTree; neo-tree is allowed) |
| vim-fugitive + gitsigns.nvim | Git | Essential |
| which-key.nvim | Keymap hints | Essential (groups stale) |
| trouble.nvim | Diagnostics list | Essential |
| nvim-spectre | Project search/replace | Essential |
| todo-comments.nvim | TODO nav | Essential |
| leap.nvim | Motion | Essential |
| nvim-surround, Comment.nvim, nvim-autopairs | Edit helpers | Essential |
| undotree | Undo history | Essential |
| noice.nvim + nui + nvim-notify | UI messages | Essential (heavy; optional) |
| lualine.nvim | Statusline | Essential (theme=tokyonight) |
| indent-blankline.nvim | Indent guides | **Replaceable** by built-in `listchars` |
| stay-in-place.nvim | Keep cursor on indent | Optional |
| lazydev.nvim | Lua dev | Essential |

No true functional duplicates beyond indent-blankline-vs-builtin.

### Keybinding Map (`<leader>` space)

| Prefix | Binding(s) | Description | Conflict / Note |
|--------|-----------|-------------|-----------------|
| `<leader>f` | ff/fg/fb/fh/fr/fw/fd/fs/fS/fc/fC/fj, ft/fT | Find (Telescope + TODOs) | OK; `fj` needs `fd` |
| `<leader>g` | gs/gc/gp/gP/gb/gd/gl/gL/gr (fugitive), ghs/ghr/… (gitsigns), ge (neotree) | Git | `<leader>gd` set by both fugitive and gitsigns(`ghd`) — distinct keys, OK |
| `<leader>l` | la/lr/lf/lF/ld/lD/ls/lwa/lwr/lwl/lm | LSP | OK |
| `<leader>j` | jo/jv/jc/jm/jt/jT/ju/jb(bytecode) | Java | `jb` ≠ "build" per spec; jr/jd/jg missing |
| `<leader>d` | "delete without register" (n/v) | — | **Collides with `<leader>d*` debug prefix** |
| `<leader>D` | (which-key group "Debug") | — | No keys actually under `D` |
| `<leader>s` | sv/sh/se/sx (splits), sr/sw/sf (spectre) | Splits + Spectre | Mixed semantics |
| `<leader>t` | to/tx/tn/tp | Tabs | OK |
| `<leader>b` | bd | Buffers | OK |
| `<leader>h` | ha/hh/hp/hn, h1-h4 | Harpoon | OK |
| `<leader>x` | xx/xw/xd/xq/xl | Trouble | which-key group unregistered |
| `<leader>u` | uu | Undotree | OK |
| `<leader>e`/`o` | neotree toggle/focus | Tree | OK |
| `<leader>r` | rw | Replace word | which-key group unregistered |
| `<leader>c` | cx | chmod +x | which-key group unregistered |

Undocumented (no which-key label): `<leader>x`, `<leader>r`, `<leader>c`, `<leader>e`. Conflict: `<leader>d` operator vs debug prefix.

### LSP Configuration
- **Configured in lspconfig:** ts_ls, eslint, html, cssls, jsonls, yamlls, lua_ls (+ jdtls via nvim-jdtls).
- **Installed in Mason:** clangd, css-lsp, eslint-lsp, html-lsp, jdtls, json-lsp, lua-language-server, marksman, typescript-language-server, yaml-language-server (+ markdownlint-cli2, markdown-toc, shfmt, stylua, tree-sitter-cli).
- **Discrepancy:** `clangd` and `marksman` installed but never configured. `markdownlint-cli2`/`shfmt` present but not wired into conform/lint.
- **Formatters:** conform declares prettier/google-java-format/stylua; **prettier and google-java-format missing**. eslint LSP also auto-fixes on save (`EslintFixAll`) — overlaps with prettier on JS/TS; verify intended (eslint fix + prettier format can fight).
- **Java LSP status:** present but **misconfigured** (Linux JDK paths, empty DAP bundles, no Lombok agent).

### Treesitter Grammars
- **Installed:** none (parser dir empty).
- **Declared (ensure_installed):** java, javascript, typescript, tsx, html, css, json, yaml, xml, lua, bash, markdown, markdown_inline, regex, sql, dockerfile.
- **Status:** completely non-functional (see P0).

### Colorscheme
- Active theme: **tokyonight-night** (dark).
- lualine theme: tokyonight.
- Status: **diverges** from CLAUDE.md Gruvbox Dark Hard goal. No `gruvbox.nvim` installed.

### Improvements Suggested (Neovim)
1. Fix treesitter branch + API + run `:TSUpdate` (P0).
2. Fix jdtls JDK runtime detection for macOS/Java 26 (P0).
3. Install + bundle java-debug-adapter & vscode-java-test for DAP (P1).
4. Install prettier + google-java-format, or trim conform config (P1).
5. Install `fd` (P1).
6. Decide Gruvbox vs Catppuccin (see Cross-Cutting) — if Gruvbox, add `ellisonleao/gruvbox.nvim` and switch lualine theme (P1).
7. Implement Java build/run/getters bindings per Goal 3 (P1).
8. Reconcile which-key groups and the `<leader>d` collision (P2).

---

## Tmux — Detailed Findings

### Current Configuration
- Prefix key: **`C-a`** (with `C-b` retained as send-prefix). Ergonomic, well done.
- True color: enabled for xterm-256color/alacritty/kitty — **missing Ghostty**.
- `default-terminal`: `tmux-256color` ✅.
- Mouse: **on** ✅.
- Copy mode: **vi** ✅, with `v`/`V`/`C-v`/`y`/`H`/`L` bindings.
- escape-time: `0` ✅ (good for nvim).
- history-limit: `50000` ✅.
- status-interval: `1s` ✅.
- focus-events: on ✅.
- Plugins (TPM): tpm, tmux-sensible, tmux-yank, tmux-resurrect, tmux-continuum, sessionx (omerxx), floax (omerxx), tmux-thumbs (fcsonline).

### Keybinding Map (custom highlights)

| Key | Action | Notes |
|-----|--------|-------|
| `prefix r` | reload config | OK |
| `prefix \|` / `-` | split h / v (cwd inherited) | intuitive ✅ |
| `prefix h/j/k/l` | select pane (repeatable) | vim-style ✅ |
| `prefix H/J/K/L` | resize pane | repeatable ✅ |
| `prefix m` | zoom toggle | also native `prefix z` |
| `prefix < / >` | swap window left/right | OK |
| `prefix f` | tmux-sessionizer | redundant with `o` |
| `prefix o` | tmux-sessionx | redundant with `f` |
| `prefix N` | new named session | OK |
| `prefix X` | kill session (confirm) | OK |
| `Alt-p` | floax floating pane | OK |

### Status Bar
- Segments: left = session name; right = current path + date + time. Minimal ✅.
- Refresh: 1s ✅.
- Colors: custom 256-color (bg colour235, accent orange colour136/166) — **Solarized-ish, not Gruvbox**.
- Uses powerline glyphs (``) — CLAUDE.md Goal 2 asks for ASCII-clean; minor divergence.

### Improvements Suggested (Tmux)
1. Add `set -ag terminal-overrides ",xterm-ghostty:RGB"` (P1).
2. If unifying on Gruvbox: restyle status to bg `#1d2021`, active window `#d79921`, pane border `#504945`/active `#689d6a` (P1, decision-gated).
3. Templatize `tmux-thumbs` clipboard command for macOS (`pbcopy`) (P2).
4. Drop one of sessionizer/sessionx (P2).
5. (Optional) Add `prefix ?` `display-popup` running the `keymaps` script — you already have a superior fzf cheatsheet, so the CLAUDE Goal 4B popup is effectively satisfied by `~/.local/bin/keymaps`.

---

## Zsh — Detailed Findings

### Startup Performance
- Measured: **~30ms** warm (first run 0.22s cold). Excellent (benchmark <300ms).
- Eager `nvm` sourcing (lines 93-95) is the only latent risk — it's a no-op here because nvm isn't installed.

### Plugin Inventory
- Plugin manager: none (hand-rolled `.zshrc`, no oh-my-zsh/zinit). Clean.
- Loaded: `zsh-autosuggestions` (sourced if present), starship, zoxide, optional fzf key-bindings.
- Slow/redundant: none active.

### Alias Audit
| Alias | Target | Status |
|-------|--------|--------|
| ls/l/lt/ltree | eza | ✅ eza installed |
| cat | bat | ✅ bat installed |
| v/vi/vim | nvim | ✅ |
| cd | z (zoxide) | ⚠️ **never applied** — guard runs before zoxide init |
| gadd/gc/gca/gco/gdiff/gst/gps/gpl/gb/gl | git | ✅ |
| tunnel | cloudflared | ⚠️ cloudflared not verified installed |
| projects | find+fzf | ✅ |
| autoskill | npx autoskills | ✅ |
- `fd` alias only defined for Linux (`fdfind`); on macOS `fd` is simply missing (install it).

### PATH Audit
- Source uses `typeset -U path` → dedupes automatically ✅.
- Duplicate currently visible in the live shell: `/Users/franmoreno/.local/bin` (injected into target `.zshrc`/`.zprofile` by the Antigravity installer). The chezmoi **source has already removed** these lines — `chezmoi apply` clears the dup.
- No non-existent-dir cleanup needed (array entries are conditional/standard).

### History Configuration
- HISTSIZE 10000 ✅, SAVEHIST 10000 ✅, `share_history` ✅, plus dedup/verify opts. Good.

### Improvements Suggested (Zsh) — additive only
1. Append `autoload -Uz compinit && compinit -C` (before plugin sourcing) — initializes completion with cache (P1).
2. Move/duplicate `alias cd='z'` to after the `eval "$(zoxide init zsh)"` line so it actually applies (P2).
3. (Optional) Lazy-load nvm to protect startup on nvm-equipped machines (P2).
4. (Optional, per Goal 6) add a `keys` function aliasing the existing `keymaps` script for context-aware cheatsheets.

---

## Alacritty — Detailed Findings

**Not applicable.** No Alacritty config exists in the chezmoi source or at `~/.config/alacritty/`. The active terminal is **Ghostty** (`dot_config/ghostty/config`), with `i3` configured to launch Ghostty on Linux. CLAUDE.md's Alacritty goals are obsolete unless you intend to adopt Alacritty.

For reference, the Ghostty config:
- Format: native Ghostty config ✅.
- Font: `JetBrains Mono`, size 17. **Not the Nerd Font variant** — icons in Neovim/neo-tree/lualine may render as boxes. Suggest `font-family = "JetBrainsMono Nerd Font"` (the install script does install `font-jetbrains-mono-nerd-font`).
- Theme: **Catppuccin Mocha** — diverges from Gruvbox goal.
- `window-decoration = false`, `mouse-hide-while-typing = true`, `shell-integration = zsh` ✅.

---

## Chezmoi — Detailed Findings

### Tracked Files (by tool)
- **Neovim:** init.lua, lazy-lock.json, lua/config/* (options, keymaps, lazy, autocmds, plugins/*) ✅
- **Tmux:** dot_config/tmux/tmux.conf ✅
- **Zsh:** empty_dot_zshrc.tmpl, empty_dot_zprofile.tmpl ✅ (templated)
- **Ghostty:** dot_config/ghostty/config ✅
- **i3:** dot_config/i3/config ✅ (Linux)
- **Starship:** dot_config/starship.toml ✅
- **Scripts:** private_dot_local/bin/executable_keymaps, executable_tmux-sessionizer ✅; run_onchange_install-packages.sh.tmpl ✅
- **Opencode:** large dot_config/opencode/** tree ✅
- **CLAUDE.md:** staged (status `A`).

### Untracked Files (candidates)
- `~/.gitconfig`, `~/.gitignore_global`, `~/.stCommitMsg` — not managed. Git config drifts per-machine; consider tracking (templatized, since it contains macOS Sourcetree paths).
- No Alacritty (n/a).

### Template Usage
- Templated: `empty_dot_zprofile.tmpl` (darwin brew branch), `empty_dot_zshrc.tmpl`, `run_onchange_install-packages.sh.tmpl` (darwin/linux branches). Good.
- Should be templated but isn't: `dot_config/nvim/lua/config/plugins/java.lua` (hardcoded Linux JDK paths — better solved in Lua at runtime than via chezmoi template, but either works). `dot_config/tmux/tmux.conf` `tmux-thumbs` clipboard command (xclip hardcoded).

### Cross-Platform Gaps
**Breaks on macOS (current machine):**
- jdtls JDK paths (`/usr/lib/jvm/...`) — Linux-only (P0).
- `tmux-thumbs` `xclip` command — Linux-only.
- `fd` not installed by the mac brew bundle but required by Telescope.

**Breaks on Linux:**
- Ghostty install path `/snap/bin/ghostty` assumed in i3 — fine only if installed via snap.
- `bat` symlinked from `batcat`; eza via gierens repo — handled ✅.
- Mason tools (jdtls/etc.) never bootstrapped by the install script on either OS.

### Idempotency
- `run_onchange_install-packages.sh.tmpl` is largely idempotent (command guards, `brew bundle`). Concerns:
  - `chsh -s "$(which zsh)"` re-runs are harmless but may prompt for password.
  - `tap "homebrew/cask-fonts"` is **deprecated** (now in core cask) — will warn/fail on newer Homebrew.
  - No `run_once_` bootstrap distinct from `run_onchange_`; acceptable since content-hashed.

---

## Cross-Cutting Observations

### Theme Consistency
CLAUDE.md targets **Gruvbox Dark Hard**. Reality is **Catppuccin Mocha** across the board:
- Ghostty (terminal): ❌ Catppuccin Mocha
- Neovim: ❌ Tokyonight Night
- Tmux: ❌ custom Solarized-ish 256-color
- Zsh prompt (Starship): ❌ Catppuccin Mocha palette
- README: ❌ advertises "Catppuccin Mocha Theme"

**This is a coherent Catppuccin setup, not a broken Gruvbox one.** Before doing any Goal 2 work, confirm the intended direction (see question at end). Converting to Gruvbox touches Ghostty theme, starship palette, tokyonight→gruvbox.nvim, lualine theme, tmux status colors, and the README.

### Keyboard Consistency
- Neovim leader: `Space`. Tmux prefix: `C-a`. i3 mod: `Mod4`. No collisions (tmux pane nav is `prefix h/j/k/l`, not bare `C-hjkl`).
- Neovim uses bare `C-h/j/k/l` for window nav; tmux does **not** intercept these (prefix-based), so no conflict — but also **no seamless cross-app nav**. CLAUDE cross-cutting suggests `vim-tmux-navigator`; not installed. Optional.

### Java Development Readiness — Score: **2 / 5**
- [x] `jdtls` installed via Mason
- [~] `nvim-jdtls` configured (via `plugins/java.lua` + FileType autocmd, not `ftplugin/java.lua`) — works, but JDK paths broken on macOS
- [ ] DAP functional — `java-debug-adapter` not installed, `bundles` empty
- [ ] `neotest` Java runner — not installed (uses `jdtls.test_*` instead; partial)
- [ ] Build system (Maven/Gradle) integration — not implemented; `mvn` present, `gradle` missing
Gap: install debug/test bundles, fix JDK runtimes, add build/run bindings, add Lombok agent detection.

---

## Implementation Order Recommendation

### Quick wins (< 30 min each)
1. Fix treesitter branch/API + `:TSUpdate` (unblocks highlighting; P0).
2. `:MasonInstall java-debug-adapter vscode-java-test prettier google-java-format`; `brew install fd`.
3. `chezmoi diff` review then `chezmoi apply` to clear the PATH-dup drift.
4. Add Ghostty true-color override in tmux; switch Ghostty font to the Nerd Font variant.
5. Add `compinit -C` and fix the `cd→z` alias ordering in `.zshrc`.
6. Drop deprecated `cask-fonts` tap; add `fd` + Mason bootstrap to install script.

### Medium effort (30 min – 2 hours each)
1. Fix jdtls JDK runtime detection (macOS/Java 26) and populate DAP `bundles` (Java debugging end-to-end).
2. Reconcile which-key groups + `<leader>d` collision.
3. Templatize tmux-thumbs clipboard; prune one session manager.
4. Track `.gitconfig` (templatized) in chezmoi.

### Large effort (> 2 hours, plan carefully)
1. **Theme decision + execution** — Gruvbox vs keep Catppuccin. If Gruvbox: Ghostty + Starship + Neovim (gruvbox.nvim) + lualine + tmux + README. (CLAUDE Goal 2.)
2. **Full Java stack to spec** — build/run/getters bindings, Maven/Gradle autodetect, Lombok agent, optional neotest. (CLAUDE Goal 3.)

---

_End of report. All findings above are based on the actual state of the config files as read during this session. No assumptions were made._
