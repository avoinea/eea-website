# EEA Plone Monorepo (AI ready dev environment)

Generic monorepo for EEA Plone projects built on Plone 6 with Volto.
This is a Plone dev environment that is AI agents ready.

## Repository layout

- `volto18/`: Volto 18 Core code (cloned during `make init` from `plone/volto` branch `18.x.x`)
- `volto17/`: Volto 17 Core code (cloned during `make init` from `plone/volto` branch `17.x.x`)
- `frontend/`: Volto frontend for Plone 6 (cloned during `make init`)
- `backend/`: Plone 6 backend (development in `backend/develop/`, cloned during `make init`)
- `.agents/skills/`: Local agent skills for this repo

## Bootstrap sources

If you don't already have the frontend/backend/volto checkouts, run:

```sh
make init
```

`make init` will also clone these core Volto checkouts if missing:

- `https://github.com/plone/volto` branch `17.x.x` into `volto17/`
- `https://github.com/plone/volto` branch `18.x.x` into `volto18/`

You'll be prompted for the frontend and backend GitHub repo URLs. For non-interactive use, set:

```sh
FRONTEND_REPO=<url> BACKEND_REPO=<url> make init
```

Optional overrides for the Volto core clone source/branches:

```sh
VOLTO_REPO=https://github.com/plone/volto VOLTO17_BRANCH=17.x.x VOLTO18_BRANCH=18.x.x make init
```

## Root make targets

Run from repo root:

- `make frontend-start` (Volto dev server)
- `make backend-start` (Plone standalone)
- `make frontend-relstorage` (Volto with RelStorage backend)
- `make backend-relstorage` (Plone with RelStorage/PostgreSQL)

## Requirements

- Node 20 or 22 (see `engines` in `frontend/package.json`)
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

## Backend development

Run from `backend/develop/`:

- Build: `make`
- Start: `make start`
- Tests: `bin/zope-testrunner --test-path sources/<package>`

Notes:

- Hot reload is not available; restart Plone after Python changes (optional `@@reload` for quick iteration).

## Useful docs

- `AGENTS.md` for repo-specific agent automation and tooling guidance