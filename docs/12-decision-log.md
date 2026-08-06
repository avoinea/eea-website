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

## Q10: Dockerfile
**Decision**: Switch to `plone/frontend-builder` multi-stage build
**Rationale**: Official Plone Docker image, pre-installs pnpm/Node/mrs-developer, build caching. EEA only upgrades to officially released versions. Reduces Dockerfile maintenance.

## Q11: REBUILD feature
**Decision**: Drop REBUILD from production. Debug pod users install tools manually.
**Rationale**: REBUILD is only used in the debug deployment (Helm chart), not in Jenkins CI/CD or production. Users can install tools in the debug container if needed.

## Q12: Jenkinsfile changes
**Decision**: Only Bundlewatch stage changes (yarn → pnpm). Docker build and all other stages unchanged.
**Rationale**: The Dockerfile handles pnpm internally via multi-stage build. Gitflow, SonarQube, and Rancher stages don't use the package manager.

## Q13: Resolutions → pnpm.overrides
**Decision**: Option B — Keep EEA addon pins + React pins; drop security patches
**Rationale**: EEA addon pins prevent version conflicts in the dependency chain. Security patches are likely resolved in Volto 19's updated dependencies. Verify with `pnpm audit`.

## Q14: Backend upgrade
**Decision**: Option B — Incremental upgrade (update base image + constraints)
**Rationale**: Backend changes in Plone 6.2 are mostly about Python packaging and Classic UI. The 4-line Dockerfile just needs a base image bump. No need for Cookieplone regeneration.

## Q15: Remaining Volto 19 breaking changes
**Decision**: `babel.config.js` → `require('@plone/volto/babel')`; `razzle-dev-utils` → conditional require; language settings → from backend API
**Rationale**: `@plone/volto/babel` works in both V18 + V19. Conditional requires handle the razzle-dev-utils fork. Language settings need actual code changes to read from API.

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