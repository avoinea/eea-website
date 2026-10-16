#!/usr/bin/env bash
# Replicate the coverage fix to all EEA Volto 19 add-ons, in batches of 10,
# with a 7.5 minute pause between batches.
set -uo pipefail

PACKAGES="/Users/alin/sandbox/eea-website-volto19/frontend/packages"
APPLY="/tmp/apply-coverage-fix.sh"
LOG="/tmp/replicate-run.log"
BATCH_SIZE=10
PAUSE_SECONDS=450

: > "$LOG"

# Pilots first (already patched locally), then the rest alphabetically.
repos=("volto-tabs-block" "volto-hero-block" "volto-quote-block")
for d in "$PACKAGES"/*/; do
  name="$(basename "$d")"
  [ -d "$d/.git" ] || continue
  [ "$name" = "volto-accordion-block" ] && continue
  case " ${repos[*]} " in *" $name "*) continue;; esac
  repos+=("$name")
done

echo "[$(date +%H:%M:%S)] total repos to process: ${#repos[@]}" >> "$LOG"

batch=0
pushed=0; skipped=0; failed=0
i=0
while [ $i -lt ${#repos[@]} ]; do
  batch=$((batch+1))
  batch_repos=("${repos[@]:$i:$BATCH_SIZE}")
  echo "[$(date +%H:%M:%S)] === BATCH $batch: ${#batch_repos[@]} repos ===" >> "$LOG"
  for name in "${batch_repos[@]}"; do
    out=$("$APPLY" "$PACKAGES/$name" push 2>&1)
    echo "[$(date +%H:%M:%S)] $name: $out" >> "$LOG"
    case "$out" in
      *PUSHED*) pushed=$((pushed+1));;
      *"PUSH FAILED"*) failed=$((failed+1));;
      *SKIP*) skipped=$((skipped+1));;
      *) skipped=$((skipped+1));;
    esac
  done
  i=$((i+BATCH_SIZE))
  if [ $i -lt ${#repos[@]} ]; then
    echo "[$(date +%H:%M:%S)] sleeping ${PAUSE_SECONDS}s before next batch..." >> "$LOG"
    sleep "$PAUSE_SECONDS"
  fi
done

echo "[$(date +%H:%M:%S)] DONE pushed=$pushed skipped=$skipped failed=$failed" >> "$LOG"
