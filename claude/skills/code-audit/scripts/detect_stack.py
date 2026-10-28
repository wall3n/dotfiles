#!/usr/bin/env python3
"""Detect the languages, build files, lint configs, and linters for a repo.

Usage: detect_stack.py [target-dir]
Prints one JSON object to stdout. Reads files only. Changes nothing.
"""

import json
import os
import shutil
import subprocess
import sys
from collections import Counter

SKIP_DIRS = {
    ".git", "node_modules", "dist", "build", "target", "out", ".venv", "venv",
    "__pycache__", ".next", ".nuxt", "vendor", ".gradle", ".idea", ".settings",
    "coverage", ".mypy_cache", ".ruff_cache", ".pytest_cache", ".tox",
}

EXT_LANG = {
    ".java": "java", ".kt": "kotlin", ".kts": "kotlin", ".scala": "scala",
    ".ts": "typescript", ".tsx": "typescript", ".js": "javascript",
    ".jsx": "javascript", ".mjs": "javascript", ".cjs": "javascript",
    ".vue": "vue", ".svelte": "svelte",
    ".py": "python", ".go": "go", ".rs": "rust", ".rb": "ruby", ".php": "php",
    ".cs": "csharp", ".swift": "swift", ".c": "c", ".h": "c", ".cpp": "cpp",
    ".cc": "cpp", ".hpp": "cpp", ".sh": "shell", ".bash": "shell",
    ".sql": "sql", ".tf": "terraform",
}

BUILD_FILES = {
    "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle",
    "package.json", "pnpm-lock.yaml", "yarn.lock", "package-lock.json",
    "bun.lockb", "tsconfig.json", "pyproject.toml", "requirements.txt",
    "setup.py", "Pipfile", "poetry.lock", "uv.lock", "go.mod", "Cargo.toml",
    "Gemfile", "composer.json", "Dockerfile", "docker-compose.yml",
    "compose.yaml", "Makefile", ".nvmrc", ".node-version", ".tool-versions",
    "mise.toml", ".python-version",
}

LINT_CONFIG_PREFIXES = (
    ".eslintrc", "eslint.config.", ".prettierrc", "biome.json", "ruff.toml",
    ".ruff.toml", ".flake8", "setup.cfg", "mypy.ini", ".pylintrc", "tox.ini",
    "checkstyle", "pmd", "spotbugs", ".golangci", "clippy.toml", ".rubocop",
    ".shellcheckrc", ".semgrep", ".gitleaks", ".hadolint", "phpstan",
    "detekt", ".editorconfig", "sonar-project.properties",
)

TOOLS = [
    "git", "java", "mvn", "gradle", "node", "npm", "npx", "pnpm", "yarn",
    "bun", "python3", "uv", "uvx", "pipx", "go", "golangci-lint", "cargo",
    "ruby", "rubocop", "php", "dotnet", "docker", "gitleaks", "semgrep",
    "trivy", "osv-scanner", "shellcheck", "hadolint", "ruff", "eslint",
]


def walk(root):
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for name in filenames:
            yield dirpath, name


def git_info(root):
    def run(*args):
        try:
            out = subprocess.run(
                ["git", "-C", root, *args], capture_output=True, text=True,
                timeout=10,
            )
            return out.stdout.strip() if out.returncode == 0 else None
        except (OSError, subprocess.TimeoutExpired):
            return None

    status = run("status", "--porcelain")
    return {
        "commit": run("rev-parse", "--short", "HEAD"),
        "branch": run("rev-parse", "--abbrev-ref", "HEAD"),
        "uncommitted_files": len(status.splitlines()) if status else 0,
    }


def main():
    root = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else ".")
    langs = Counter()
    build_files, lint_configs = [], []

    for dirpath, name in walk(root):
        rel = os.path.relpath(os.path.join(dirpath, name), root)
        ext = os.path.splitext(name)[1].lower()
        if ext in EXT_LANG and not name.endswith(".min.js"):
            langs[EXT_LANG[ext]] += 1
        if name in BUILD_FILES:
            build_files.append(rel)
        if name.startswith(LINT_CONFIG_PREFIXES) or name.lower().startswith(
            LINT_CONFIG_PREFIXES
        ):
            lint_configs.append(rel)

    print(json.dumps({
        "root": root,
        "git": git_info(root) if shutil.which("git") else None,
        "languages": dict(langs.most_common()),
        "build_files": sorted(build_files),
        "lint_configs": sorted(lint_configs),
        "tools_on_path": {t: bool(shutil.which(t)) for t in TOOLS},
    }, indent=2))


if __name__ == "__main__":
    main()
