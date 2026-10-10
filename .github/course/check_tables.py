#!/usr/bin/env python3
"""Validate Markdown tables (and catch leftover merge-conflict markers).

Usage:
    python .github/course/check_tables.py [--ex3] [FILE ...]

With no FILE arguments, every tracked *.md file in the repo is checked.
--ex3 additionally checks that exercise-3/hackathon-plan.md keeps the work of
BOTH teammates (the "did you resolve the conflict correctly?" check).

Exit code 0 = everything renders; 1 = problems found (printed as GitHub
Actions ::error annotations so they show up inline on the PR).
"""
import re
import subprocess
import sys
from pathlib import Path

CONFLICT_RE = re.compile(r"^(<{7}( |$)|={7}$|>{7}( |$)|\|{7}( |$))")
SEPARATOR_CELL_RE = re.compile(r"^:?-{3,}:?$")
EX3_FILE = "exercise-3/hackathon-plan.md"

errors = []


def error(path, line, msg):
    errors.append((path, line, msg))


def split_row(line):
    """Split '| a | b \\| c |' into ['a', 'b \\| c'] (escaped pipes stay)."""
    body = line.strip()
    if body.startswith("|"):
        body = body[1:]
    if body.endswith("|") and not body.endswith("\\|"):
        body = body[:-1]
    return [c.strip() for c in re.split(r"(?<!\\)\|", body)]


def find_tables(lines):
    """Yield (start_index, [lines]) for each block of lines starting with '|'."""
    i = 0
    while i < len(lines):
        if lines[i].lstrip().startswith("|"):
            start = i
            while i < len(lines) and lines[i].lstrip().startswith("|"):
                i += 1
            yield start, lines[start:i]
        else:
            i += 1


def blank_code_fences(lines):
    """Replace lines inside ``` fenced code blocks with '' so examples are ignored."""
    out, fence = [], None
    for line in lines:
        m = re.match(r"^\s*(`{3,}|~{3,})", line)
        if fence is None and m:
            fence = m.group(1)[0] * len(m.group(1))
            out.append("")
        elif fence is not None:
            if line.strip().startswith(fence):
                fence = None
            out.append("")
        else:
            out.append(line)
    return out


def check_file(path):
    text = Path(path).read_text(encoding="utf-8")
    lines = blank_code_fences(text.splitlines())
    tables = {}  # heading -> list of row cell lists (header first)
    heading = None

    for n, line in enumerate(lines, 1):
        if CONFLICT_RE.match(line):
            error(path, n, f"Leftover merge-conflict marker: '{line[:20]}'. "
                           "Delete the markers and keep the content you want.")

    for start, block in find_tables(lines):
        # Nearest heading above the table names it (used by the ex3 checks).
        heading = None
        for j in range(start - 1, -1, -1):
            if lines[j].startswith("#"):
                heading = lines[j].lstrip("#").strip()
                break
        lineno = start + 1
        if len(block) < 2:
            error(path, lineno, "A table needs a header row AND a separator row like |---|---|.")
            continue
        header = split_row(block[0])
        sep = split_row(block[1])
        if not all(SEPARATOR_CELL_RE.match(c) for c in sep):
            error(path, lineno + 1,
                  "Second row of a table must be the separator, e.g. | --- | :---: | ---: |")
        if len(sep) != len(header):
            error(path, lineno + 1,
                  f"Separator has {len(sep)} column(s) but the header has {len(header)}.")
        rows = [header]
        for k, raw in enumerate(block[2:], 2):
            stripped = raw.strip()
            if not stripped.endswith("|"):
                error(path, lineno + k, "Table row must end with a '|'.")
            cells = split_row(raw)
            if len(cells) != len(header):
                error(path, lineno + k,
                      f"Row has {len(cells)} cell(s) but the header has {len(header)}: {stripped}")
            rows.append(cells)
        if heading:
            tables[heading] = rows
    return tables


def check_ex3(tables):
    path = EX3_FILE

    def table(name):
        if name not in tables:
            error(path, 1, f"Could not find the '{name}' table. Did a heading get deleted?")
            return None
        return tables[name]

    def rows_where(t, first_cell):
        return [r for r in t[1:] if r and r[0] == first_cell]

    sched = table("Schedule")
    if sched:
        activities = [" | ".join(r) for r in sched[1:]]
        for want in ("Git workshop", "Hacking starts"):
            if not any(want in a for a in activities):
                error(path, 1, f"Schedule lost the '{want}' row. Both teammates' rows must be kept.")
        times = [r[0] for r in sched[1:] if r]
        dupes = sorted({t for t in times if times.count(t) > 1})
        if dupes:
            error(path, 1, f"Schedule has duplicate row(s) for {', '.join(dupes)}. "
                           "'Accept Both' can copy a line twice; keep only one.")
        elif times != sorted(times):
            error(path, 1, f"Schedule rows should be in time order, got: {', '.join(times)}")

    teams = table("Teams")
    if teams:
        if "Room" not in teams[0]:
            error(path, 1, "Teams table lost the 'Room' column added by Alex.")
        if not rows_where(teams, "Rebasers"):
            error(path, 1, "Teams table lost the 'Rebasers' row you added.")

    budget = table("Budget")
    if budget:
        snacks = rows_where(budget, "Snacks")
        if len(snacks) != 1:
            error(path, 1, f"Budget should have exactly one 'Snacks' row, found {len(snacks)}.")
        elif snacks[0][-1] not in ("100", "150"):
            error(path, 1, "Snacks cost should be one of the two proposed values (100 or 150).")

    tasks = table("Tasks")
    if tasks:
        food = rows_where(tasks, "Order food")
        if len(food) != 1:
            error(path, 1, f"Tasks should have exactly one 'Order food' row, found {len(food)}.")
        elif food[0][1:] != ["Marta", "Done"]:
            error(path, 1, "'Order food' must combine BOTH edits: owner Marta (yours) "
                           "and status Done (Alex's).")


def main(argv):
    ex3 = "--ex3" in argv
    files = [a for a in argv if not a.startswith("--")]
    if not files:
        out = subprocess.run(["git", "ls-files", "*.md"], capture_output=True, text=True, check=True)
        files = [f for f in out.stdout.splitlines() if f]

    all_tables = {}
    for f in files:
        all_tables[f] = check_file(f)

    if ex3:
        if Path(EX3_FILE).exists():
            check_ex3(all_tables.get(EX3_FILE) or check_file(EX3_FILE))
        else:
            error(EX3_FILE, 1, "File is missing. Did you delete it while resolving the conflict?")

    for path, line, msg in errors:
        print(f"::error file={path},line={line}::{msg}")
    if errors:
        print(f"\n{len(errors)} problem(s) found.")
        return 1
    print(f"All tables in {len(files)} file(s) look good.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
