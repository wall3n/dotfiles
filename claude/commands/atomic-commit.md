---
description: Split the working tree into atomic Conventional Commits and commit them
argument-hint: "[optional scope hint or path to limit the commits to]"
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*), Bash(git restore:*), Bash(git rev-parse:*), Bash(git branch:*), Read, Grep, Glob
---

Commit the current working tree as a series of atomic commits.

Scope hint from the user (may be empty): $ARGUMENTS

## Current state

- Branch: !`git rev-parse --abbrev-ref HEAD`
- Status: !`git status --short`
- Staged diff stat: !`git diff --cached --stat`
- Unstaged diff stat: !`git diff --stat`
- Recent commits, for the style in this repository: !`git log --oneline -12`

## What to do

1. Read the full diff (`git diff` and `git diff --cached`). Read a changed file when the diff alone does not show the intent.
2. Group the changes into atomic commits. One commit does one thing. A refactor and a feature never share a commit. A formatting-only change gets its own `style:` commit.
3. Print the plan first: one line for each commit, in the form `<type>(scope): <subject> — <the files>`. Then commit, without waiting for an answer.
4. For each commit: `git add` only that group's paths, then `git commit`. Never `git add -A` and never `git add .`.
5. After the last commit, run `git status --short` and `git log --oneline`. Report both, and name any file you left uncommitted, with the reason.

## Message rules

These come from `~/.claude/CLAUDE.md`, and they are not negotiable:

- Conventional Commits: `<type>(scope): <description>`.
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
- English only, in the subject, the body, and the footer.
- Lowercase after the colon. No trailing period. Maximum 72 characters.
- Body wrapped at 72 characters. The body says what and why, never how.
- A breaking change takes `!` after the type or scope, plus a `BREAKING CHANGE:` footer.
- **Never** add a `Co-authored-by` trailer, a `Generated with` line, or any other trailer.

## Limits

- Never push. Never create a branch. Never amend an existing commit.
- Never run `git reset --hard`, `git checkout .`, or `git clean`.
- Stop and report when the tree is clean, when a rebase or a merge is in progress, or when a conflict marker sits in a file.
- When a change holds a secret, an API key, or a `.env` value, stop before you stage it. Report the file and the line.
