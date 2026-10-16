#!/usr/bin/env bash
# Second pass: apply the Cypress hydration fix to repos that were missed by the
# first run (pattern variants). EEA repos only, batches of 10 with a 7.5 min pause.
set -uo pipefail

PACKAGES="/Users/alin/sandbox/eea-website-volto19/frontend/packages"
LOG="/tmp/mass-update-pass2.log"
BATCH=10
PAUSE=450
: > "$LOG"

repos=()
for d in "$PACKAGES"/*/; do
  name="$(basename "$d")"
  [ -d "$d/.git" ] || continue
  [ "$name" = "volto-accordion-block" ] && continue
  url="$(git -C "$d" remote get-url origin 2>/dev/null || echo '')"
  case "$url" in *collective/*) continue;; esac
  repos+=("$name")
done
echo "[$(date +%H:%M:%S)] pass2 repos: ${#repos[@]}" >> "$LOG"

process() {
  local name="$1"
  cd "$PACKAGES/$name" || return
  git fetch -q origin volto19 2>/dev/null
  if [ -n "$(git status --porcelain)" ]; then
    echo "[$(date +%H:%M:%S)] $name: SKIP (dirty)" >> "$LOG"
    return
  fi
  if [ "$(git rev-list --count HEAD..origin/volto19 2>/dev/null || echo 0)" != "0" ]; then
    git pull --rebase -q origin volto19 >/dev/null 2>&1 || { git rebase --abort >/dev/null 2>&1; echo "[$(date +%H:%M:%S)] $name: SKIP (rebase conflict)" >> "$LOG"; return; }
  fi
  if python3 /tmp/patch-hydration.py | grep -q PATCHED; then
    git add cypress/support/e2e.js
    CI=true git commit -m "fix: load the edit route directly in slateBeforeEach" \
      -m "The appHistory push can race with the client hydration, which then settles back on the server-rendered view URL and the title editor never mounts." >/dev/null 2>&1
    if git push origin volto19 >/tmp/pass2-push.log 2>&1; then
      echo "[$(date +%H:%M:%S)] $name: PUSHED" >> "$LOG"
    else
      echo "[$(date +%H:%M:%S)] $name: PUSH FAILED -> $(tail -1 /tmp/pass2-push.log)" >> "$LOG"
    fi
  else
    echo "[$(date +%H:%M:%S)] $name: nothing to do" >> "$LOG"
  fi
}

i=0
batch=0
while [ $i -lt ${#repos[@]} ]; do
  batch=$((batch+1))
  echo "[$(date +%H:%M:%S)] === PASS2 BATCH $batch ===" >> "$LOG"
  for name in "${repos[@]:$i:$BATCH}"; do
    process "$name"
  done
  i=$((i+BATCH))
  if [ $i -lt ${#repos[@]} ]; then
    echo "[$(date +%H:%M:%S)] sleeping ${PAUSE}s..." >> "$LOG"
    sleep "$PAUSE"
  fi
done
echo "[$(date +%H:%M:%S)] PASS2 DONE" >> "$LOG"
