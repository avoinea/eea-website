# 04 — Cookieplone Templates

## Overview

We create and maintain EEA-specific Cookieplone templates that extend the upstream Plone templates with EEA conventions:
- Jenkins CI (not GitHub Actions)
- `@eeacms/` npm scope, `eea` GitHub org
- Docker Hub registry (`eeacms/`)
- EEA author/email defaults
- Documentation and VSCode config always included
- Ports 3000 (Volto) / 8080 (Plone) — not upstream's 55001

## Template: `frontend_addon` (updated for Volto 19)

### Custom EEA Makefile (replaces upstream)

A slim EEA Makefile is provided as a template file, replacing the upstream's bloated ~160-line Makefile. Key differences from upstream:

- **Ports**: `RAZZLE_INTERNAL_API_PATH?=http://localhost:8080/Plone` (not 55001)
- **No docker-compose for frontend**: local pnpm dev workflow (`pnpm start`)
- **Backend via docker-compose**: `docker-compose.yml` with `eeacms/plone-backend` on port 8080
- **EEA target names**: `ci-fix`, `test-ci`, `start-ci`, `check-ci`, `cypress-ci` (not upstream `format`, `ci-test`, `acceptance-frontend-prod-start`, `ci-acceptance-test`)
- **Cypress**: `pnpm --filter @plone/volto exec cypress` with `--project $(CURRENT_DIR)` and absolute `specPattern`
- **Vitest**: `test-ci` passes `--coverage --coverage.reporter=lcov --reporter=junit --outputFile=junit.xml`
- **`check-ci`**: curl-based wait (no `wait-on` dependency)
- **24 targets** total — no storybook, multilingual, guillotina, subpath, deployment bloat

### Jenkinsfile (based on existing EEA V18 pattern)

The Jenkinsfile uses EEA target names and minimal V19 path swaps from the V18 EEA Jenkinsfile:

| What | V18 EEA | V19 EEA |
|---|---|---|
| `--workdir` | `/app/src/addons/$GIT_NAME` | `/app` |
| Fix `docker cp` | `/app/src/addons/$GIT_NAME/src` | `/app/packages/$GIT_NAME/src` |
| Fix `git add` | `src/` | `packages/$GIT_NAME/src/` |
| Coverage `docker cp` | `/app/coverage` | `/app/packages/$GIT_NAME/coverage` |
| junit `docker cp` | `/app/junit.xml` | `/app/packages/$GIT_NAME/junit.xml` |
| Cypress results `docker cp` | `/app/src/addons/$GIT_NAME/cypress/` | `/app/cypress/` |
| SonarQube sources | `./src` | `./packages/$GIT_NAME/src` |

- `CURRENT_VOLTO = "19"`, `PREVIOUS_VOLTO = "18-yarn"`
- Three separate lint stages: ES lint, Style lint, Prettier
- `RAZZLE_INTERNAL_API_PATH` passed as Docker env var (not make argument)
- V18-yarn stage uses `yarn start` + `npx cypress run` directly (our V19 Makefile uses pnpm, not available in V18 image)
- **TODO for next agent**: Verify V18-yarn stage works — the generated addon doesn't have `cypress:run` in its package.json, and `npx cypress run` needs to find the cypress binary in the V18 image

### Cypress support (EEA override)

- `cypress/support/commands.js` — EEA commands: `autologin`, `createContent`, `removeContent`, `setWorkflow`, `waitForResourceToLoad`, Slate editor helpers, `navigate`, `getIfExists`
- `cypress/support/e2e.js` — `@cypress/code-coverage/support`, `slateBeforeEach`/`slateAfterEach`
- `cypress/tests/example.cy.js` — EEA-style test (block basics with Slate)
- **Not** the upstream pattern (Volto's `add-commands` + `reset-fixture`)

### Hooks

- `pre_prompt.sh` — converts `cookiecutter.json` → `cookieplone.json` v2, hides EEA constants. No longer appends Makefile targets (Makefile is now a template file).
- `post_gen_project.py` — patches addon `package.json`:
  - `lint-staged` config (calls `make lint-fix`, `make prettier-fix`, `make stylelint-fix`, `make i18n`)
  - `prepare: "cd ../.. && husky install || true"` (runs from addon package, goes to repo root, fails silently in monorepo)
  - DevDependencies: `husky`, `lint-staged`, `@cypress/code-coverage`, `@vitest/coverage-v8` (same version as `vitest`)

### .husky/pre-commit

Lives at the **repo root** (not inside the addon package), since husky v8 expects hooks at the git root.

### Example Vitest test

`src/config/settings.test.ts` — simple test verifying `install(config)` returns config unchanged.

### docker-compose.yml

Backend only: `eeacms/plone-backend` on port 8080 with `PROFILES: "eea.kitkat:testing"`.

`make start` starts both: `docker compose up -d backend && pnpm start`.

## Template: `frontend_project`

Unchanged from previous session — see TODO.md Phase 2 for details.

## cookieplone-config.json

Extends `gh:plone/cookieplone-templates` tag `20260320.1`. Hides all non-EEA groups and templates. Only `frontend_addon` and `frontend_project` are visible.

## Usage

```bash
# Generate a new EEA Volto add-on
COOKIEPLONE_REPOSITORY=gh:eea/cookieplone-templates uvx cookieplone@2.0.0b3 frontend_addon

# Generate a new EEA frontend project
COOKIEPLONE_REPOSITORY=gh:eea/cookieplone-templates uvx cookieplone@2.0.0b3 frontend_project
```
