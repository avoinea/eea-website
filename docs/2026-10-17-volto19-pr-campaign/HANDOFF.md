# Handoff — pentru sesiunea următoare

## Stare

Campania de PR-uri `volto19 → develop` e deschisă pentru toate cele 36 de
repo-uri verzi `eea/*`: **34 verzi**; rămân `eea-website-frontend` #284 (config
Jenkins) și `volto-eea-website-policy` #138 (coverage Sonar). Ultimele
commit-uri de addon: tableau `3c11356`, datablocks `22b3116`, policy `bcd82b3`.

## Ce face următoarea sesiune (primii pași)

1. `volto-eea-website-policy` #138: acoperă cele două fișiere
   `src/customizations/volto/...` (Sonar 26.9% vs 52% pe master). Folosește
   `api/sources/lines` pe master vs PR ca să vezi exact ce linii acoperea
   master (vezi `PLAN.md`), apoi teste unitare local (repro în afara
   monorepo-ului, capcane mai jos).
2. Adaugă nota + checklist-ul de unpin chatbot/searchlib în body-ul PR-ului
   #138 (e pusă doar la globalsearch #79).
3. `eea-website-frontend` #284: de decis cu userul — e config Jenkins (job-ul
   de PR pe Node 18 vs `engines ^24`), nu cod.
4. Când toate PR-urile sunt verzi: reia campania cu mini-valul fail-fast
   (13 repo-uri, `docs/2026-10-16-volto19-coverage-and-migration/TODO.md`).

## Capcane de mediu (importante)

- **Rularea testelor local**: mută clone-ul în afara `frontend/` (ex.
  `mv frontend/packages/<addon> /tmp/repro/<addon>`), altfel node_modules-ul
  părintelui se infiltrează → React/intl duplicate → teste pică fals
  (`Could not find required intl object`). După rulare, mută-l la loc.
- `core/` (Volto 19.5.0) se clonează ieftin: `git clone --shared
  frontend/core core`; apoi `npx -y pnpm@10.20.0 install --no-frozen-lockfile`
  (lock-ul branch-ului și core-ul local diferă la `browserslist`). **Nu
  commita `pnpm-lock.yaml`** — `git checkout -- pnpm-lock.yaml` înainte de commit.
- Hook-ul husky `lint-staged` nu există local → `git commit --no-verify`, dar
  rulează întâi `prettier --check` pe fișierele atinse.
- Node 24: `export PATH=~/.nvm/versions/node/v24.10.0/bin:$PATH`; macOS nu are
  `timeout`.
- Check-ul agregat `Jenkins` apare de mai multe ori pe același SHA (build de
  branch + build de PR): filtrează după `/job/PR-<n>/`.
- Sonar pe PR se compară cu **master**, nu cu develop.
- `dashboard/` (untracked în repo-ul principal) e serverul local de stare
  (`npm start` în `dashboard/`, apoi `curl http://127.0.0.1:3210/api/status`);
  nu-l comite.
- `frontend/packages/volto-tableau` și `volto-datablocks` au acum `core/` +
  `node_modules` instalate (gitignored) — utile pentru repro rapid.

## Skill-uri utile

- `volto19-green-campaign` (principal; include `scripts/open-volto19-prs.sh`).
- `plone-frontend-developer` (Vitest/coverage/Volto 19).
- `handoff` la finalul sesiunii următoare.
