#!/usr/bin/env bash
# Exercise 4 setup: a branch that is BEHIND main by N commits and AHEAD by M commits.
#
#   main:        ... B ── m1 ── m2 ── ... ── m{BEHIND}
#                     \
#   ex4/feature:       f1 ── f2 ── ... ── f{AHEAD}
#
# The two sides touch different files, so `git rebase main` replays cleanly.
# Safe to re-run: it resets the exercise-4 files and force-pushes the branch.
#
# Env vars:
#   BEHIND       commits added to main after the branch point (default: 10)
#   AHEAD        commits on the feature branch (default: 9)
#   BASE_BRANCH  default: main
#   REMOTE       default: origin
set -euo pipefail

BEHIND="${BEHIND:-10}"
AHEAD="${AHEAD:-9}"
BASE_BRANCH="${BASE_BRANCH:-main}"
REMOTE="${REMOTE:-origin}"
BRANCH="ex4/feature"

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

git config user.name  "${GIT_AUTHOR_NAME:-github-actions[bot]}"
git config user.email "${GIT_AUTHOR_EMAIL:-41898282+github-actions[bot]@users.noreply.github.com}"

git fetch "$REMOTE" --prune
git checkout -B "$BASE_BRANCH" "$REMOTE/$BASE_BRANCH"

# Branch point: reset both exercise-4 files.
mkdir -p exercise-4
printf '# Release notes (main)\n\nCommits added to `main` while you were working:\n\n' > exercise-4/main-changelog.md
printf '# Feature notes (ex4/feature)\n\nYour work on the feature branch:\n\n' > exercise-4/feature-notes.md
git add exercise-4
git diff --cached --quiet || git commit -m "Exercise 4 setup: branch point"
git push "$REMOTE" "$BASE_BRANCH"
BASE_SHA="$(git rev-parse HEAD)"

# Feature branch: AHEAD commits
git checkout -B "$BRANCH" "$BASE_SHA"
for i in $(seq 1 "$AHEAD"); do
  echo "- Feature step $i of $AHEAD" >> exercise-4/feature-notes.md
  git commit -qam "feature: step $i of $AHEAD"
done
git push --force "$REMOTE" "$BRANCH"

# Main moves on: BEHIND commits
git checkout "$BASE_BRANCH"
for i in $(seq 1 "$BEHIND"); do
  echo "- Main update $i of $BEHIND" >> exercise-4/main-changelog.md
  git commit -qam "main: update $i of $BEHIND"
done
git push "$REMOTE" "$BASE_BRANCH"

read -r behind ahead < <(git rev-list --left-right --count "$BASE_BRANCH...$BRANCH")
echo "$BRANCH is $behind commit(s) behind and $ahead commit(s) ahead of $BASE_BRANCH."
