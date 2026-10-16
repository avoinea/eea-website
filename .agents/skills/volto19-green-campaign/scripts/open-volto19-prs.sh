#!/usr/bin/env bash
# Open `volto19 -> <base>` PRs for EEA add-ons; skips repos that already have a
# PR with head `volto19` (any state) and non-eea repos are not accepted at all.
#
# Usage:
#   scripts/open-volto19-prs.sh --dry-run volto-foo volto-bar
#   BODY="..." scripts/open-volto19-prs.sh volto-foo volto-bar
#
# Env: BASE (default develop), TITLE (default "chore: Volto 19 support"),
#      BODY (default short description).
set -uo pipefail

DRY=0
if [ "${1:-}" = "--dry-run" ]; then DRY=1; shift; fi
if [ $# -eq 0 ]; then echo "usage: $0 [--dry-run] <addon>..." >&2; exit 2; fi

BASE="${BASE:-develop}"
TITLE="${TITLE:-chore: Volto 19 support}"
BODY="${BODY:-Volto 19 support: CI/test configuration and dependency updates. The branch is green on both the Volto 18 and the Volto 19 Jenkins integrations.}"

rc=0
for name in "$@"; do
  repo="eea/$name"
  existing="$(gh pr list -R "$repo" --head volto19 --state all --json number,state \
    --jq '.[0] | if . then "\(.number) \(.state)" else empty end' 2>/dev/null)"
  if [ -n "$existing" ]; then
    echo "SKIP  $name  (PR $existing)"
    continue
  fi
  if [ "$DRY" = 1 ]; then
    echo "DRY   $name  volto19 -> $BASE"
    continue
  fi
  err="$(mktemp)"
  if url="$(gh pr create -R "$repo" --base "$BASE" --head volto19 --title "$TITLE" --body "$BODY" 2>"$err")"; then
    echo "OPEN  $name  $url"
  else
    echo "FAIL  $name  $(tr '\n' ' ' < "$err")"
    rc=1
  fi
  rm -f "$err"
done
exit $rc
