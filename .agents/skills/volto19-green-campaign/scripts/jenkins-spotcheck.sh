#!/usr/bin/env bash
# Snapshot GitHub check-runs per EEA add-on, on the latest origin/volto19 commit.
# Usage: jenkins-spotcheck.sh [output-file]
set -uo pipefail

PACKAGES="${PACKAGES:-$HOME/sandbox/eea-website-volto19/frontend/packages}"
OUT="${1:-/tmp/jenkins-spotcheck-$(date +%H%M%S).txt}"
: > "$OUT"

JQ='
  ([.check_runs[] | select(.status=="completed" and (.conclusion as $c | $c != "success" and $c != "neutral" and $c != "skipped"))]
    | map("\(.name) [\(.output.title)]") | join("; ")) as $failed
  | ([.check_runs[] | select(.status != "completed")] | map(.name) | join("; ")) as $pending
  | (.check_runs | length) as $n
  | if $n == 0 then "NO  |no checks yet"
    elif $failed != "" then "FAIL|\($failed)"
    elif $pending != "" then "RUN |pending: \($pending)"
    else "OK  |\($n) checks green" end
'

for d in "$PACKAGES"/*/; do
  name="$(basename "$d")"
  [ -d "$d/.git" ] || continue
  url="$(git -C "$d" remote get-url origin 2>/dev/null || true)"
  case "$url" in *collective/*) continue;; esac
  slug="$(echo "$url" | sed -E 's#(git@github.com:|https://github.com/)##; s#\.git$##')"
  sha="$(git -C "$d" ls-remote origin refs/heads/volto19 2>/dev/null | cut -f1)"
  if [ -z "$sha" ]; then
    echo "$name|NO  |no volto19 branch" >> "$OUT"
    continue
  fi
  state="$(gh api "repos/$slug/commits/$sha/check-runs?per_page=100" --jq "$JQ" 2>/dev/null)"
  echo "$name|${state:-FAIL|gh api error}" >> "$OUT"
done

echo "=== $OUT ==="
column -t -s'|' "$OUT" 2>/dev/null || cat "$OUT"
