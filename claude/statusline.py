#!/usr/bin/env python3
"""Claude Code statusline.

Reads the session JSON payload on stdin. Shows:

    ~/dir | branch* | model | ctx 63% (125k) | 5h 72% | 7d 11%

- ctx  context window used by this session, read from the transcript.
- 5h   five-hour limit used, read from the cache in ~/.claude.json.
- 7d   seven-day limit used, from the same cache.

The limit numbers come from a cache that Claude Code refreshes. When the cache
is more than 15 minutes old, the number carries a "~" and turns dim.
"""
import json
import os
import subprocess
import sys
import time

HOME = os.path.expanduser("~")
CONFIG = os.path.join(HOME, ".claude.json")
STALE_AFTER_S = 15 * 60

DIM = "\033[2m"
CYAN = "\033[36m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RED = "\033[31m"
OFF = "\033[0m"


def color_for(pct):
    if pct is None:
        return DIM
    if pct >= 85:
        return RED
    if pct >= 60:
        return YELLOW
    return GREEN


def read_payload():
    try:
        return json.load(sys.stdin)
    except Exception:
        return {}


def git_branch(path):
    def run(args):
        try:
            out = subprocess.run(
                ["git", "-C", path] + args,
                capture_output=True, text=True, timeout=1,
            )
        except Exception:
            return None
        if out.returncode != 0:
            return None
        return out.stdout.strip()

    if run(["rev-parse", "--is-inside-work-tree"]) != "true":
        return None
    name = run(["branch", "--show-current"]) or run(["rev-parse", "--short", "HEAD"])
    if not name:
        return None
    if run(["status", "--porcelain"]):
        name += "*"
    return name


def context_window(model_name, model_id):
    """Return the context size in tokens for this model."""
    text = "{} {}".format(model_name or "", model_id or "").lower()
    if "1m" in text:
        return 1_000_000
    return 200_000


def context_used(transcript_path):
    """Total tokens held in the context, from the last assistant message."""
    if not transcript_path or not os.path.isfile(transcript_path):
        return None
    last = None
    try:
        with open(transcript_path, errors="ignore") as fh:
            for line in fh:
                if '"usage"' not in line:
                    continue
                try:
                    row = json.loads(line)
                except Exception:
                    continue
                msg = row.get("message")
                if not isinstance(msg, dict):
                    continue
                usage = msg.get("usage")
                if isinstance(usage, dict) and usage.get("output_tokens") is not None:
                    last = usage
    except Exception:
        return None
    if not last:
        return None
    return (
        (last.get("input_tokens") or 0)
        + (last.get("cache_creation_input_tokens") or 0)
        + (last.get("cache_read_input_tokens") or 0)
    )


def limits():
    """Return (five_hour_pct, seven_day_pct, stale) from the cached utilization."""
    try:
        with open(CONFIG) as fh:
            cached = json.load(fh).get("cachedUsageUtilization") or {}
    except Exception:
        return None, None, False
    util = cached.get("utilization") or {}
    age = time.time() - (cached.get("fetchedAtMs") or 0) / 1000.0

    def pct(key):
        block = util.get(key) or {}
        value = block.get("utilization")
        return int(value) if isinstance(value, (int, float)) else None

    return pct("five_hour"), pct("seven_day"), age > STALE_AFTER_S


def main():
    payload = read_payload()
    workspace = payload.get("workspace") or {}
    model = payload.get("model") or {}

    directory = workspace.get("current_dir") or payload.get("cwd") or os.getcwd()
    shown_dir = directory.replace(HOME, "~", 1) if directory.startswith(HOME) else directory

    parts = ["{}{}{}".format(CYAN, shown_dir, OFF)]

    branch = git_branch(directory)
    if branch:
        parts.append("{}{}{}".format(GREEN, branch, OFF))

    parts.append("{}{}{}".format(YELLOW, model.get("display_name") or "?", OFF))

    used = context_used(payload.get("transcript_path"))
    if used is not None:
        window = context_window(model.get("display_name"), model.get("id"))
        pct = int(round(used * 100.0 / window))
        parts.append("{}ctx {}% ({}k){}".format(color_for(pct), pct, used // 1000, OFF))
    elif payload.get("exceeds_200k_tokens") is True:
        parts.append("{}ctx >200k{}".format(RED, OFF))

    five, seven, stale = limits()
    mark = "~" if stale else ""
    if five is not None:
        style = DIM if stale else color_for(five)
        parts.append("{}5h {}{}%{}".format(style, mark, five, OFF))
    if seven is not None:
        style = DIM if stale else color_for(seven)
        parts.append("{}7d {}{}%{}".format(style, mark, seven, OFF))

    sys.stdout.write(" {}|{} ".format(DIM, OFF).join(parts))


if __name__ == "__main__":
    main()
