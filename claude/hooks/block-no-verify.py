#!/usr/bin/env python3
"""PreToolUse hook for Bash: stop git commands that skip git hooks.

Blocks --no-verify (and `git commit -n`) on commit, push, merge,
cherry-pick, rebase and am, and any `-c core.hooksPath=` override.
Idea from ECC scripts/hooks/block-no-verify.js.
"""
import json
import re
import sys

HOOK_SUBCOMMANDS = r"(commit|push|merge|cherry-pick|rebase|am)"


def deny(reason: str) -> None:
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }
    }))
    sys.exit(0)


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)
    command = (data.get("tool_input") or {}).get("command") or ""

    # Check each simple command on its own, split on ; && || | and newlines.
    for segment in re.split(r"&&|\|\||[;|\n]", command):
        if not re.search(r"(^|[\s/])git\s", segment):
            continue
        if re.search(r"core\.hookspath\s*=", segment, re.IGNORECASE):
            deny("Do not override core.hooksPath. Fix the failing git hook instead.")
        if not re.search(rf"\s{HOOK_SUBCOMMANDS}(\s|$)", segment):
            continue
        if re.search(r"\s--no-verify(\s|$)", segment):
            deny("Do not skip git hooks with --no-verify. Fix what the hook reports.")
        if re.search(r"\scommit\s", segment) and re.search(r"\s-[a-zA-Z]*n[a-zA-Z]*(\s|$)", segment):
            deny("`git commit -n` skips git hooks. Fix what the hook reports.")
    sys.exit(0)


if __name__ == "__main__":
    main()
