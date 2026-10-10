#!/usr/bin/env bash
# Check that a branch was REBASED onto main (not merged, not left behind).
#
# Usage: check_rebase.sh <base-ref> <head-ref> [min-commits]
#   e.g. check_rebase.sh origin/main HEAD 9
set -uo pipefail

BASE="${1:?base ref}"
HEAD="${2:?head ref}"
MIN="${3:-1}"
fail=0

if git merge-base --is-ancestor "$BASE" "$HEAD"; then
  echo "OK: branch contains every commit from $BASE (0 behind)."
else
  behind="$(git rev-list --count "$HEAD..$BASE")"
  echo "::error::Branch is $behind commit(s) behind $BASE. Run: git fetch origin && git rebase origin/main"
  fail=1
fi

merges="$(git rev-list --merges "$BASE..$HEAD")"
if [ -n "$merges" ]; then
  echo "::error::Found merge commit(s) on your branch: $(echo $merges | cut -c1-80). Rebase instead of merging (did you click 'Update branch'?)."
  fail=1
else
  echo "OK: no merge commits, history is linear."
fi

ahead="$(git rev-list --count "$BASE..$HEAD")"
if [ "$ahead" -lt "$MIN" ]; then
  echo "::error::Expected at least $MIN commit(s) ahead of $BASE, found $ahead. Did some commits get lost?"
  fail=1
else
  echo "OK: $ahead commit(s) ahead of $BASE."
fi

exit $fail
