# EEA Website Frontend (Volto)

## Environment
- Plone: 6.1
- Volto: 17.x (see `frontend/package.json` for exact version)
- Node: 20 (repo allows 18 or 20)
- Package manager: Yarn 3.2.3

## Repo layout
- Root frontend: `frontend/`
- Source: `frontend/src/`
- Local add-ons: `frontend/src/addons/`
- Overrides/customizations: `frontend/src/customizations/`
- Theme entry: `frontend/src/theme.js`
- App config: `frontend/src/config.js`
- Routes: `frontend/src/routes.js`

## Common commands (run from `frontend/`)
- Start dev server: `yarn start`
- Build: `yarn build`
- Lint JS/TS: `yarn lint`
- Format check: `yarn prettier`
- Stylelint: `yarn stylelint`
- Tests: `yarn test`
- Cypress: `yarn cypress:open` or `yarn cypress:run`

## Add-ons
- Workspace add-ons are in `frontend/src/addons/*` and registered via `frontend/package.json` `addons`.
- Check `frontend/package.json` `resolutions` for pinned add-on versions.

## Add-on Make targets (example)
From `frontend/src/addons/volto-accordion-block` (`make help`):
- `make lint` / `make lint-fix`
- `make test` / `make test-update`
- `make cypress-open` / `make cypress-run`
- `make stylelint` / `make stylelint-fix`
- `make prettier` / `make prettier-fix`
- `make start`, `make install`, `make shell`, `make clean`
