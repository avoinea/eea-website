# HANDOFF — Volto 19 Upgrade

> Talk prep (Plone Conf 2026) handoff: `./HANDOFF-PLONECONF.md` — this file is migration-only.
> Session 2 report (Aug 18) at the bottom — its "gotchas" remain valid.

## Session 6 (2026-09-09, final) — docs sync + merges + template verification

Full detail: `./TODO.md` (live checkboxes), `./session-progress.md` (sessions 3–6 + addenda), `./12-decision-log.md` (amendments D1–D5 + Q26–Q29), `./continue.md` (next steps).

### Ground truth vs the old docs

Phases 3 and most of 4 were already done in undocumented sessions (Aug 21–26: `frontend/` migrated to the pnpm workspace; Aug 20–Sep 8: npm publishes; Sep 4: all 67 add-ons restructured on `volto19` branches). Session 6 verified everything against git history + the npm registry, then synced the docs and completed the remaining alignment work:

- **Docs synced**: TODO (checkboxes to reality), session-progress (sessions 3–6 reconstructed + verified), decision log (amendments D1–D5 + new Q26–Q29), HANDOFF, continue.
- **REBUILD removed** (Q11 now conforms): `frontend` `e3c598c` (entrypoint) + `helm-charts` `2b0617ce` (debug deployment env).
- **Frontend lockfile regenerated + verified**: `frontend` `6d58e97` — `pnpm install --frozen-lockfile` passes (12m16s, pnpm 10.20.0). CI on `volto19` was guaranteed red since Sep 4 (stale lockfile vs the restructured add-on workspaces); this commit is the fix.
- **Templates verified end-to-end + fixed** (`cookieplone-templates` `e32ed29` + `87cdc91`): `frontend_project` aligned with the proven `eea-website-frontend` implementation (missdev Docker build + SSR dependency check gate, „Volto frontend checks” Jenkins stage, EEA scripts/Makefile/package.json, `razzle.extend.js`, no `jsconfig.json`/storybook; `.npmrc` hoist bug fixed — it resolved lint to the system eslint); `frontend_addon` post_gen gaps fixed (test/release-beta scripts added to the nested package, `towncrier.toml`/`news/` removed). Validated by generation + running: add-on `make install`/`test`/`test-ci` pass; project `pnpm install`/`build:deps`/`make check` exit 0.
- **Hook fix in template** (`968aa91`): the root -dev shell declares `lint-staged`, otherwise `.husky/pre-commit` fails every local commit ("Command \"lint-staged\" not found") — **existing 67 repos still need the one-line fix** (declined in-session).
- **All 13 DIVERGED add-ons merged** (`develop` → `volto19`), versions reconciled above npm latest for the 8 npm-published ones (accordion `1c0af61` pilot; datablocks `14e5d04`, group-block `b5d79b9`, website-policy `86dd96b`, website-theme `84cef72`, taxonomy `606e542`, kitkat `46773ba`, design-system `6998bd237`, chatbot `b24be04`, statistic-block `2b58792`, searchlib `3cb05ca`, block-divider `4ef5b91`, columns-block `cde98bc` — full table in `session-progress.md` addendum 3). Merged test failures are **pre-existing** (verified against the pre-merge state: 22/36 ≈ 23/37).
- **gitignore**: pnpm-store fallback + cookieplone transient answers file (`8173a61`, root).

### Key findings (this session)

