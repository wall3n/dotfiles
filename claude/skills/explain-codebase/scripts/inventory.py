#!/usr/bin/env python3
"""Print a compact inventory of a codebase so the reader knows what to open first.

Usage: python3 inventory.py <target-dir>

Uses `git ls-files` when the target is inside a git work tree (respects
.gitignore), and falls back to a filtered directory walk otherwise.
Standard library only.
"""
import collections
import os
import re
import subprocess
import sys

SKIP_DIRS = {
    ".git", "node_modules", "dist", "build", "target", "out", ".next", ".nuxt",
    "vendor", "__pycache__", ".venv", "venv", ".tox", ".gradle", ".idea",
    ".vscode", "coverage", ".turbo", ".cache", "Pods", "DerivedData",
}

MANIFESTS = {
    "package.json", "pnpm-workspace.yaml", "tsconfig.json", "vite.config.ts",
    "vite.config.js", "next.config.js", "next.config.mjs", "angular.json",
    "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle",
    "settings.gradle.kts", "pyproject.toml", "setup.py", "requirements.txt",
    "Pipfile", "go.mod", "Cargo.toml", "Gemfile", "composer.json",
    "mix.exs", "pubspec.yaml", "Package.swift", "Dockerfile",
    "docker-compose.yml", "docker-compose.yaml", "compose.yaml", "Makefile",
    "serverless.yml", "application.properties", "application.yml",
    "application.yaml", ".env.example", "openapi.yaml", "openapi.json",
}

DOC_NAMES = re.compile(r"^(readme|contributing|architecture|adr|ticket|changelog|design)", re.I)

SOURCE_EXT = {
    ".java", ".kt", ".scala", ".py", ".ts", ".tsx", ".js", ".jsx", ".mjs",
    ".go", ".rs", ".rb", ".php", ".cs", ".swift", ".m", ".c", ".cc", ".cpp",
    ".h", ".hpp", ".ex", ".exs", ".dart", ".vue", ".svelte", ".sql",
    ".graphql", ".proto",
}

ENTRY_HINT = re.compile(
    r"(main|app|application|index|server|cli|__main__|routes?|router|"
    r"controller|handler|endpoint|api|resource|service|usecase|use_case|"
    r"repository|model|entity|schema|migration|seed|data)\b",
    re.I,
)

TEST_HINT = re.compile(r"(^|/)(tests?|__tests__|spec)(/|$)|(_test|\.test|\.spec|Test)\.\w+$")


def list_files(root):
    try:
        out = subprocess.run(
            ["git", "-C", root, "ls-files", "--cached", "--others", "--exclude-standard"],
            capture_output=True, text=True, check=True,
        ).stdout
        files = [f for f in out.splitlines() if f]
        if files:
            return files, "git ls-files"
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass
    files = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and not d.startswith(".")]
        for name in filenames:
            files.append(os.path.relpath(os.path.join(dirpath, name), root))
    return files, "directory walk"


def count_lines(path):
    try:
        with open(path, "rb") as fh:
            return sum(1 for _ in fh)
    except OSError:
        return 0


def main():
    root = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else ".")
    if not os.path.isdir(root):
        sys.exit(f"Not a directory: {root}")

    files, method = list_files(root)
    files = [f for f in files if not any(part in SKIP_DIRS for part in f.split("/"))]

    by_ext = collections.Counter()
    loc_by_ext = collections.Counter()
    by_top = collections.Counter()
    manifests, docs, entries, tests = [], [], [], []
    source_total = 0

    for rel in sorted(files):
        name = os.path.basename(rel)
        ext = os.path.splitext(name)[1].lower()
        top = rel.split("/")[0] if "/" in rel else "(root)"
        by_top[top] += 1
        if name in MANIFESTS:
            manifests.append(rel)
        if DOC_NAMES.match(name) and ext in {".md", ".rst", ".txt", ""}:
            docs.append(rel)
        if ext in SOURCE_EXT:
            source_total += 1
            by_ext[ext] += 1
            loc_by_ext[ext] += count_lines(os.path.join(root, rel))
            if TEST_HINT.search(rel):
                tests.append(rel)
            elif ENTRY_HINT.search(os.path.splitext(name)[0]):
                entries.append(rel)

    total_loc = sum(loc_by_ext.values())
    if source_total <= 80:
        size = "SMALL: read every source file yourself"
    elif source_total <= 300:
        size = "MEDIUM: read entry points and core modules, skim the rest"
    else:
        size = "LARGE: split by top-level module and use Explore agents"

    print(f"# Inventory of {root}")
    print(f"Listed with: {method}")
    print(f"Files: {len(files)}  Source files: {source_total}  Source lines: {total_loc}")
    print(f"Size class: {size}\n")

    print("## Source files by language")
    for ext, n in by_ext.most_common():
        print(f"  {ext:10} {n:6} files {loc_by_ext[ext]:8} lines")

    print("\n## Files by top-level directory")
    for top, n in by_top.most_common():
        print(f"  {top:40} {n}")

    for title, items, cap in (
        ("Manifests and config (read first)", manifests, 60),
        ("Docs and tickets (read first)", docs, 40),
        ("Likely entry points and core files", entries, 120),
        ("Tests (they show intended behaviour)", tests, 60),
    ):
        print(f"\n## {title}: {len(items)}")
        for item in items[:cap]:
            print(f"  {item}")
        if len(items) > cap:
            print(f"  ... {len(items) - cap} more")


if __name__ == "__main__":
    main()
