# Plan & status

## Faza 1 — Batch 2 extins (6 repo-uri) · DONE

- design-tokens, embed-content, redirector: fail-fast stale + cleanup 404 (± praguri
  coverage); embed-content în plus `check-ci` 1200 + heap 8G.
- hero-block: selector dual V18/V19 la widget-ul de styling.
- Toate verificate: toate check-urile Jenkins `success` pe HEAD (ambele integrări,
  unit V19, secrets).

## Faza 2 — razzle-dev-utils (globalsearch/policy) · DONE

- Cauza nu era în cele două repo-uri: `@eeacms/volto-eea-chatbot@4.1.x` și
  `@eeacms/volto-searchlib@5.0.0` (npm) încă cer `razzle-dev-utils/makeLoaderFinder`.
- Pin git `github:eea/<repo>#volto19&path:/packages/<repo>` pentru ambele, în
  `pnpm.overrides`; scos shim-ul de `node_modules`. Necesită scoaterea `prepare` din
  pachetele chatbot/searchlib (commit-uri `720e124`, `2cdbd19`).
- Lock-uri regenerate cu pnpm 10.20.0 (core 19.5.0, `a424fdb`).

## Faza 3 — globalsearch React #423 · DONE

- Repro local: build izolat (repo mutat în afara monorepo-ului) = verde; setup cu
  node_modules-ul părinte = roșu (dublură React).
- Fix `1c6e077`: `rm -rf /app/node_modules` înainte de `pnpm install` în Dockerfile.
- Verificat: Jenkins build #16 → toate check-urile `success`.

## Faza 4 — docs · DONE

- `docs/2026-10-16-volto19-coverage-and-migration/{TODO,REPORT}.md` actualizate
  (`46de60b`, `c1dc2ad`); acest folder de handoff.

## Pending (vezi `TODO.md`)

- Unpin chatbot/searchlib la PR-ul `volto19→develop` (după release-urile majore).
- CI chatbot roșu (fail-fast stale + lint) — separat, nu blochează unpin-ul.
- Mini-val fail-fast: 13 repo-uri rămase.

## Operare (pentru continuare)

- Verificare stare: `gh api repos/eea/<repo>/commits/<sha>/check-runs?per_page=100`
  (per-stage pot fi fals `success`; agregatul `Jenkins` e adevărul).
- Diagnostic Jenkins detaliat: sesiunea Chrome logată → `wfapi/describe` →
  `stageFlowNodes` → `/execution/node/<id>/log/`; scripturile campaniei:
  `.agents/skills/volto19-green-campaign/scripts/*.sh`.
- Lock regen (dacă e nevoie): `core` clonat la tag-ul 19.5.0 în repo (gitignored) +
  `npx -y pnpm@10.20.0 install --lockfile-only --ignore-scripts`; verifică
  `--frozen-lockfile`.
