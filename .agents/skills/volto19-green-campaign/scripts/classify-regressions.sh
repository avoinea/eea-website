#!/usr/bin/env bash
# Classify failing GitHub checks per EEA add-on: current volto19 head vs the
# most recent previous push on the branch that has check-runs.
#
# NOTE: the baseline is found by walking the LOCAL origin/volto19 history, so
# run `git fetch` first; the current HEAD is taken from `git ls-remote` (Jenkins
# may push "style: Automated code fix" commits).
#
# Usage: classify-regressions.sh [output-file]
set -uo pipefail

PACKAGES="${PACKAGES:-$HOME/sandbox/eea-website-volto19/frontend/packages}"
OUT="${1:-/tmp/regression-report.txt}"
: > "$OUT"

NAMES='[.check_runs[] | select(.status=="completed" and (.conclusion as $c | $c != "success" and $c != "neutral" and $c != "skipped")) | .name] | .[]'

for d in "$PACKAGES"/*/; do
  name="$(basename "$d")"
  [ -d "$d/.git" ] || continue
  url="$(git -C "$d" remote get-url origin 2>/dev/null || true)"
  case "$url" in *collective/*) continue;; esac
  slug="$(echo "$url" | sed -E 's#(git@github.com:|https://github.com/)##; s#\.git$##')"
  cur="$(git -C "$d" ls-remote origin refs/heads/volto19 2>/dev/null | cut -f1)"
  [ -n "$cur" ] || continue
  now="$(gh api "repos/$slug/commits/$cur/check-runs?per_page=100" --jq "$NAMES" 2>/dev/null | sort -u)"
  [ -n "$now" ] || continue
  base=""; basef=""
  while read -r sha; do
    [ -n "$sha" ] || continue
    [ "$sha" = "$cur" ] && continue
    n="$(gh api "repos/$slug/commits/$sha/check-runs?per_page=100" --jq '.check_runs | length' 2>/dev/null)"
    if [ "${n:-0}" -gt 0 ] 2>/dev/null; then
      base="$sha"
      basef="$(gh api "repos/$slug/commits/$sha/check-runs?per_page=100" --jq "$NAMES" 2>/dev/null | sort -u)"
      break
    fi
  done < <(git -C "$d" log --format='%H' origin/volto19 -8)
  newf="$(comm -23 <(echo "$now") <(echo "$basef") | paste -sd'; ' -)"
  stillf="$(comm -12 <(echo "$now") <(echo "$basef") | paste -sd'; ' -)"
  echo "$name|base=${base:0:7}|NEW: ${newf:-none}|STILL: ${stillf:-none}" >> "$OUT"
done

echo "=== $OUT ==="
cat "$OUT"
