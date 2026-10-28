---
description: Find every git repository on this Mac with unpushed commits, then push them after confirmation
argument-hint: "[optional root directory to scan; default: the standard project roots]"
allowed-tools: Bash(find:*), Bash(git status:*), Bash(git log:*), Bash(git branch:*), Bash(git remote:*), Bash(git rev-parse:*), Bash(git push:*), Bash(ls:*), Read
---

Find every git repository that holds commits the remote does not have. Report them. Push them after the user confirms.

Scan root from the user (may be empty): $ARGUMENTS

## Step 1 — find the repositories

When the user gives a root, scan that root only. Otherwise scan these:

```
~/01-projects
~/02-areas
~/03-resources
~/04-archive
~/.local/share/chezmoi
```

Use this command for each root, and skip anything under `node_modules`:

```
find <root> -type d -name .git -not -path "*/node_modules/*" -maxdepth 6
```

## Step 2 — read the state of each repository

For each repository, collect:

- The current branch: `git -C <repo> rev-parse --abbrev-ref HEAD`
- The remote: `git -C <repo> remote -v`
- The unpushed commits: `git -C <repo> log --oneline @{u}.. 2>/dev/null`
- The uncommitted changes: `git -C <repo> status --short`

A repository with no remote, or with no upstream branch, is not an error. Report it under its own heading.

## Step 3 — report

Print one table:

| Repository | Branch | Unpushed | Uncommitted | Remote |
|---|---|---|---|---|

Then list, under separate headings:

- The repositories with no remote.
- The repositories with a branch that has no upstream.
- The repositories that hold uncommitted work.

## Step 4 — confirm, then push

Push moves code to a server other people can read, so it needs an explicit answer.

Ask one question: which repositories to push. Wait for the answer.

After the user answers, push each named repository with `git -C <repo> push`. When a branch has no upstream, use `git -C <repo> push -u origin <branch>`, and say so first.

Report the result of each push, one line for each repository.

## Limits

- Never use `--force`, `--force-with-lease`, or `--delete`.
- Never push a branch the user did not name.
- Never commit, never stage, never stash. Report uncommitted work and leave it alone. Tell the user that `/atomic-commit` handles it.
- When a push fails, report the exact error and continue with the next repository. Do not retry with a different flag.
