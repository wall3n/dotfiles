# Global Claude Configuration

## Commit Style

Always use **Conventional Commits** when writing git commit messages.

### Format

```
<type>(scope): <description>

[optional body]

[optional footer]
```

### Rules

- **Language:** English only — subject line, body, and footer.
- **No Co-author:** Never include `Co-authored-by` trailers.
- **Subject line:** lowercase after the colon, no trailing period, max ~72 chars.
- **Body:** wrap at 72 chars; use it to explain *what* and *why*, not *how*.

### Allowed Types

| Type       | When to use                                              |
|------------|----------------------------------------------------------|
| `feat`     | A new feature                                            |
| `fix`      | A bug fix                                                |
| `docs`     | Documentation changes only                               |
| `style`    | Formatting, missing semicolons, etc. (no logic change)   |
| `refactor` | Code restructure without feature addition or bug fix     |
| `perf`     | Performance improvement                                  |
| `test`     | Adding or correcting tests                               |
| `build`    | Build system or dependency changes                       |
| `ci`       | CI/CD configuration changes                              |
| `chore`    | Maintenance tasks that don't fit elsewhere               |
| `revert`   | Reverts a previous commit                                |

### Breaking Changes

Add `!` after the type/scope and include a `BREAKING CHANGE:` footer:

```
feat(api)!: rename user endpoint

BREAKING CHANGE: /users is now /accounts
```

### Examples

```
feat(auth): add JWT refresh token support

fix(invoices): correct rounding error in tax calculation

refactor(domain): extract PaymentPolicy into its own class

chore(deps): upgrade Spring Boot to 3.4.0
```

## Toolchain and Versions

Always pick the **LTS or stable** release channel for a runtime, a compiler, or a
tool. Never propose or install a beta, an RC, a nightly, or a "latest major"
release only because it is newer. Stability comes before new features.

Current lines to hold:

| Tool | Line | Do not bump to |
|---|---|---|
| Node | 24.x LTS | 25.x (odd lines never get LTS); 26.x until this row changes, even after 26 becomes LTS |
| Python | 3.13 | 3.14 |
| Java | 21 LTS (Temurin, via mise) | non-LTS releases |
| Rust | `stable` rustup channel | `beta`, `nightly` |

Rules:

- When `mise outdated --bump` shows a newer major, do not apply it. Report it and wait.
- When a tool ships a stable build and a canary or nightly build, install the stable build.
- A project file (`.nvmrc`, `.node-version`, `.tool-versions`, `engines`) wins over this
  table. Read it first.
- State the version you install, and say where the pin comes from.

## Model Routing

The main model is `opusplan`: Opus in plan mode, Sonnet outside plan mode.
Subagents default to Sonnet (`CLAUDE_CODE_SUBAGENT_MODEL=sonnet`).

- Plan a task with more than 3 steps, or a design decision, in plan mode (Opus).
- Execute the approved plan outside plan mode (Sonnet).
- Send a small, mechanical task to the `quick-task` agent (Haiku): run tests or
  lint and report, rename, format, bump a version, summarize a log or a diff.
- Use the `Explore` agent for a wide codebase search. Keep only the conclusion.
- Do not send a task to Haiku if it needs a judgment call or has an unknown cause.
