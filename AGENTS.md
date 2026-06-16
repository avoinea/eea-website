# AGENTS.md

## AI Assistant Instructions

## Skills
- plone-frontend-developer: Senior Plone Volto frontend engineering for debugging add-ons, fixing UI bugs, and handling Plone 6 + Volto frontend tasks. (path: .agents/skills/plone-frontend-developer/SKILL.md)
- plone-backend-developer: Plone backend development for server behavior, add-ons, configuration, and tests in `backend/develop/`. (path: .agents/skills/plone-backend-developer/SKILL.md)
- volto-cypress-writer: Cypress E2E writing and maintenance for Volto add-ons in `frontend/src/addons`, with UI-first setup and project-specific commands. (path: .agents/skills/volto-cypress-writer/SKILL.md)
- caveman: Ultra-compressed communication mode for token-efficient, terse responses with adjustable intensity levels. (path: .agents/skills/caveman/SKILL.md)
- grill-me: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. (path: .agents/skills/grill-me/SKILL.md)
- handoff: Compact the current conversation into a handoff document for another agent to pick up. (path: .agents/skills/handoff/SKILL.md)

## Repo Overview
- `volto18/`: Volto 18 Core code
- `volto17/`: Volto 17 Core code
- `frontend/`: Volto frontend for Plone 6 (cloned during `make init`).
- `backend/`: Plone 6 backend (development in `backend/develop/`, cloned during `make init`).
- `.agents/skills/`: Local agent skills for this repo.
- `.venv/`: Local Python virtual environment for tooling (use `.venv/bin/python`).

## Frontend Conventions
- Add-ons live in `frontend/src/addons/` and are registered in `frontend/package.json`.
- Preferred runtime: Node 20 or 22 with Yarn 3.2.3 (see `engines` in `frontend/package.json`).

## Frontend Commands
- Dev: `make start` (run from `frontend/`).
- Add-on dev sync: `make develop` (uses `mrs.developer.json`).
- Tests: `make test src/addons/<addon>` for Jest; Cypress via `make cypress` or `yarn cypress:run`.

## Backend Conventions
- Dev workflow runs from `backend/develop/` with `make` then `make start`.
- Hot reload is not available;

## Backend Tests
- Run `bin/zope-testrunner --test-path sources/<package>` from `backend/develop/`.

## Bootstrap
- Run `make init` from the repo root. It also clones `volto17/` (`https://github.com/plone/volto` branch `17.x.x`) and `volto18/` (`https://github.com/plone/volto` branch `18.x.x`) if missing.
- Provide frontend/backend GitHub repo URLs when prompted (or pass `FRONTEND_REPO`/`BACKEND_REPO` env vars).
- Optional Volto override env vars: `VOLTO_REPO`, `VOLTO17_BRANCH`, `VOLTO18_BRANCH`.
