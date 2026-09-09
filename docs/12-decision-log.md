# 12 — Decision Log

All decisions made during the upgrade planning interview, with rationale.

## Q1: Overall migration strategy
**Decision**: Strategy A — Regenerate-and-migrate with Cookieplone
**Rationale**: `src/config.js` is already empty (all config in addons). Volto 19 changes are extensive (razzle fork, babel fork, pnpm 10, Vitest, pnpm catalog). Cookieplone generates correct boilerplate. Official guide recommends this approach.

## Q2: Frontend project structure
**Decision**: Option A — Accept Cookieplone pnpm workspace structure (`packages/website/`)
**Rationale**: The `packages/website/` pattern is the official Volto 19 approach. Docker images and CI work out of the box. `volto-update-deps` and other tools expect this structure. Not a true mono-repo — it's a single-project workspace.

## Q3: How to generate the project
**Decision**: Option B — Separate EEA templates (frontend_project + frontend_addon)
**Rationale**: Frontend and backend are already separate repos with independent Jenkins pipelines. Generating separately preserves this boundary. Templates are reusable for other EEA projects.

## Q4: EEA template overrides
**Decision**: Bake in reusable items (Jenkinsfile, EEA defaults, Dockerfile, Makefile); leave per-project items (addon list, mrs.developer.json, custom razzle config) as configuration
**Rationale**: Template generates boilerplate with EEA conventions; each project fills in its specific addons and config.

## Q5: Addon migration strategy
**Decision**: Option C — Phased approach (fix known breaking changes first, then upgrade project, then clean up)
**Rationale**: Known breaking changes are small (5 `<img>`, 1 react-dnd, 5 superagent). Fixes are backward-compatible with Volto 18. Allows incremental progress without big-bang risk.

## Q6: Testing strategy
**Decision**: Skip unit tests on Volto 18 (Cypress only); Vitest + Cypress on Volto 19
**Rationale**: Avoids maintaining both Jest and Vitest in every addon. Cypress provides the primary quality gate. Vitest's Jest-compatible API means most test files need zero changes.

## Q7: Test runner
**Decision**: Stay with Cypress (not Playwright)
**Rationale**: Volto 19 still uses Cypress natively. Cookieplone templates, Docker images, and Volto core all expect it. Playwright migration is a separate project.

## Q8: mrs.developer.json output path
**Decision**: Follow Cookieplone convention — `packages/` output
**Rationale**: pnpm workspace includes `packages/*`. Addons in `packages/` are automatically resolved as workspace packages. `volto-update-deps` and addon registry expect this.

## Q9: Custom razzle.config.js
**Decision**: Option A — Keep compression + handsontable customizations inline in razzle.config.js
**Rationale**: The razzle.config.js pattern is unchanged in Volto 19. Only the import path changes (razzle → @plone/razzle), which the Cookieplone template handles.
**Amended (2026-09-09)**: The premise was **wrong** — Volto 19 no longer uses a project-level `razzle.config.js`. The implementation (correct) uses `razzle.extend.js` inside the project add-on, auto-loaded by Volto core's `razzle.config.js` via `AddonRegistry.getExtenders()`. Content migrated faithfully (gzip + brotli through the new `compression-webpack-plugin` API, handsontable `IgnorePlugin`) plus node-target `performance.hints: false`. The `frontend_project` template now ships the same `razzle.extend.js` (compression defaults, without the handsontable part).

## Q10: Dockerfile
**Decision**: Switch to `plone/frontend-builder` multi-stage build
**Rationale**: Official Plone Docker image, pre-installs pnpm/Node/mrs-developer, build caching. EEA only upgrades to officially released versions. Reduces Dockerfile maintenance.

## Q11: REBUILD feature
**Decision**: Drop REBUILD from production. Debug pod users install tools manually.
**Rationale**: REBUILD is only used in the debug deployment (Helm chart), not in Jenkins CI/CD or production. Users can install tools in the debug container if needed.
**Implemented (2026-09-09)**: The initial implementation had kept `apply_rebuild` in `entrypoint.sh` (contrary to this decision). It was **removed** (`frontend` `e3c598c` + helm-charts `2b0617ce`) after audit showed it is structurally incompatible with the new layout: a PVC mounted on `/app/packages` shadows the baked project add-on (which missdev does not fetch), and the 3Gi debug pod cannot fit the frontend build. See Q28.

