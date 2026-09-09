# Continue — Next Steps for Agents

> Plone Conf 2026 talk prep has its own continue file: `./continue-ploneconf.md` (this file is migration-only).

## Current state

Updated 2026-09-09 (Session 6 — docs sync + alignment fixes). Full detail: `./TODO.md`, `./session-progress.md`, `./12-decision-log.md` (amendments + Q26–Q29).

### What's done
- **Phase 0**: gitflow Docker image supports pnpm (branch `pnpm-support`, pushed, clean). Image build/push still operational.
- **Phase 1**: All 64 addon repos have backward-compatible V19 fixes. CI verification on V18 still pending.
- **Phase 2**: `frontend_addon` + `frontend_project` cookieplone templates complete. **`frontend_project` now aligned with the proven `eea-website-frontend` implementation** (`e32ed29`) and validated by generation.
- **Phase 3** ✅ (Aug 21–26): `frontend/` migrated in place to the Volto 19 pnpm workspace on branch `volto19` (core@19.3.0, project add-on `packages/eea-website-frontend/`, missdev Docker build + SSR dependency check, „Volto 19 frontend checks” Jenkins stage, REBUILD dropped).
- **Phase 4** 🔶 (Sep 4): all 67 add-ons restructured + pushed on `volto19` branches (workspace layout, dual V18/V19 pnpm Jenkinsfiles, vitest). npm publishes partially done; 9 add-ons have `npm latest` > repo version.
- **Phase 5**: Backend Makefile + requirements updated (blocked on EEA 6.2.x Docker image).
- **Frontend lockfile**: regenerated + `--frozen-lockfile` verified (2026-09-09).

### What's pending
- Push the local commits from this session (frontend `e3c598c` + `6d58e97`, cookieplone-templates `38c2abd` + `e32ed29`, helm-charts `2b0617ce`) and watch Jenkins (frontend + add-on pipelines V18/V19)
- Reconcile the 9 npm-vs-repo version mismatches (TODO Phase 4)
- Switch `mrs.developer.json` to tags (stabilizes the frontend frozen lockfile)
- Rewrite `frontend/scripts/release.py` for the new layout (`make release` broken)
- Phase 2 interactive-mode prompt testing; V18-yarn stage verification for add-on Jenkinsfiles
- Phase 0: build/push `eeacms/gitflow` image
- Phase 5: update backend Dockerfile when EEA publishes 6.2.x image
- Phase 6: debug deployment redesign (REBUILD is gone; PVC on `/app/packages` would shadow the baked project add-on)

## What to do next

### 1. Push this session's commits (you, from a machine with credentials)

```bash
cd frontend && git push origin volto19                       # e3c598c, 6d58e97
cd ../helm-charts && git push origin main                    # 2b0617ce
cd ../cookieplone-templates && git push origin main          # 38c2abd, e32ed29
# root repo: docs update commit
```

### 2. Phase 4 follow-ups (next coding session)

```bash
# Reconcile versions, then switch mrs.developer.json to tags:
#   9 add-ons listed in ./docs/TODO.md Phase 4
# Fix scripts/release.py (reads jsconfig.json + src/ — both gone)
```

### 3. Phase 5 — Backend upgrade (when EEA image available)

Wait for EEA to publish `eeacms/plone-backend:6.2.1-<n>`, then update `backend/Dockerfile`, run backend tests + upgrade steps.

### 4. Phase 6 — Cutover (after Phase 4 + 5)

Merge `volto19` → `develop` → `master`, build/push images, redesign debug deployment, update Helm charts, deploy.

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
