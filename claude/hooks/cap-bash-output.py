#!/usr/bin/env python3
"""PreToolUse hook for Bash: keep long test, build and lint output short.

Test runners and builds can print thousands of lines into the context.
This hook writes the full output to a temp file and shows only the last
200 lines, with the log path, so Claude can grep the log when it needs
more. The exit code of the command stays the same.

It does not set a permission decision, so the normal permission flow
runs on the changed command. Add `# full-output` to a command to skip it.
"""
import json
import re
import sys

MAX_LINES = 200

NOISY = re.compile(
    r"(^|[\s;&(])("
    r"(npm|pnpm|yarn|bun)\s+(run\s+)?(test|build|lint|check|typecheck)"
    r"|npx\s+(jest|vitest|tsc|eslint|playwright)"
    r"|(\./)?mvnw?\s|(\./)?gradlew?\s"
    r"|cargo\s+(test|build|clippy|check)"
    r"|(uv\s+run\s+)?pytest"
    r"|go\s+(test|build|vet)"
    r"|make(\s|$)|tsc(\s|$)"
    r"|docker(\s+compose)?\s+(logs|build)"
    r")"
)
# Redirects that only merge or drop streams do not count as a file write.
HARMLESS = re.compile(r"\d?>&\d|\d?>\s*/dev/null")
# The command already limits its own output, or it needs the raw stream.
SKIP = re.compile(r"\|\s*(tail|head|grep|rg|wc|less)\b|\btee\b|>|<<|# full-output")


def wrap(command: str) -> str:
    # `}` goes on its own line, so a trailing comment cannot hide it.
    return (
        "__cap_log=$(mktemp -t claude-out); { " + command + "\n"
        '} >"$__cap_log" 2>&1; __cap_rc=$?; '
        '__cap_n=$(wc -l <"$__cap_log" | tr -d " "); '
        f'if [ "$__cap_n" -gt {MAX_LINES} ]; then '
        f'echo "[cap-bash-output] last {MAX_LINES} of $__cap_n lines. Full log: $__cap_log"; fi; '
        f'tail -n {MAX_LINES} "$__cap_log"; (exit $__cap_rc)'
    )


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    tool_input = data.get("tool_input") or {}
    command = tool_input.get("command", "")
    if (
        not command
        or tool_input.get("run_in_background")
        or "__cap_log" in command
        or SKIP.search(HARMLESS.sub("", command))
        or not NOISY.search(command)
    ):
        sys.exit(0)

    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "updatedInput": {**tool_input, "command": wrap(command)},
        }
    }))


if __name__ == "__main__":
    main()