## Q12: Jenkinsfile changes
**Decision**: Only Bundlewatch stage changes (yarn → pnpm). Docker build and all other stages unchanged.
**Rationale**: The Dockerfile handles pnpm internally via multi-stage build. Gitflow, SonarQube, and Rancher stages don't use the package manager.
**Amended (2026-09-09)**: The implementation went further (and better): the separate Bundlewatch stage was **replaced** by a „Volto 19 frontend checks” stage (ci-install, check, ci-i18n, build, bundlewatch, then a Docker build + `wait-on` + Cypress smoke test against the project backend on `docker-big-jobs`), and „Build & Push” was extended to also run on branch `volto19` (so the migration branch gets demo images). The `frontend_project` template ships this stage as „Volto frontend checks”.

## Q13: Resolutions → pnpm.overrides
**Decision**: Option B — Keep EEA addon pins + React pins; drop security patches
**Rationale**: EEA addon pins prevent version conflicts in the dependency chain. Security patches are likely resolved in Volto 19's updated dependencies. Verify with `pnpm audit`.
**Amended (2026-09-09)**: The EEA add-on “pins” became **`workspace:*` overrides** (stricter than version pins — forces every reference to the checked-out add-on). `react`/`react-dom` 18.2.0, `react-refresh`, `@pmmmwh/react-refresh-webpack-plugin` kept; the `chalk@4.1.2` pin (via `@plone/babel-preset-razzle>chalk`) was also retained; `react-dev-utils` and `@plone/scripts/execa` dropped as decided.

## Q14: Backend upgrade
**Decision**: Option B — Incremental upgrade (update base image + constraints)
**Rationale**: Backend changes in Plone 6.2 are mostly about Python packaging and Classic UI. The 4-line Dockerfile just needs a base image bump. No need for Cookieplone regeneration.

## Q15: Remaining Volto 19 breaking changes
**Decision**: `babel.config.js` → `require('@plone/volto/babel')`; `razzle-dev-utils` → conditional require; language settings → from backend API
**Rationale**: `@plone/volto/babel` works in both V18 + V19. Conditional requires handle the razzle-dev-utils fork. Language settings need actual code changes to read from API.
**Amended (2026-09-09)**: Language settings were implemented differently — instead of reading from the backend API, `volto-eea-website-policy` sets `config.settings` values explicitly, which keeps the consuming add-ons (design-system Header, website-theme AlternateHrefLangs/Header) working unchanged. Backward-compatible and verified on V18; revisit if the policy add-on is ever removed. No `SITE_DEFAULT_LANGUAGE` references remain.

## Q16: Documentation structure
**Decision**: `docs/` folder with 13 .md files + 1 Textile file for Redmine
**Rationale**: Each document answers "what, why, how" and serves as a reference for developers and agents.

## Q17: Execution plan
**Decision**: 6 phases (later expanded to 7 with Phase 0)
**Rationale**: Each phase is independently verifiable. Phases 0, 1, 2, 5 can run in parallel. Dependencies are clear.

## Q18: Version targets
**Decision**: Volto 19.3.0, Plone 6.2.1 (both stable releases)
**Rationale**: Both are stable, no need to wait for alphas/betas. `plone/frontend-builder:19.3.0` Docker image is available.

## Q19: Gitflow automation
**Decision**: Update `eeacms/gitflow` Docker image to support pnpm (Phase 0)
**Rationale**: The gitflow image currently only installs `yarn`. Add `pnpm` alongside it. Update `js-release.sh` to detect pnpm vs yarn. `npm publish` works regardless of package manager.

