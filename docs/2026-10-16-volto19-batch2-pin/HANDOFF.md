# Handoff — pentru sesiunea următoare

## Stare

6/6 repo-uri verzi (HEAD-uri în `REPORT.md`); pin git din branch-ul `volto19` pentru
chatbot/searchlib în globalsearch+policy; globalsearch rezolvat cu clean-install în
Dockerfile. Docs canonice: `docs/2026-10-16-volto19-coverage-and-migration/`
(actualizate), acest folder = handoff. Commit docs: `c1dc2ad` pe `main`
(avoinea/eea-website); addon-urile sunt pushuite pe `volto19` la HEAD-urile din tabel.

## Ce face următoarea sesiune (primii pași)

1. Dacă se continuă campania „repo-uri verzi”: următorul lot = **mini-val fail-fast**
   (13 repo-uri, listă în docs canonice `TODO.md`), cu skill-ul
   `volto19-green-campaign` (protocol + tipare de fix).
2. Dacă se face PR-ul `volto19→develop`: verifică checklist-ul de **unpin** (vezi
   `TODO.md`) și pune pin-urile în descrierea PR-ului.
3. Nu redeschide discuția despre release-ul 4.1.6 (decizie user: următorul e major).

## Capcane de mediu (importante)

- **Verificare CI**: per-stage check-urile pot fi fals `success`; adevărul e în
  agregatul `Jenkins` (`output.summary`, trunchiat la ~64KB). Cel mai bun diagnostic:
  sesiunea Chrome logată → `wfapi/describe` → `/execution/node/<id>/log/`.
- **Imaginea de bază** `eeacms/frontend-builder:19` are `node_modules` scris de un pnpm
  vechi; `pnpm install` peste el cu pnpm 10 poate produce două instanțe React
  (`#423` la hidratare / `null.useEffect` în dev). Fix: install curat în Dockerfile.
- **Pin git**: `github:eea/<repo>#volto19&path:/packages/<repo>`; pachetul trebuie să
  nu aibă `prepare` (altfel pnpm rulează install în checkout → `workspace:*` pică).
- **Lock regen** local: `core` clonat la tag-ul 19.5.0 (gitignored) +
  `npx -y pnpm@10.20.0 install --lockfile-only --ignore-scripts`; CI folosește lock-ul
  commitat („Lockfile is up to date”), deci lock-ul contează.
- **Repro local fidel**: repo-ul de addon trebuie mutat/clonat **în afara**
  monorepo-ului (`frontend/`), altfel node_modules-ul părinte se infiltrează în
  rezoluție (dubluri React) — așa a apărut și falsul repro.
- **Unelte locale**: Node 24 (`~/.nvm/versions/node/v24.10.0`) pentru `engines ^24`;
  pnpm 10.20.0; macOS fără `timeout`; Makefile-urile au `.SILENT` (comenzile nu apar în
  `docker logs`); Docker pe arm64 emulează imaginile amd64 (build-uri lente).
- Jenkins API: doar cu sesiunea Chrome (cookie + `Jenkins-Crumb`); rebuild branch prin
  `POST /job/volto-addons/job/<repo>/job/volto19/build`.
- În workspace: `dashboard/` e untracked (nu e al campaniei) — nu-l atinge.

## Skill-uri utile

- `volto19-green-campaign` (principal) — protocol, scripturi, tipare de fix.
- `volto-cypress-writer` — teste Cypress în add-on-uri.
- `plone-frontend-developer` — build/config Volto 19, pnpm, Jenkins.
- `handoff` — la finalul sesiunii următoare.
