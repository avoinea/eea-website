# Handoff — pentru sesiunea următoare

## Stare

Campania red→green e închisă: **21 add-on-uri verzi** pe branch-urile `volto19` și **21 PR-uri `volto19 → develop`** deschise; dashboard 50 verzi / 15 roșii. Toate commit-urile sunt pe `volto19` (vezi `REPORT.md`); docs canonice pe `main` la `35ad3f9`; DS la `6c28303ea`, datahub la `fd7fd5c`.

## Ce face următoarea sesiune (primii pași)

1. **PR-uri verzi**: re-rulează `editing-progress` #37 (flaky V18); SonarQube pe PR la chatbot #45 / embed #88 / redmine #30 (aceeași clasă ca policy #138 — de decis cu userul dacă le repară sau le lasă în seama lui).
2. **Ultimele branch-roșii**: `group-block`, `object-widget`, `searchlib`, `slate-zotero`, `theme #395` — diagnostice de pornire în `TODO.md`; `theme` e deja diagnosticat (lint override + pin `@plone/babel-preset-razzle` + DS release).
3. **Unpin-uri** după release-uri: DS (datahub), chatbot/searchlib (globalsearch/policy/datahub).
4. Când toate PR-urile sunt verzi: reia campania pe `collective/*` (decizie user).

## Capcane de mediu (verificate în această sesiune)

- **prettier de la rădăcina monorepo-ului e vacu u**: `.gitignore` ignoră `frontend/`; rulează cu `--ignore-path /dev/null` sau din repo-ul addonului.
- **Jenkins API**: POST anonim → 403; rebuild doar cu cookie de sesiune Chrome + crumb. Alternativă folosită: push care atinge repo-ul (sau commit gol) pentru re-trigger.
- **Subagenți**: un workflow de 10 lane-uri a expirat la 20 min pentru că un copil a rămas blocat pe `curl` către Jenkins; preferă lane-uri țintite și interzice `curl` neautentificat în prompt.
- **Git la DS**: branch-ul `volto19` primește „style: Automated code fix" de la Jenkins — `git fetch && git rebase origin/volto19` înainte de push.
- **Dependințe noi + git pin**: pnpm tratează pachetele cu `prepare` ca build-required și rulează `pnpm install` în checkout (pică pe `workspace:*`); fix-ul e mutarea `prepare` → `husky:install` + root prepare (chatbot, searchlib, design-system).
- **CI non-frozen**: lock-urile nu au fost actualizate la dependințele noi; CI rezolvă în imagine. De revizuit înainte de merge.
- **Locally**: node 24 (`~/.nvm/versions/node/v24.10.0`); pentru repro unit mută clone-ul în afara `frontend/` (altfel node_modules-ul părintelui se infiltrează) sau folosește `core/` local + ajustarea `server.fs.allow`.
- **Dashboard**: `dashboard/` (untracked) — `curl http://127.0.0.1:3210/api/status`.

## Skill-uri utile

- `volto19-green-campaign` (principal; scripturi în `.agents/skills/volto19-green-campaign/scripts/`).
- `plone-frontend-developer` (Vitest/coverage/Volto 19), `handoff` la final.