1. **`razzle.extend.js` from a registered add-on is the official Volto 19 webpack-extension mechanism** (`AddonRegistry.getAddonExtenders()` in core's `razzle.config.js`) — the Q9 premise („razzle.config.js unchanged in V19") was wrong; implementation was right.
2. **`frontend/scripts/release.py` is broken under the new layout** (reads `jsconfig.json` + `src/<path>`; both gone) → `make release` fails; needs a rewrite against `mrs.developer.json` + `packages/`.
3. **Lockfile spans moving branch heads** (`develop: true`): any add-on dep change breaks the frontend `--frozen-lockfile` until tags are pinned (Q26). The 8 reconciled versions unblock publishing from `volto19`.
4. **`.husky/pre-commit` hook broken in all 67 restructured repos**: it runs `pnpm lint-staged`, which resolves only from the nested package → local commits fail the hook (CI is guarded). Template fixed; existing repos need lint-staged in the root -dev shell.
5. **Merged test failures are pre-existing**: `useContext`-null / `@formatjs/intl-utils` invariant on rendering tests (e.g. accordion 23/37) exist identically pre-merge — per-addon test-setup debugging or a CI-environment difference (full-icu/network) — Phase 4 "verify CI" work.
6. **`volto19` branch is at 6.6.0 while `master` is at 6.7.0** — expect CHANGELOG/version conflicts at the cutover merge.

## State of the repos (all pushed as of Sep 9, unless noted)

### `eea/eea-website-frontend` (`./frontend/`, branch `volto19`) — PUSHED
- Phase 3 done (Aug 21–26): pnpm workspace, core@19.3.0, project add-on `packages/eea-website-frontend/`, Dockerfile (missdev + frozen-lockfile + Sentry rebuild + SSR dependency check), Jenkins „Volto 19 frontend checks” stage, EEA scripts on pnpm/packages, REBUILD dropped.
- Commits this session: `e3c598c` (REBUILD dropped), `6d58e97` (lockfile regenerated + verified).
- Pending: Jenkins status on `volto19` (lockfile fix + REBUILD drop are in); full local `pnpm build` not re-run this session.

### 67 add-on repos (`./frontend/packages/*`, branch `volto19`)
- Restructured + pushed (Sep 4). **13 DIVERGED repos merged with `develop` this session + pushed** (accordion `1c0af61`, datablocks `14e5d04`, group-block `b5d79b9`, website-policy `86dd96b`, website-theme `84cef72`, taxonomy `606e542`, kitkat `46773ba`, design-system `6998bd237`, chatbot `b24be04`, statistic-block `2b58792`, searchlib `3cb05ca`, block-divider `4ef5b91`, columns-block `cde98bc`); the other 51 were already in sync (develop is an ancestor).
- **Versions reconciled** (nested > npm latest) for the 8 npm-published ones; publish from `volto19` pending (Phase 4).
- **Pending**: `.husky/pre-commit` lint-staged fix in all 67 (template fixed); add-on CI (V18 + V19 pipelines) verification — test failures (useContext/intl, 22–23 per repo where checked) are pre-existing and need per-addon investigation.

### `eea/cookieplone-templates` (branch `main`) — PUSHED
- `38c2abd` prompt/doc wording; `e32ed29` `frontend_project` aligned with the proven implementation (missdev Docker build + SSR dependency check, „Volto frontend checks” stage, EEA scripts/Makefile/package.json, `razzle.extend.js`, no `jsconfig.json`/storybook; `.npmrc` hoist bug fixed); `87cdc91` addon post_gen gaps (test scripts, towncrier removal); `968aa91` hook fix (lint-staged in root -dev shell).
- `frontend_addon` matches the 67 restructured add-ons 1:1; both templates validated end-to-end (generation + install/test/check suites).

### `eea/frontend-builder` — PUSHED
- Branches `18.x` + `19.x` on origin; Docker Hub `eeacms/frontend-builder:18`/`:19` auto-built; per-add-on Dockerfile is just the overlay.

### `eea/eea.docker.gitflow` (branch `pnpm-support`)
- pnpm support added (Phase 0), pushed. **Build/push of the image still pending** (operational).

### `eea/helm-charts` — PUSHED
- `2b0617ce` REBUILD env dropped from `eea-website-frontend` debug deployment.
- Pending (Phase 6): debug volume-mount redesign for the `packages/` layout (PVC on `/app/packages` shadows the baked project add-on).

### `backend/` — blocked (Phase 5)
- PLONE_VERSION=6.2.1 + horse-with-no-namespace prepared; blocked on EEA publishing `eeacms/plone-backend:6.2.1-<n>`.

## What's next for the next agent (in order)

### Phase 4 remaining (after the pushes)
1. **Watch CI** on the pushed branches: frontend „Volto 19 frontend checks” (`volto19`) + the 13 add-on dual pipelines (V18 + V19). Fix what surfaces — the merged test failures (useContext-null/intl on ~4 files per add-on) need per-addon test-setup debugging **or** a CI-environment difference (full-icu, node build) — verified pre-existing in the sandbox, not merge-caused.
2. **Propagate the hook fix** to the existing 67 repos: add `"lint-staged": "^14.0.1"` to each root `-dev` shell `devDependencies` (template fixed in `968aa91`).
3. **Rewrite `frontend/scripts/release.py`** for the new layout (`mrs.developer.json` + `packages/` + nested add-on versions) — `make release` is broken.
4. **npm publish** the reconciled versions from `volto19` (via release-it/gitflow when CI is green) so `latest` points at restructured V19 builds.
5. **Switch `mrs.developer.json` to tags** (stabilizes the frontend `--frozen-lockfile`).
6. Operational: build/push `eeacms/gitflow` image; verify a Volto 18 add-on release through it.

### Phase 5: Backend upgrade (when EEA 6.2.x image available)
- `backend/Dockerfile` base image → `eeacms/plone-backend:6.2.1-<n>`; run Plone upgrade steps; backend tests.

### Phase 6: Cutover
- PRs `volto19` → `develop` per add-on (clean after the merges); frontend `volto19` → `develop`/`master` (expect 6.6.0 vs 6.7.0 CHANGELOG/version conflicts).
- Build and push Docker images (Jenkins via gitflow); redesign the debug deployment flow (REBUILD is gone; PVC on `/app/packages` shadows the baked project add-on); deploy to demo, verify end-to-end, deploy to production.

## How to track progress

- Live checklist: `./docs/TODO.md`
- Full session log: `./docs/session-progress.md`
- All decisions: `./docs/12-decision-log.md` (Q26–Q29 are new/amended)
- Build and deployment: `./docs/07-build-and-deployment.md`
- Testing strategy: `./docs/06-testing-strategy.md`

## Session 2 (Aug 18) — historical: add-on template / builder / gitflow groundwork

### `volto-test-addon` → Volto 19 (PR #15, green)

Regenerated from the EEA `cookieplone-templates` `frontend_addon` template: pnpm workspace layout (root `-dev` package + `packages/volto-test-addon/`), `@plone/razzle` babel, `src/index.ts`, Jest → Vitest, EEA Makefile/Jenkinsfile/Dockerfile/docker-compose (dual V19 + V18 CI), EEA Cypress support, `packageManager` pnpm@10.20.0, Volto 19.3.0. Preserved: applyConfig, locales, CHANGELOG history, LICENSE, EEA docs, auto-comment workflow. PR #15 green (Jenkins, SonarQube, V18+V19 integration, unit, Betterleaks, branch, pr-merge).

### `eeacms/frontend-builder` — common builder image

Branches `18.x` + `19.x`: `FROM plone/frontend-builder:18`/`:19` + Chromium (pinned via Debian snapshot) + Cypress deps + `ENTRYPOINT ["pnpm"]`/`CMD ["start"]`. Docker Hub auto-builds `eeacms/frontend-builder:18`/`:19`. Per-add-on Dockerfile is just the overlay.

### `cookieplone-templates` — fixes + simplification

- Add-on Dockerfile: `FROM eeacms/frontend-builder:${VOLTO_VERSION}` + overlay (`rm -rf /app/cypress` + `cp -r .../. /app/` + `pnpm install` + `make build-deps`).
- Jenkinsfile: `CURRENT_VOLTO=19` + `PREVIOUS_VOLTO=18` (both pnpm).
- Makefile: `check-ci` uses bash `/dev/tcp` (no curl in the base image) + 600s timeout.
- `cypress.config.js`: junit + `@cypress/code-coverage`. `.gitleaks.toml`: drop `.npmrc` from `forbidden-secret-file`; allowlist Cypress `admin` creds. DEVELOP/RELEASE: `make` → `make install`; `.release-it.json` path → `packages/<addon>/`. `post_gen_project.py`: remove `jest-addon.config.js`; `.husky/pre-commit` executable; `.dockerignore` complete.

### `eea.docker.gitflow` — pnpm support (Phase 0)

- Dockerfile: `pnpm` alongside `yarn` (Node 18/20/22); `src/js-release.sh` detects pnpm via `packageManager`; `src/frontend-release.sh` pnpm deduplicate + lockfile.

## Key findings (the "gotchas")

1. **`rm -rf /app/cypress` is critical**: the base `plone/frontend-builder` ships an **upstream Volto** `cypress/support/e2e.js` that uses `reset-fixture` → `POST /Plone/RobotRemote`. The EEA backend doesn't expose `/Plone/RobotRemote` → 404. The add-on's **EEA** `cypress/support/e2e.js` (`slateBeforeEach` — creates content via REST API) must **replace** the base's. Without `rm -rf /app/cypress` first, `cp -r` **merges** (base's `reset-fixture` files remain alongside the add-on's), and Cypress loads the wrong `e2e.js`.

2. **`check-ci` uses bash `/dev/tcp`**: `plone/frontend-builder` does **not** install `curl` or `wget`. The EEA `make check-ci` must use bash's built-in `/dev/tcp/localhost/3000` (no external binary). The 600s timeout covers the `pnpm build && pnpm start:prod` time.

3. **`cp -r` nesting**: `cp -r /app/src/addons/<addon>/cypress /app/cypress` (where `/app/cypress` already exists in the base) **nests** → `/app/cypress/cypress/`. Use `rm -rf /app/cypress` first, then `cp -r`.

4. **Catalog injection**: `pnpm install` in the add-on workspace resolves `catalog:` specifiers via the `.pnpmfile.cjs` hook (reads `core/catalog.json`). If `core` is symlinked **outside** the workspace, pnpm may not resolve the catalog. Use a real `core/` directory inside the workspace (or `mrs-developer` to clone into `./core`).

5. **Dual V18 + V19 pnpm works**: Volto 18 ships `vitest.config.mjs` (not just Jest). The add-on's `@plone/razzle` babel is only used by `make i18n` (the add-on's own i18n extraction), not by the CI stages. So a V19-structure add-on works on V18 pnpm without changes.

