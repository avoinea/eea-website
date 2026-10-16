# Plan & status

## Faza 1 — PR-uri `volto19 → develop` pentru toate repo-urile verzi · DONE

- 35 PR-uri deschise în 4 valuri (5 + 5 + 15 + 10), excluzând `collective/*`.
- Script: `open-volto19-prs.sh` (dry-run + skip PR existent).

## Faza 2 — sync `develop → volto19` la repo-urile „behind" · DONE

- `volto-datablocks` merge `56913c3`; `volto-eea-website-policy` merge `bcd82b3`.
- Ambele PR-uri au `mergeable=true`.

## Faza 3 — repararea roșiilor „doar-pe-PR" · PARȚIAL

- DONE `volto-tableau` #93: config coverage + test schema (`3c11356`) →
  Sonar 52.0% vs 46.4%; toate check-urile verzi.
- DONE `volto-datablocks` #160: `vi.mock` (`5f8b49a`) + teste coverage
  (`22b3116`) → Sonar 38.1% vs 35.5%; toate check-urile verzi.
- BLOCKED `volto-eea-website-policy` #138: Sonar coverage 26.9 vs 52.0.
- BLOCKED `eea-website-frontend` #284: job Jenkins PR pe Node 18.

## Faza 4 — docs · DONE

- Acest folder.

## Operare (pentru continuare)

- Stare per PR: check-runs pe HEAD-ul PR-ului, filtrate după `/job/PR-<n>/`
  (pe același SHA există și check-ul build-ului de branch!):
  `gh api repos/eea/<repo>/commits/<sha>/check-runs?per_page=100`.
- Sonar (public, fără auth):
  - per proiect/PR: `https://sonarqube.eea.europa.eu/api/measures/component?component=<repo>&pullRequest=<n>&metricKeys=coverage,lines_to_cover,uncovered_lines`
  - per fișier: `/api/measures/component_tree?...&pullRequest=<n>`
  - hits per linie (pentru „ce linii acoperea master"): `/api/sources/lines?key=<repo>:<path>&branch=master`
    (respectiv `&pullRequest=<n>`; căile diferă: master = `src/...`, PR = `packages/<repo>/src/...`).
- Verdictul Sonar pe PR compară cu **master**, nu cu develop.
- Repro local: clone-ul mutat în afara `frontend/`, `core/` clonat
  `--shared` din `frontend/core` (tag 19.5.0), `npx -y pnpm@10.20.0 install
  --no-frozen-lockfile`, apoi `CI=1 pnpm run test --coverage`.
