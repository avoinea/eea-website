# Handoff: EEA Website Volto 19 Upgrade

## What was done

A comprehensive upgrade plan was created through a 19-question interview ("grill-me" skill). All decisions are documented in `./docs/` (14 files, ~52 KB). The plan covers upgrading the EEA Main Website frontend from Volto 18.35.1 to 19.3.0 (yarn→pnpm) and backend from Plone 6.1 to 6.2.1.

## What needs to happen next

The user also requested progress-tracking files (`docs/continue.md` and `docs/PLAN.md`) for the next agents to use. These have NOT been created yet — that is the immediate next action.

After that, the next sessions will execute the 7-phase plan starting with Phase 0 (gitflow image update) and Phase 1 (addon breaking-change fixes), which can run in parallel.

## Key artifacts already created

- `./docs/README.md` — Index of all documentation
- `./docs/01-overview.md` through `./docs/12-decision-log.md` — Full plan
- `./docs/13-redmine-ticket-summary.textile` — Redmine ticket summary

## Key decisions (see `./docs/12-decision-log.md` for full rationale)

1. Regenerate-and-migrate with Cookieplone (not incremental upgrade)
2. Accept pnpm workspace structure (`packages/website/`)
3. Create separate EEA `frontend_project` Cookieplone template (not combined project)
4. Phased addon migration — dual Volto 18+19 compatible
5. Skip unit tests on V18, Vitest on V19, Cypress on both
6. Multi-stage Dockerfile with `plone/frontend-builder:19.3.0`
7. Update `eeacms/gitflow` Docker image to support pnpm (Phase 0)
8. Backend: incremental upgrade (not Cookieplone regeneration)

## Codebase context

- `./frontend/` — Volto 18.35.1, yarn 3.2.3, 64 local dev addons in `src/addons/`
- `./backend/` — Plone 6.1.4, EEA-customized Docker image
- `./cookieplone-templates/` — EEA Cookieplone templates (has `frontend_addon`, needs `frontend_project`)
- `./cookieplone/` — Cookieplone CLI tool source
- `./volto17/`, `./volto18/`, `./volto19/` — Volto source code (branches 17.x.x, 18.x.x, main)
- `./eea.docker.gitflow/` — EEA gitflow Docker image source
- `~/sandbox/docker/eea-charts/sources/eea-website-frontend/` — Helm charts (has debug deployment with REBUILD)

## Skills to use next session

- `plone-frontend-developer` — For addon code fixes (Phase 1) and project migration (Phase 3)
- `plone-backend-developer` — For backend upgrade (Phase 5)
- `volto-cypress-writer` — If Cypress tests need updating for new path structure
- `grill-me` — If further design decisions are needed before execution