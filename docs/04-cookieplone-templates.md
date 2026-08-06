# 04 — Cookieplone Templates

## Overview

We create and maintain EEA-specific Cookieplone templates that extend the upstream Plone templates with EEA conventions:
- Jenkins CI (not GitHub Actions)
- `@eeacms/` npm scope, `eea` GitHub org
- Docker Hub registry (`eeacms/`)
- EEA author/email defaults
- Documentation and VSCode config always included

## Template: `frontend_addon` (update existing)

The existing `frontend_addon` template in `cookieplone-templates/` needs updating for dual Volto 18/19 support.

### Changes needed

1. **Jenkinsfile** — add a Volto 19 testing stage alongside the existing Volto 18 stage:
   - Volto 18 pipeline: Cypress only (no unit tests)
   - Volto 19 pipeline: Vitest + Cypress
   - Both use `eeacms/volto-project-ci` Docker images

2. **`babel.config.js`** — use `require('@plone/volto/babel')` instead of `['razzle']` (works in both V18 + V19)

3. **Vitest config** — generate `vitest.config.mjs` for Volto 19 addon testing

4. **`cookiecutter.json`** — already has Volto version selection via `__test_framework` variable

### What stays the same
- `DEVELOP.md` with EEA development instructions
- EEA organization defaults
- No GitHub Actions
- Documentation and VSCode always included

## Template: `frontend_project` (create new)

A new standalone EEA `frontend_project` template that generates a complete frontend repo (not combined with backend).

### Template structure
```
cookieplone-templates/
├── cookieplone-config.json          # Add frontend_project entry
└── templates/
    ├── frontend_addon/               # Existing (updated)
    │   ├── cookiecutter.json
    │   └── {{ cookiecutter.__folder_name }}/
    │       ├── Jenkinsfile            # Updated for dual V18/V19
    │       └── DEVELOP.md
    └── frontend_project/              # NEW
        ├── cookiecutter.json
        └── {{ cookiecutter.__folder_name }}/
            ├── Jenkinsfile            # EEA CI (Bundlewatch, Docker build, gitflow)
            ├── Dockerfile             # Multi-stage with plone/frontend-builder
            ├── Makefile                # EEA targets (develop, relstorage, staging, demo, cypress)
            └── entrypoint.sh           # Sentry upload at startup (no REBUILD)
```

### What the template bakes in (reusable across all EEA projects)
- Jenkinsfile with EEA CI pattern (Bundlewatch stage, Docker build, gitflow release, SonarQube)
- Docker Hub registry default (`eeacms/`)
- EEA npm scope (`@eeacms/`), GitHub org (`eea`)
- Multi-stage Dockerfile with `plone/frontend-builder`
- Makefile with EEA targets
- `entrypoint.sh` with Sentry upload (no REBUILD)
- `.bundlewatch.config.json` pattern
- No GitHub Actions, no Ansible

### What stays per-project (filled in during migration)
- Specific addon list in `volto.config.js`
- `mrs.developer.json` with project addons
- Custom `razzle.config.js` additions (compression, handsontable)
- Project-specific Jenkins env vars (SonarQube tags, stack IDs)
- Cypress tests and fixtures
- Locales, public assets, theme files

## cookieplone-config.json update

Add `frontend_project` to the templates section:
```json
"templates": {
  "frontend_addon": { ... },
  "frontend_project": {
    "path": "./templates/frontend_project",
    "title": "EEA Frontend Project for Plone",
    "description": "Create a Volto frontend project with EEA conventions"
  }
}
```

## Usage

```bash
# Generate a new EEA frontend project
COOKIEPLONE_REPOSITORY=gh:eea/cookieplone-templates cookieplone frontend_project

# Generate a new EEA Volto add-on
COOKIEPLONE_REPOSITORY=gh:eea/cookieplone-templates cookieplone frontend_addon
```