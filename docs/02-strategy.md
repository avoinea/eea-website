# 02 — Strategy: Regenerate-and-Migrate with Cookieplone

## Decision

**Regenerate-and-migrate**: Generate a fresh Volto 19 project using Cookieplone, then copy over all project-specific configuration, addons, and customizations.

## Rationale

The Volto 19 upgrade guide explicitly recommends this approach:

> "It is usually better and quicker to move your items into new locations and copy your dependencies than dealing with following the upgrade steps."

Key reasons:

1. **`src/config.js` is already empty** — all real configuration lives in addons, so the project is truly just boilerplate
2. **Volto 19 changes are extensive** — razzle fork, babel preset fork, pnpm 10, Vitest, pnpm catalog, `.pnpmfile.cjs`, `.npmrc` changes, Dockerfile changes. Manually applying all of these is error-prone.
3. **Cookieplone is the official generator** — generates correct boilerplate with all Volto 19 defaults
4. **Our `cookieplone-templates/` are already set up** — the `extends` mechanism is in place

## What gets regenerated vs. migrated

### Regenerated (from Cookieplone template)
- `package.json` (with pnpm, Volto 19 deps)
- `pnpm-workspace.yaml`
- `pnpm-lock.yaml`
- `.npmrc`
- `.pnpmfile.cjs`
- `tsconfig.json` (replaces `jsconfig.json`)
- `babel.config.js`
- `razzle.config.js` (base — then we add customizations)
- `.storybook/main.js`
- `Makefile` (base — then we add EEA targets)
- `Dockerfile` (base — then we customize)
- `volto.config.js`
- Vitest config

### Migrated from existing frontend
- `mrs.developer.json` (output path: `src/addons/` → `packages/`)
- Addon list (into `volto.config.js` + `package.json`)
- Custom `razzle.config.js` additions (compression plugins, handsontable fix)
- `.bundlewatch.config.json`
- Cypress config and tests
- `locales/` directory
- `public/` directory
- `theme/` directory
- EEA scripts (`update.sh`, `status.sh`, `pull.sh`, `pull-requests.py`, `release.py`)
- `Jenkinsfile` (updated for pnpm)
- `entrypoint.sh` (updated — drop REBUILD, keep Sentry)
- `pnpm.overrides` (from `resolutions`)

### Dropped
- `jsconfig.json` + `jsconfig.json.prod` (replaced by `tsconfig.json`)
- `.yarnrc.yml` + `.yarn/` directory (replaced by pnpm)
- `yarn.lock` (replaced by `pnpm-lock.yaml`)
- `patches/razzle-jest.patch` (Jest removed in Volto 19)
- `scripts/apply-workspace-protocol.js` (pnpm handles workspace natively)
- `scripts/restore-production-package.js` (same)
- `omelette` symlink (handled by Cookieplone)
- `REBUILD` logic in `entrypoint.sh` (debug pod only, users can install tools manually)