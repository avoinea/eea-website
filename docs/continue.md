# Continue — Next Steps for Agents

## Current state

All planning is complete. 14 documentation files are in `./docs/`. A 7-phase execution plan with checkboxes is in `./docs/TODO.md`. All 19 decisions are logged in `./docs/12-decision-log.md`.

**No execution has started yet.** All phases are "Not started" in `./docs/TODO.md`.

## What to do next

### Immediate next actions (can start in parallel)

1. **Phase 0** — Update `eea.docker.gitflow` Docker image for pnpm support
   - Edit `./eea.docker.gitflow/Dockerfile` — add `pnpm` alongside `yarn`
   - Edit `./eea.docker.gitflow/src/js-release.sh` — detect pnpm via `packageManager` field
   - See `./docs/07-build-and-deployment.md` for details

2. **Phase 1** — Fix addon breaking changes on `develop` branches (all backward-compatible with V18)
   - Start with the 5 `<img>` → `<Image>` fixes (smallest, safest)
   - Then `babel.config.js` → `require('@plone/volto/babel')` across all addons
   - Then superagent error handling (5 addons)
   - Then language settings (3 addons) — most complex, needs API integration
   - See `./docs/05-addon-migration.md` for per-addon details

3. **Phase 2** — Create/update Cookieplone templates
   - Update `./cookieplone-templates/templates/frontend_addon/`
   - Create `./cookieplone-templates/templates/frontend_project/`
   - See `./docs/04-cookieplone-templates.md` for template structure

4. **Phase 5** — Backend upgrade (can run entirely independently)
   - Update `./backend/Dockerfile` base image
   - Update `./backend/develop/Makefile` Plone version
   - See `./docs/10-backend-upgrade.md` for steps

### After those complete

5. **Phase 3** — Generate new Volto 19 frontend project (depends on Phase 2)
6. **Phase 4** — Addon pnpm migration (depends on Phases 0 + 3)
7. **Phase 6** — Cutover (depends on Phases 3 + 4 + 5)

## How to track progress

- Update checkboxes in `./docs/TODO.md` as each step completes
- Add notes/comments in `./docs/TODO.md` if steps are blocked or need clarification
- The Redmine summary is in `./docs/13-redmine-ticket-summary.textile` — paste into the upgrade ticket

## Skills to use

- `plone-frontend-developer` — For addon code fixes (Phase 1) and project generation (Phase 3)
- `plone-backend-developer` — For backend upgrade (Phase 5)
- `volto-cypress-writer` — If Cypress tests need path updates for new structure
- `grill-me` — If further design decisions arise during execution

## Key references

- Full plan: `./docs/11-execution-plan.md`
- All decisions: `./docs/12-decision-log.md`
- Breaking changes: `./docs/09-volto19-breaking-changes.md`
- Addon migration: `./docs/05-addon-migration.md`
- Volto 19 upgrade guide: https://6.docs.plone.org/volto/upgrade-guide/index.html
- Plone 6.2 upgrade guide: https://6.docs.plone.org/backend/upgrading/version-specific-migration/upgrade-to-62.html