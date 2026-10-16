#!/usr/bin/env bash
# Mass updates for EEA Volto 19 add-ons, in batches of 10 with a 7.5 min pause:
#  1. commit any pending per-repo fixes (tests/lint)
#  2. load the edit route directly in slateBeforeEach (Cypress hydration race)
#  3. update mrs.developer.json to Volto 19.5.0
# Collective repositories are skipped on purpose (they have their own workflow).
set -uo pipefail

PACKAGES="/Users/alin/sandbox/eea-website-volto19/frontend/packages"
LOG="/tmp/mass-update.log"
BATCH=10
PAUSE=450
: > "$LOG"

fix_msg() {
  case "$1" in
    volto-columns-block) echo "fix: complete the ./utils mock in index.test.js";;
    volto-datablocks) echo "fix: update stale vitest mocks in unit tests";;
    volto-eea-design-system) echo "fix: drive the AI summary state via the hook mock in Header tests";;
    volto-eea-map) echo "chore: drop unit coverage thresholds until tests exist";;
    volto-searchlib) echo "fix: resolve @eeacms/search to the in-repo searchlib in eslint";;
    volto-globalsearch) echo "fix: declare @eeacms/search and ignore its lib/* subpaths in eslint";;
    volto-widget-geolocation) echo "fix: allow the Redux password reference in the secrets scan";;
  esac
}


repos=()
for d in "$PACKAGES"/*/; do
  name="$(basename "$d")"
  [ -d "$d/.git" ] || continue
  [ "$name" = "volto-accordion-block" ] && continue
  url="$(git -C "$d" remote get-url origin 2>/dev/null || echo '')"
  case "$url" in *collective/*) continue;; esac
  repos+=("$name")
done

echo "[$(date +%H:%M:%S)] total EEA repos: ${#repos[@]}" >> "$LOG"

process() {
  local name="$1"
  local dir="$PACKAGES/$name"
  cd "$dir" || return

  git fetch -q origin volto19 2>/dev/null

  # 1. pending per-repo fixes
  if [ -n "$(git status --porcelain)" ]; then
    if [ -n "$(fix_msg "$name")" ]; then
      git add -A
      CI=true git commit -m "$(fix_msg "$name")" >/dev/null 2>&1
      echo "[$(date +%H:%M:%S)] $name: committed pending fix" >> "$LOG"
    else
      echo "[$(date +%H:%M:%S)] $name: SKIP (unexpected dirty worktree)" >> "$LOG"
      return
    fi
  fi

  # be up to date with the remote before adding new commits
  if [ "$(git rev-list --count HEAD..origin/volto19 2>/dev/null || echo 0)" != "0" ]; then
    if ! git pull --rebase -q origin volto19 >/dev/null 2>&1; then
      git rebase --abort >/dev/null 2>&1
      echo "[$(date +%H:%M:%S)] $name: SKIP (rebase conflict)" >> "$LOG"
      return
    fi
  fi

  # 2. Cypress hydration fix
  if python3 /tmp/patch-hydration.py | grep -q PATCHED; then
    git add cypress/support/e2e.js
    CI=true git commit -m "fix: load the edit route directly in slateBeforeEach" \
      -m "The appHistory push can race with the client hydration, which then settles back on the server-rendered view URL and the title editor never mounts." >/dev/null 2>&1
    echo "[$(date +%H:%M:%S)] $name: hydration fix committed" >> "$LOG"
  fi

  # 3. Volto 19.5.0
  if python3 /tmp/patch-mrs.py | grep -q PATCHED; then
    git add mrs.developer.json
    CI=true git commit -m "chore: update Volto to 19.5.0" >/dev/null 2>&1
    echo "[$(date +%H:%M:%S)] $name: mrs 19.5.0 committed" >> "$LOG"
  fi

  if [ -n "$(git log --oneline origin/volto19..HEAD 2>/dev/null)" ]; then
    if git push origin volto19 >/tmp/mass-push.log 2>&1; then
      echo "[$(date +%H:%M:%S)] $name: PUSHED" >> "$LOG"
    else
      echo "[$(date +%H:%M:%S)] $name: PUSH FAILED -> $(tail -1 /tmp/mass-push.log)" >> "$LOG"
    fi
  else
    echo "[$(date +%H:%M:%S)] $name: nothing to push" >> "$LOG"
  fi
}

i=0
batch=0
while [ $i -lt ${#repos[@]} ]; do
  batch=$((batch+1))
  echo "[$(date +%H:%M:%S)] === BATCH $batch ===" >> "$LOG"
  for name in "${repos[@]:$i:$BATCH}"; do
    process "$name"
  done
  i=$((i+BATCH))
  if [ $i -lt ${#repos[@]} ]; then
    echo "[$(date +%H:%M:%S)] sleeping ${PAUSE}s..." >> "$LOG"
    sleep "$PAUSE"
  fi
done
echo "[$(date +%H:%M:%S)] DONE" >> "$LOG"
