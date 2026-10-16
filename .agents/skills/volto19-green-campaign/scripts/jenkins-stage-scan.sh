#!/usr/bin/env bash
# List the Jenkins stages that actually FAILED per repo.
#
# The per-stage GitHub checks can be a false "success" ("No test results found")
# while the stage's `sh` step failed; the aggregate `Jenkins` check's
# output.summary carries the real errors. This script parses that summary.
#
# Usage: jenkins-stage-scan.sh [repo ...]   (default: all repos in $PACKAGES)
set -uo pipefail

PACKAGES="${PACKAGES:-$HOME/sandbox/eea-website-volto19/frontend/packages}"

if [ "$#" -gt 0 ]; then
  repos="$*"
else
  repos="$(ls "$PACKAGES")"
fi

for r in $repos; do
  [ -d "$PACKAGES/$r/.git" ] || continue
  sha="$(git -C "$PACKAGES/$r" ls-remote origin refs/heads/volto19 2>/dev/null | cut -f1)"
  if [ -z "$sha" ]; then echo "$r|NO_REF"; continue; fi
  id="$(gh api "repos/eea/$r/commits/$sha/check-runs?per_page=100" \
        --jq '[.check_runs[] | select(.name=="Jenkins")][0].id' 2>/dev/null)"
  if [ -z "$id" ] || [ "$id" = "null" ]; then echo "$r|NO_JENKINS"; continue; fi
  gh api "repos/eea/$r/check-runs/$id" --jq '.output.summary' 2>/dev/null | python3 -c "
import sys, html, re
t = html.unescape(sys.stdin.read())
parts = re.split(r'^### \`(Testing / [^\`]+)\`', t, flags=re.M)
errs = [parts[i].replace('Testing / ', '').strip()
        for i in range(1, len(parts), 2) if 'Error in' in parts[i+1]]
print('$r|' + ('; '.join(errs) if errs else 'none'))
"
done
