# 🔧 Dotfiles

Configuración personal para macOS y Linux, gestionada con **[Chezmoi](https://www.chezmoi.io/)**.
Diseñada para ser rápida, moderna y estéticamente agradable (Gruvbox Dark Hard Theme).

![OS](https://img.shields.io/badge/OS-macOS%20%7C%20Linux-white?logo=apple)
![Manager](https://img.shields.io/badge/Manage-Chezmoi-blue)
![Shell](https://img.shields.io/badge/Shell-Zsh-green)

## 🚀 Instalación Rápida (One-Liner)

En una máquina nueva (Mac o Linux), abre la terminal y ejecuta:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply wall3n
```

## 🤖 Claude Code

La config de Claude Code vive en `claude/`. `~/.claude` solo tiene symlinks
a esos archivos (ver `dot_claude/`). Si Claude cambia `settings.json`, el
cambio entra directo en el repo: revisa `git diff` y haz commit.

| Qué | Dónde |
|---|---|
| Instrucciones globales, settings, statusline | `claude/CLAUDE.md`, `claude/settings.json`, `claude/statusline.py` |
| Agents (`quick-task`, `scaffolder`, `worker`, `user-tester`) | `claude/agents/` |
| Commands (`/feature-loop`, `/orchestrate`, `/atomic-commit`, `/push-all`) | `claude/commands/` |
| Hooks (output cap, journal, git y lint guards) | `claude/hooks/` |
| Skills propias (`ste-writing`, `code-audit`, `explain-codebase`) | `claude/skills/` |
| Skills de terceros (se reinstalan, no se copian) | `claude/skills-lock.json` |

`run_onchange_after_restore-claude.sh` reinstala las skills de terceros
del lock y los plugins de `settings.json` en un equipo nuevo.

**Journal:** en un repo con `docs/journal/`, al cerrar cada sesión Haiku
resume los commits y cambios del día en `docs/journal/AAAA-MM-DD.md`.
En un repo sin esa carpeta, Claude pregunta una vez si la crea.