## Q20: Common builder image — `eeacms/frontend-builder`
**Decision**: Create `eeacms/frontend-builder` (branches `18.x`, `19.x`) = `plone/frontend-builder:18`/`:19` + Chromium + Cypress deps + `ENTRYPOINT ["pnpm"]`/`CMD ["start"]`. Auto-build on Docker Hub → tags `18`/`19`.
**Rationale**: Chromium + Cypress deps + `ENTRYPOINT`/`CMD` are **common** to all add-ons. Baking them once in `eeacms/frontend-builder` means the per-add-on `Dockerfile` is just the overlay (13 lines vs 60+). Faster CI builds (Chromium installed once, reused). Consistent `ENTRYPOINT`/`CMD` across all add-ons.

## Q21: Add-on `Dockerfile` — just the overlay
**Decision**: `FROM eeacms/frontend-builder:${VOLTO_VERSION}` + `COPY` + `rm -rf /app/cypress` + `cp -r .../. /app/` + `pnpm install` + `make build-deps`. No Chromium, no `WORKDIR`/`ENTRYPOINT`/`CMD` (inherited from base).
**Rationale**: The overlay copies the add-on's config (`package.json`, `pnpm-workspace.yaml`, `.npmrc`, `.pnpmfile.cjs`, `.eslintrc.js`, etc.) + `packages/<addon>` onto the base Volto project. `rm -rf /app/cypress` first so the add-on's **EEA** Cypress (`slateBeforeEach` — creates content via REST API) replaces the base's **upstream Volto** Cypress (`reset-fixture` → `POST /Plone/RobotRemote` → `404` on the EEA backend).

## Q22: `check-ci` — bash `/dev/tcp` instead of `curl`
**Decision**: `make check-ci` uses `bash -c 'until (echo > /dev/tcp/localhost/3000) 2>/dev/null; do sleep 2; done'` with a 600s timeout.
**Rationale**: `plone/frontend-builder` (and thus `eeacms/frontend-builder`) does **not** install `curl` or `wget`. The bash `/dev/tcp` built-in checks if port 3000 is open without any external binary. The 600s timeout covers `make start-ci`'s `pnpm build && pnpm start:prod` (the production build takes a few minutes in CI).

## Q23: `cypress.config.js` — JUnit reporter + code-coverage task
**Decision**: `reporter: 'junit'` + `reporterOptions.mochaFile: 'cypress/reports/cypress-[hash].xml'` + `setupNodeEvents` registers `@cypress/code-coverage/task`.
**Rationale**: The EEA Jenkinsfile's Integration-tests `finally` block does a **fatal** `docker cp /app/cypress/reports` — without the JUnit reporter, no reports are written, and the `cp` fails with "Could not find the file." The `@cypress/code-coverage/task` registers the task so `cypress/support/e2e.js`'s `@cypress/code-coverage/support` import has somewhere to send coverage (coverage is only collected when the frontend is built with `babel-plugin-istanbul` — see `make start-ci`).

## Q24: `.gitleaks.toml` — drop `.npmrc` from forbidden-secret-file
**Decision**: Remove `\.npmrc` from the `forbidden-secret-file` path regex.
**Rationale**: The Cookieplone-generated `.npmrc` is benign pnpm hoist-pattern config (`public-hoist-pattern[]=*eslint*`, etc.). Flagging it as a forbidden secret-bearing file causes a false positive in Betterleaks. Real npm auth tokens (`_authToken=...`) in `.npmrc` are still caught by the `secret-literal-assignment` rule.

