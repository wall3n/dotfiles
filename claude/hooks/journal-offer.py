#!/usr/bin/env python3
"""SessionStart hook: offer a work journal in a git repo that has none.

The journal hook (journal-write.py) runs only in repos with docs/journal/.
In a repo without that folder, this hook tells Claude to ask the user
once. A "no" goes into an opt-out list, so the question does not repeat.
"""
import json
import os
import subprocess
import sys
from pathlib import Path

OPTOUT = Path.home() / ".local/state/claude/journal-optout.txt"


def main() -> None:
    if os.environ.get("CLAUDE_JOURNAL_CHILD"):
        sys.exit(0)
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    cwd = data.get("cwd") or os.getcwd()
    root = subprocess.run(
        ["git", "-C", cwd, "rev-parse", "--show-toplevel"],
        capture_output=True, text=True,
    ).stdout.strip()
    if not root or (Path(root) / "docs/journal").is_dir():
        sys.exit(0)
    if OPTOUT.exists() and root in OPTOUT.read_text().splitlines():
        sys.exit(0)

    context = (
        f"This git repo ({root}) has no work journal. Before you do the "
        "user's first request, ask one short question: should Claude create "
        "docs/journal/ to keep a daily journal of the important changes? "
        f"If yes: run `mkdir -p {root}/docs/journal && touch "
        f"{root}/docs/journal/.gitkeep`. If no: run `mkdir -p {OPTOUT.parent} "
        f"&& echo '{root}' >> {OPTOUT}`. Ask only once, then do the request."
    )
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": context,
        }
    }))


if __name__ == "__main__":
    main()
