#!/usr/bin/env python3
"""SessionEnd hook: update today's work journal in docs/journal/.

Runs only in a git repo that has docs/journal/ (journal-offer.py creates
it). It collects today's commits and the uncommitted changes, then asks
Haiku through `claude -p` to merge them into docs/journal/YYYY-MM-DD.md.
The summary runs in a detached process, so the session closes at once.
The file is not committed: review it and commit it with your work.
"""
import datetime
import json
import os
import subprocess
import sys
from pathlib import Path

PROMPT = """You keep a daily work journal for a software repo.
Below is the current journal file for {day} (it can be empty) and the
git activity of today. Return the full updated journal file in Markdown,
and nothing else.

Rules:
- Title: "# Journal {day}".
- Sections: "## Done" (the important changes, one bullet each, with the
  commit hash when there is one), "## In progress" (uncommitted work),
  "## Decisions and notes" (only when the commits show a decision).
- Keep every existing bullet. Merge duplicates. Skip trivial changes.
- English, short sentences, no marketing words.

=== CURRENT JOURNAL ===
{current}

=== TODAY'S COMMITS ===
{commits}

=== UNCOMMITTED CHANGES ===
{changes}
"""


def git(root: str, *args: str) -> str:
    return subprocess.run(
        ["git", "-C", root, *args], capture_output=True, text=True
    ).stdout.strip()


def summarize(root: str) -> None:
    day = datetime.date.today().isoformat()
    commits = git(root, "log", "--since=midnight", "--no-merges",
                  "--stat", "--format=%n%h %s%n%b")
    changes = git(root, "status", "--short") + "\n" + git(root, "diff", "HEAD", "--stat")
    if not commits and not changes.strip():
        return

    journal = Path(root) / "docs/journal" / f"{day}.md"
    current = journal.read_text() if journal.exists() else ""
    prompt = PROMPT.format(day=day, current=current,
                           commits=commits[:20000], changes=changes[:5000])
    result = subprocess.run(
        ["claude", "-p", "--model", "haiku", "--tools", "",
         "--no-session-persistence", "--strict-mcp-config"],
        input=prompt, capture_output=True, text=True, timeout=180,
        env={**os.environ, "CLAUDE_JOURNAL_CHILD": "1"},
    )
    text = result.stdout.strip()
    if result.returncode == 0 and text.startswith("# Journal"):
        journal.write_text(text + "\n")


def main() -> None:
    if os.environ.get("CLAUDE_JOURNAL_CHILD"):
        sys.exit(0)
    if len(sys.argv) > 2 and sys.argv[1] == "--run":
        summarize(sys.argv[2])
        return
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    cwd = data.get("cwd") or os.getcwd()
    root = git(cwd, "rev-parse", "--show-toplevel")
    if not root or not (Path(root) / "docs/journal").is_dir():
        sys.exit(0)
    subprocess.Popen(
        [sys.executable, __file__, "--run", root],
        start_new_session=True,
        stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )


if __name__ == "__main__":
    main()
