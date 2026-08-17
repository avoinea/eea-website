# Continue — Next Steps for Agents

## Current state

Phases 0, 1, 2 (frontend_addon), and 5 (partial) are **code complete**. Phase 2's frontend_project template is created but untested. See `./docs/TODO.md` for checkbox-level detail and `./docs/session-progress.md` for a full session log with key learnings.

### What's done
- **Phase 0**: gitflow Docker image supports pnpm (3 files in `eea.docker.gitflow/`)
- **Phase 1**: All 64 addon repos have backward-compatible V19 fixes (babel.config.js, razzle-dev-utils, react-dnd, etc.)
- **Phase 2**: `frontend_addon` and `frontend_project` cookieplone templates complete and tested with `cookieplone@2.0.0b3` (`--no-input` mode)
- **Phase 5**: Backend Makefile + requirements updated (blocked on EEA 6.2.x Docker image)

### What's pending
- Phase 0: Build/push gitflow Docker image (operational)
- Phase 1: Commit/push addon changes, run CI to verify V18 compatibility
- Phase 2: Test `frontend_project` template generation ✅
- Phase 2: Interactive mode testing (3 prompts for project, 6 for addon)
- Phase 5: Update Dockerfile when EEA publishes 6.2.x backend image

## What to do next

### 1. Operational tasks (no code changes needed)

**Phase 0 — Build and push gitflow image:**
```bash
cd eea.docker.gitflow
git add Dockerfile src/js-release.sh src/frontend-release.sh
git commit -m "Add pnpm support alongside yarn"
git push  # triggers Jenkins to build eeacms/gitflow
# Verify: trigger a Volto 18 addon release via Jenkins
```

**Phase 1 — Commit and push addon changes:**
```bash
# For each of the 64 addon repos in frontend/src/addons/:
cd frontend/src/addons/<addon-name>
git add -A
git commit -m "Volto 19 compatibility: babel.config.js, razzle-dev-utils, react-dnd"
git push  # triggers CI — verify Cypress passes on Volto 18
```

**Phase 2 — Test frontend_project template:**
```bash
COOKIEPLONE_REPOSITORY=$(pwd)/cookieplone-templates uvx cookieplone@2.0.0b3 frontend_project --no-input -o /tmp/test-project
# Verify: Dockerfile, Makefile, Jenkinsfile, entrypoint.sh, .bundlewatch.config.json all present
```

### 2. Phase 3 — Generate new Volto 19 frontend project (after Phase 2 testing)

This is the next major coding task. Use the `frontend_project` template to scaffold the new frontend, then copy over project-specific config from `./frontend/`:

```bash
# Generate base project
COOKIEPLONE_REPOSITORY=gh:eea/cookieplone-templates uvx cookieplone@2.0.0b3 frontend_project

# Then copy from ./frontend/:
# - mrs.developer.json (output: packages/)
# - volto.config.js (26 project-level addons)
# - razzle.config.js (compression + handsontable)
# - .bundlewatch.config.json
# - cypress/ (update paths: src/addons/ → packages/)
# - locales/, public/, theme/
# - EEA scripts (update.sh, status.sh, pull.sh, etc.)
# - pnpm.overrides (24 EEA addon pins + React + react-refresh)
```

See `./docs/03-frontend-project-structure.md` and `./docs/07-build-and-deployment.md` for details.

### 3. Phase 5 — Backend upgrade (when EEA image available)

Wait for EEA to publish `eeacms/plone-backend:6.2.1-<n>`, then:
```bash
# Update backend/Dockerfile
FROM eeacms/plone-backend:6.2.1-<n>

# Run backend tests, check for namespace errors
# Add horse-with-no-namespace to requirements.txt if needed (already added preemptively)
# Run Plone upgrade steps in Add-ons control panel
```

### 4. After Phase 3: Phases 4 and 6

- **Phase 4**: Migrate each addon to pnpm (package.json, vitest.config.mjs, npm publish)
- **Phase 6**: Cutover (merge, deploy, Helm chart updates)

## How to track progress

- Update checkboxes in `./docs/TODO.md` as each step completes
- Full session log with key learnings: `./docs/session-progress.md`

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
- Cookieplone templates: `./docs/04-cookieplone-templates.md`
- Build and deployment: `./docs/07-build-and-deployment.md`
- Backend upgrade: `./docs/10-backend-upgrade.md`
- Session progress + key learnings: `./docs/session-progress.md`
- Volto 19 upgrade guide: https://6.docs.plone.org/volto/upgrade-guide/index.html
- Plone 6.2 upgrade guide: https://6.docs.plone.org/backend/upgrading/version-specific-migration/upgrade-to-62.html

## Cookieplone quick reference

```bash
# Run with EEA templates from local checkout
COOKIEPLONE_REPOSITORY=$(pwd)/cookieplone-templates uvx cookieplone@2.0.0b3 frontend_addon
COOKIEPLONE_REPOSITORY=$(pwd)/cookieplone-templates uvx cookieplone@2.0.0b3 frontend_project

# Clear cache if templates don't update
rm -rf ~/.cookiecutters/eea/cookieplone-templates

# The menu shows only: Add-ons (→ frontend_addon) and Projects (→ frontend_project)
```
