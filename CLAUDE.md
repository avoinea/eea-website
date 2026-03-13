# CLAUDE.md

## AI Assistant Instructions

## Skills
- plone-frontend-developer: Senior Plone Volto frontend engineering for debugging add-ons, fixing UI bugs, and handling Plone 6 + Volto frontend tasks. (path: .skills/plone-frontend-developer/SKILL.md)
- plone-backend-developer: Plone backend development for server behavior, add-ons, configuration, and tests in `backend/develop/`. (path: .skills/plone-backend-developer/SKILL.md)

## Repo Overview
- `volto/`: Volto 18 Core code
- `frontend/omelette`: Volto 17 Core code
- `frontend/`: Volto frontend for Plone 6 (cloned during `make init`).
- `backend/`: Plone 6 backend (development in `backend/develop/`, cloned during `make init`).
- `.skills/`: Local Codex skills for this repo.
- `.venv/`: Local Python virtual environment for tooling (use `.venv/bin/python`).

## Frontend Conventions
- Add-ons live in `frontend/src/addons/` and are registered in `frontend/package.json`.
- Preferred runtime: Node 20 with Yarn 3.2.3 (repo allows Node 18 or 20).

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
- Run `make init` from the repo root and provide frontend/backend GitHub repo URLs when prompted (or pass `FRONTEND_REPO`/`BACKEND_REPO` env vars).