6. **Betterleaks false positives**: the Cookieplone-generated `.npmrc` (pnpm hoist patterns) is flagged by the `forbidden-secret-file` rule. The Cypress `admin`/`admin` test credentials are flagged by `secret-literal-assignment`. Both are false positives — fix in `.gitleaks.toml`.

7. **`razzle.extend.js` (Q9 amended)**: Volto 19 loads add-on webpack config extensions via `AddonRegistry.getExtenders()` — the project add-on ships `razzle.extend.js` (compression gzip/brotli + node-target performance hints). There is no project-level `razzle.config.js` in V19.

## Cookieplone quick reference

```bash
# Run with EEA templates from local checkout
COOKIEPLONE_REPOSITORY=$(pwd)/cookieplone-templates uvx cookieplone@2.0.0b3 frontend_addon
COOKIEPLONE_REPOSITORY=$(pwd)/cookieplone-templates uvx cookieplone@2.0.0b3 frontend_project

# Clear cache if templates don't update
rm -rf ~/.cookiecutters/eea/cookieplone-templates

# The menu shows only: Add-ons (→ frontend_addon) and Projects (→ frontend_project)

# Sandbox without uvx: pip3 install --user --break-system-packages cookieplone==2.0.0b3
#   → ~/.local/bin/cookieplone (Python 3.14 works)
```

## `eeacms/frontend-builder` quick reference

```bash
# The common builder image (auto-built on Docker Hub from eea/frontend-builder branches)
# Branch 18.x → eeacms/frontend-builder:18
# Branch 19.x → eeacms/frontend-builder:19

# Add-on Dockerfile uses:
# FROM eeacms/frontend-builder:${VOLTO_VERSION}
# (VOLTO_VERSION = "18" or "19" — the Docker Hub tags)

# Jenkinsfile:
# CURRENT_VOLTO = "19"   # eeacms/frontend-builder:19
# PREVIOUS_VOLTO = "18"  # eeacms/frontend-builder:18
```
