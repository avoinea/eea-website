# EEA Website

Monorepo for the EEA website built on Plone 6.1 with Volto 17.
This is a Plone dev environment that is Codex/Claude ready.

## Repository layout

- `frontend/`: Volto 17 frontend for Plone 6.1
- `backend/`: Plone 6 backend (development in `backend/develop/`)
- `skills/`: Local Codex/Claude skills for this repo

## Bootstrap sources

If you don't already have the frontend/backend checkouts, run:

```sh
make init
```

## Root make targets

Run from repo root:

- `make frontend-start` (Volto dev server)
- `make backend-start` (Plone standalone)
- `make frontend-relstorage` (Volto with RelStorage backend)
- `make backend-relstorage` (Plone with RelStorage/PostgreSQL)

## Requirements

- Node 20 (repo allows Node 18 or 20)
- Yarn 3.2.3
- Python environment for Plone backend (see `backend/` docs)

## Frontend development

Run from `frontend/`:

- Dev server: `make start` or `yarn start`
- Add-on dev sync: `make develop`
- Tests (Jest): `make test src/addons/<addon>`
- Cypress: `make cypress` or `yarn cypress:run`

Notes:

- Add-ons live in `frontend/src/addons/` and are registered in `frontend/package.json`.
- Shadow customizations live in `frontend/src/customizations/` and require a server restart.

## Backend development

Run from `backend/develop/`:

- Build: `make`
- Start: `make start`
- Tests: `bin/zope-testrunner --test-path sources/<package>`

Notes:

- Hot reload is not available; restart Plone after Python changes (optional `@@reload` for quick iteration).

## Useful docs

- `AGENTS.md` for repo-specific automation and tooling guidance
