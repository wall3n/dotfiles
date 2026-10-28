#!/usr/bin/env python3
"""PreToolUse hook for Edit|Write|MultiEdit: ask before a lint config changes.

Claude sometimes weakens a linter or formatter rule to make a check pass.
This hook asks the user before an existing config file changes. A new
config file is allowed. Idea from ECC scripts/hooks/config-protection.js.
"""
import json
import os
import re
import sys

PROTECTED_NAMES = {
    # JS / TS
    ".eslintrc", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json",
    ".eslintrc.yml", ".eslintrc.yaml", ".prettierrc", ".prettierrc.json",
    ".prettierrc.yml", ".prettierrc.yaml", ".prettierrc.js", ".prettierrc.cjs",
    ".prettierrc.mjs", ".prettierrc.toml", "biome.json", "biome.jsonc",
    ".stylelintrc", ".stylelintrc.json", ".markdownlint.json",
    ".markdownlint.jsonc", ".markdownlint.yaml",
    # Python
    "ruff.toml", ".ruff.toml", ".flake8", ".pylintrc", "pylintrc", "mypy.ini",
    ".mypy.ini",
    # Rust
    "rustfmt.toml", ".rustfmt.toml", "clippy.toml", ".clippy.toml",
    # Java
    "checkstyle.xml", "spotbugs-exclude.xml", "pmd.xml",
    # Git hooks and commit lint
    ".pre-commit-config.yaml", ".commitlintrc", ".commitlintrc.json",
    ".commitlintrc.yml", ".lintstagedrc", ".lintstagedrc.json",
}
PROTECTED_PATTERNS = [
    re.compile(r"^eslint\.config\.(js|cjs|mjs|ts)$"),
    re.compile(r"^prettier\.config\.(js|cjs|mjs|ts)$"),
    re.compile(r"^commitlint\.config\.(js|cjs|mjs|ts)$"),
    re.compile(r"^stylelint\.config\.(js|cjs|mjs)$"),
]


def is_protected(name: str) -> bool:
    return name in PROTECTED_NAMES or any(p.match(name) for p in PROTECTED_PATTERNS)


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)
    path = (data.get("tool_input") or {}).get("file_path") or ""
    name = os.path.basename(path)
    if not path or not is_protected(name) or not os.path.exists(path):
        sys.exit(0)
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "ask",
            "permissionDecisionReason": (
                f"{name} is a linter or formatter config. Fix the code, not the "
                "rule. Approve only if you asked for this config change."
            ),
        }
    }))
    sys.exit(0)


if __name__ == "__main__":
    main()
