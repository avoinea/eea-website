# Plan și status

## Faza 1 — Fix Cypress Volto 18 pentru `volto-accordion-block` ✅ DONE
- Commit `4955914` pe `volto19` (PR-133). Verificat local pe ambele versiuni (`retries=0` + `make cypress-ci`) și pe Jenkins build #5 (Volto 18 ✅ / Volto 19 ✅).

## Faza 2 — Fix coverage SonarQube pentru `volto-accordion-block` ✅ DONE
- Commit `9386b4d`: `.coverage.babel.config.js`, `Makefile start-ci`, `babel-plugin-istanbul`, provider istanbul, `@vitest/coverage-istanbul`.
- Verificat local: unit+l e2e = 87.00% (prag 80%, master 82.20%). Jenkins #5: `Check coverage: OK (82.20 >= 82.20)`.

## Faza 3 — Template `frontend_addon` ✅ DONE
- `82a8091` — coverage e2e (fișier + Makefile + hook + README).
- `e7dbadc` — fix hidratare în `cypress/support/e2e.js`.
- Branch `next` în `eea/cookieplone-templates`.

## Faza 4 — Replicare coverage pe toate add-on-urile ✅ DONE
- 66 repo-uri (65 în batch-uri + `volto-datablocks` după rebase); commit `fix: sonarqube coverage on Volto 19` (5 fișiere/repo).
- Lockfile-urile nu au fost atinse (clone-urile locale nu au `core/`); CI face `pnpm install` ne-frozen.

## Faza 5 — Fix-uri per repo pentru eșecuri preexistente ✅ pregătite
- 7 repo-uri (vezi `DECISIONS.md` pct. 6); verificate în containere `eeacms/frontend-builder:19` (EXIT=0 / LINT=0).
- Commit-urile se fac automat de scriptul de batch-uri (`/tmp/mass-update.sh`, mesaje dedicate).

## Faza 6 — Update hidratare + Volto 19.5.0 pe toate EEA ✅ DONE
- Script: `nohup /tmp/mass-update.sh`, log `/tmp/mass-update.log` (păstrat și în `scripts/`).
- Batch-uri de 10, pauză 450s; per repo: commit fix-uri pending → fetch/rebase → patch hidratare → patch `mrs` → push.
- Rezultat final: **61 pushed, 1 skipped în batch (`volto-anchors`, rezolvat în pass 2), 0 failed**.

## Faza 7 — Pass 2 hidratare (variante de pattern) ✅ DONE
- 3 repo-uri ratate în batch 1 (`volto-anchors`, `volto-block-image-cards`, `volto-block-toc`) → patch + push țintit.
- Verificare finală pe 62 repo-uri EEA: `mrs=19.5.0`, fără pattern vechi de hidratare, worktree curat, 0 unpushed → **0 anomalii**.

## Faza 8 — Repo `collective` ⏳ BLOCKED (decizie user)
- Doar coverage a fost împins; hidratare + 19.5.0 nu. Opțiuni: PR-uri, cherry-pick la ei, sau skip.

## Faza 9 — Verificare Jenkins ✅ DONE (sesiunea 2)
- Spot-check pe 63 repo-uri: 23 OK, 38 eșecuri preexistente, 2 regresii reale (columns-block, slate-label) reparate.
- Vezi `spotcheck-2026-10-16.txt`, `regressions-per-check.txt`, `regressions-per-title.txt`, `diagnostics/`.

## Faza 10 — Curățenie ✅ la final
- Containere locale: `vacb-*`, `qt-*`, `cb-quick*`, proxy-uri `socat` (porturile 3000/3001).

## Faza 11 — Regresii sesiunea 2 ✅ DONE (push; re-verificare CI în curs)
- `volto-columns-block` `e544509`, `volto-slate-label` `7cdbac4`, `volto-datablocks` `c30ac71`, `volto-widget-geolocation` `64ceb5f`, `volto-group-block` `01688ee`, `volto-searchlib` `bdd6708`.
- La finalul sesiunii: 5 build-uri Jenkins în curs (columns-block, slate-label, group-block, globalsearch, searchlib).