## Q25: Dual Volto 18 + Volto 19 CI (both pnpm)
**Decision**: `PREVIOUS_VOLTO = "18"` (pnpm) + `CURRENT_VOLTO = "19"` (pnpm). The V18 stage uses the same EEA Makefile flow as V19 (not yarn).
**Rationale**: Volto 18 ships `vitest.config.mjs` (not just Jest) — so the add-on's Vitest tests run on V18 too. The add-on's `@plone/razzle` babel is only used by `make i18n` (the add-on's own i18n extraction), not by the CI stages (`lint`, `test-ci`, `start-ci`, `cypress-ci`), which use the base Volto project's babel. So a V19-structure add-on works on V18 pnpm without changes.
## Q26: Frontend lockfile policy for moving add-on branches (2026-09-09)
**Decision**: Commit the regenerated `frontend/pnpm-lock.yaml` (matching the restructured `volto19` add-on workspaces) and keep `pnpm install --frozen-lockfile` in CI. Keep `mrs.developer.json` on `volto19` **branches** during the migration; switch to tags/V19-compatible npm releases as Phase 4 completes — tags make the lockfile truly stable.
**Rationale**: The committed lockfile (old layout: `link:packages/<addon>`) could never match the restructured add-ons (nested `link:packages/<addon>/packages/<addon>`) — CI was guaranteed red since Sep 4. The regenerated lockfile passes `--frozen-lockfile` (verified 2026-09-09, 12m16s). Trade-off accepted: until tags are pinned, any add-on that gains a dependency requires regenerating the frontend lockfile — document this in every PR that touches add-on `package.json` dependencies.
**Rejected**: dropping `--frozen-lockfile` (loses reproducibility, undermines the Docker pnpm-store cache), and switching to tags immediately (blocked by the 9 npm-vs-repo version mismatches).

## Q27: SSR prod-prune gate (2026-09-09, formalizing the Aug 25–26 fixes)
**Decision**: The frontend Docker build ends with: `pnpm install --prod --frozen-lockfile --ignore-scripts` → `pnpm rebuild @sentry/cli` → `node packages/<addon>/scripts/check-server-dependencies.cjs` → `test -x node_modules/.bin/sentry-cli`. Runtime-only deps discovered by the checker (`postcss`, `react-is`, `wikibase-sdk`, `@sentry/cli`) live in root `dependencies`; the checker scans every `require()` in `core/packages/volto/build/server.js` and fails the build if any unresolvable module remains.
**Rationale**: `pnpm`'s strict node_modules + prod prune can drop modules the SSR bundle requires at runtime (they were devDeps or transitive-only in the dev install) — the container crashes at startup, not at build time. The checker turns that class of failure into a build-time gate. `--ignore-scripts` skips Sentry CLI's binary download postinstall, hence the explicit `pnpm rebuild` + `test -x`.
**Note**: the template ships the same script + Dockerfile steps for all new EEA projects.

## Q28: Debug pod / REBUILD removal (2026-09-09)
**Decision**: Remove `REBUILD` entirely (`entrypoint.sh` + helm `debug-deployment.yaml`). Debug users exec into the pod and run the build manually. The debug volume-mount redesign is deferred to Phase 6.
**Rationale**: REBUILD only ever ran in the debug pod; under the pnpm workspace it is structurally incompatible — a PVC on `/app/packages` shadows the baked project add-on (missdev doesn't fetch it), and the 3Gi debug pod cannot fit the frontend build (7–16GB `NODE_OPTIONS`). Old deployments setting `REBUILD` against the new image degrade to a harmless no-op.
**Open**: Phase 6 must redesign the debug flow (PVC mounted elsewhere + per-add-on copy/symlink, or debug on the baked image build).

## Q29: `frontend_project` template alignment (2026-09-09)
**Decision**: Align `cookieplone-templates/templates/frontend_project` with the proven `eea-website-frontend` implementation (commit `e32ed29`): proven Dockerfile (missdev + frozen-lockfile + Sentry rebuild + SSR check + `plone/frontend-prod-config` runtime), „Volto frontend checks” Jenkins stage, EEA Makefile targets, EEA scripts (husky/update/status/pull), EEA `package.json` scripts + overrides, cypress code-coverage + fail-fast + smoke test, `razzle.extend.js`, AddonRegistry-based `.eslintrc.js`, `.nvmrc`, `.release-it.json`.
**Rationale**: The Aug 18 template state generated a **broken Docker build** for any project with add-ons in `mrs.developer.json` (no missdev fetch) and had storybook scripts without a generated `.storybook/` directory. The template is the reference for future EEA projects and the PloneConf demo — it must reflect validated reality.
**Deviations accepted**: `pull-requests*.py` not ported (hardcode the eea-website-frontend `jsconfig.json` URL + `~/.github` credentials file — legacy); `release.py` not ported (broken under the new layout, see TODO Phase 4); storybook scripts removed from the template (no `.storybook` generated; the frontend keeps its own); `jsconfig.json` dropped (AddonRegistry + `.eslintrc.js` handle all aliases).
