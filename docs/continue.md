# Continue — Next Steps for Agents

> Plone Conf 2026 talk prep has its own continue file: `./continue-ploneconf.md` (this file is migration-only).

## Current state

Updated 2026-09-09 (Session 6, final — docs sync + merges + template verification). Full detail: `./TODO.md`, `./session-progress.md`, `./12-decision-log.md` (amendments + Q26–Q29), `./HANDOFF.md` (full repo state).

### What's done
- **Phase 0**: gitflow Docker image supports pnpm (branch `pnpm-support`, pushed, clean). Image build/push still operational.
- **Phase 1**: All 64 addon repos have backward-compatible V19 fixes. CI verification on V18 still pending.
- **Phase 2**: templates complete + **verified end-to-end** (addon install/test/test-ci pass; project install/build:deps/check exit 0); `.npmrc` hoist bug + addon post_gen gaps fixed (`87cdc91`); hook fix in template (`968aa91`).
- **Phase 3** ✅ (Aug 21–26): `frontend/` migrated in place to the Volto 19 pnpm workspace on branch `volto19` (core@19.3.0, project add-on `packages/eea-website-frontend/`, missdev Docker build + SSR dependency check, „Volto 19 frontend checks” Jenkins stage, REBUILD dropped).
- **Phase 4** 🔶: all 67 add-ons restructured + pushed; **all 13 DIVERGED repos merged with `develop` + versions reconciled above npm latest** (accordion `1c0af61`, datablocks `14e5d04` → 9.0.2, group-block `b5d79b9` → 10.1.1, website-policy `86dd96b` → 4.0.5, website-theme `84cef72` → 4.5.1, taxonomy `606e542` → 6.0.6, kitkat `46773ba` → 33.2.1, design-system `6998bd237` → 1.61.2, chatbot `b24be04` → 4.1.1, statistic-block `2b58792`, searchlib `3cb05ca`, block-divider `4ef5b91`, columns-block `cde98bc`). Merged test failures are pre-existing (verified vs pre-merge state).
- **Phase 5**: Backend Makefile + requirements updated (blocked on EEA 6.2.x Docker image).
- **Frontend lockfile**: regenerated + `--frozen-lockfile` verified (2026-09-09, `6d58e97`).
- **REBUILD removed**: frontend `e3c598c` + helm-charts `2b0617ce` (Q11 conforms).
- **All commits pushed** (verified: frontend, cookieplone-templates, helm-charts; root has 1 docs commit — `8173a61` — push on next push round).

### What's pending
- **Watch CI** after the pushes: frontend „Volto 19 frontend checks” (`volto19`) + 13 add-on dual pipelines (V18 + V19) — the merged test failures (useContext-null/intl on ~4 files per add-on) are pre-existing; per-addon test-setup debugging needed
- **Hook fix batch**: lint-staged in the root -dev shell for the existing 67 repos (template fixed in `968aa91`)
- **npm publish** the reconciled versions from `volto19` (via release-it/gitflow when CI is green)
- Switch `mrs.developer.json` to tags (stabilizes the frontend frozen lockfile)
- Rewrite `frontend/scripts/release.py` for the new layout (`make release` broken)
- Phase 2 interactive-mode prompt testing; V18-yarn stage verification for add-on Jenkinsfiles
- Phase 0: build/push `eeacms/gitflow` image
- Phase 5: update backend Dockerfile when EEA publishes 6.2.x image
- Phase 6: debug deployment redesign (REBUILD is gone; PVC on `/app/packages` would shadow the baked project add-on)

## What to do next

### 1. One small push left (root repo)

```bash
cd /Users/alin/sandbox/eea-website-volto19 && git push origin main   # 8173a61 (gitignore)
```

### 2. Watch CI on the pushed branches

The 13 add-on dual pipelines (V18 + V19) + the frontend „Volto 19 frontend checks” stage run on push. The known pre-existing test failures (useContext-null / intl invariant on rendering tests, ~4 files per DIVERGED add-on) need per-addon test-setup debugging — verified NOT merge-caused (pre-merge state fails identically).

### 3. Phase 4 follow-ups (next coding session)

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
