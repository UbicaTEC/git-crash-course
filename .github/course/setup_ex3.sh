#!/usr/bin/env bash
# Exercise 3 setup: create a Pull Request with 4 merge conflicts in one Markdown file.
#
#   1. Reset exercise-3/hackathon-plan.md on main to the base version.
#   2. Branch "ex3/teammate-alex" edits 4 places in the file and is merged into main
#      (this simulates a teammate who got their PR merged first).
#   3. Branch "ex3/your-changes" edits the SAME 4 places differently, starting from the
#      old base, so its PR into main now has 4 conflicts.
#
# Safe to re-run: it resets the file and force-pushes the exercise branches.
#
# Env vars:
#   BASE_BRANCH  default branch to target (default: main)
#   REMOTE       git remote name (default: origin)
#   SKIP_PR=1    don't call the GitHub CLI (used by local verification)
set -euo pipefail

BASE_BRANCH="${BASE_BRANCH:-main}"
REMOTE="${REMOTE:-origin}"
TEAMMATE_BRANCH="ex3/teammate-alex"
YOUR_BRANCH="ex3/your-changes"
FILE="exercise-3/hackathon-plan.md"

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

# Copy the source versions somewhere safe before we start switching branches.
SRC="$(mktemp -d)"
cp .github/course/ex3/base.md .github/course/ex3/teammate.md .github/course/ex3/yours.md "$SRC/"

git config user.name  "${GIT_AUTHOR_NAME:-github-actions[bot]}"
git config user.email "${GIT_AUTHOR_EMAIL:-41898282+github-actions[bot]@users.noreply.github.com}"

git fetch "$REMOTE" --prune
git checkout -B "$BASE_BRANCH" "$REMOTE/$BASE_BRANCH"

# 1. Base version on main
mkdir -p exercise-3
cp "$SRC/base.md" "$FILE"
git add "$FILE"
git diff --cached --quiet || git commit -m "Exercise 3 setup: add hackathon plan"
git push "$REMOTE" "$BASE_BRANCH"
BASE_SHA="$(git rev-parse HEAD)"

# 2. Teammate branch, merged into main right away
git checkout -B "$TEAMMATE_BRANCH" "$BASE_SHA"
cp "$SRC/teammate.md" "$FILE"
git commit -am "Plan: add Git workshop, team rooms, snack budget, food ordered"

# 3. Your branch, from the same (old) base
git checkout -B "$YOUR_BRANCH" "$BASE_SHA"
cp "$SRC/yours.md" "$FILE"
git commit -am "Plan: add hacking slot, Rebasers team, snack budget, food owner"
git push --force "$REMOTE" "$YOUR_BRANCH"

git checkout "$BASE_BRANCH"
git merge --no-ff "$TEAMMATE_BRANCH" -m "Merge branch '$TEAMMATE_BRANCH' (Alex's plan updates)"
git push "$REMOTE" "$BASE_BRANCH"
git branch -D "$TEAMMATE_BRANCH"

if [ "${SKIP_PR:-0}" = "1" ]; then
  echo "SKIP_PR=1: not opening a Pull Request."
  exit 0
fi

EXISTING="$(gh pr list --head "$YOUR_BRANCH" --base "$BASE_BRANCH" --state open --json number --jq '.[0].number')"
if [ -n "$EXISTING" ]; then
  echo "PR #$EXISTING already open; its branch was reset, so it has fresh conflicts."
else
  gh pr create \
    --base "$BASE_BRANCH" \
    --head "$YOUR_BRANCH" \
    --title "Exercise 3: update the hackathon plan (resolve the conflicts!)" \
    --body "$(cat <<'BODY'
Your teammate **Alex** changed `exercise-3/hackathon-plan.md` and their work was merged into `main` first.
This branch changed the **same lines**, so this PR has **4 merge conflicts**.

Follow **Exercise 3** in the README:

1. Resolve all 4 conflicts so that **every table still renders**.
2. Keep the work of **both** people (rows, columns and edits).
3. Push your fix. The **Check tables** check must turn green.
4. Merge this PR into `main`.
BODY
)"
fi
