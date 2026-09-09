# Session Progress — Volto 19 Upgrade Execution

## What was done this session

### Phase 0: Update gitflow Docker image for pnpm ✅ (code complete)
- **Dockerfile**: Added `pnpm` to global npm installs for Node 18, 20, and 22
- **js-release.sh**: Added `detect_package_manager()` helper function that checks `packageManager` field in `package.json`. Updated:
  - NODEJS_VERSION install section (adds pnpm alongside yarn)
  - `update_package_json()` function (uses `pnpm add` instead of `yarn add` when pnpm detected)
  - Lock file git add (handles both `yarn.lock` and `pnpm-lock.yaml`)
  - Prepublish/publish section (uses `pnpm install`/`pnpm prepublish` when pnpm detected)
  - RUN_YARN_BEFORE_PUBLISH section
  - Changelog filtering (added `[PNPM]` pattern alongside `[YARN]`)
- **frontend-release.sh**: Updated NODEJS_VERSION install, pnpm detection for yarn-deduplicate, and lock file handling

**Pending**: Build/push Docker image, verify Volto 18 addon release still works

### Phase 1: Fix addon breaking changes ✅ (code complete across 64 addons)

| Fix | Addons | Status |
|-----|--------|--------|
| `babel.config.js` → `require('@plone/volto/babel')` | All 64 addons | ✅ Done (64 files updated) |
| `razzle-dev-utils` → conditional require | volto-eea-chatbot, volto-searchlib | ✅ Done |
| Cleanup commented razzle-dev-utils | volto-globalsearch | ✅ Done |
| `<img>` → `<Image>` | 5 addons | ✅ Already handled (ESLint exemptions + existing eslint-disable comments) |
| superagent error handling | 5 addons | ✅ Already safe (defensive patterns in use) |
| react-dnd/react-sortable-hoc | volto-eea-website-theme | ✅ Done (added deps + registered loadables) |
| Language settings | 3 addons | ✅ Already backward-compatible (policy addon sets config values) |

**Pending**: CI verification on Volto 18 (Cypress tests must pass)

### Phase 2: Create/update Cookieplone templates ✅ (frontend_addon complete and tested)

#### frontend_addon template (tested with cookieplone@2.0.0b3)

- **Jenkinsfile** — dual Volto 19 (current, full testing via upstream Makefile targets) + Volto 18-yarn (previous, Cypress only). Uses `--workdir=/app` for V19, upstream targets (`format`, `lint`, `ci-test`, `ci-acceptance-test`, `acceptance-frontend-prod-start`)
- **Dockerfile** — CI test image with Chromium. Handles both V18 (`/setupAddon` + `yarn install`) and V19 (copy addon to `/app/packages/` + `pnpm install`). Installs pinned Chromium for Cypress
- **pre_prompt.sh hook** — runs after template merge but before wizard. Does three things:
  1. Removes `initialize_ci` and `initialize_documentation` from merged cookiecutter.json
  2. Converts `cookiecutter.json` → `cookieplone.json` (v2 format) with EEA constants (`author`, `email`, `github_organization`) marked as `format: "constant"` (hidden from prompts). Visible prompts: title, description, frontend_addon_name, npm_package_name, use_prerelease_versions, volto_version (6 prompts)
  3. Appends `cypress`/`cypress-open`/`cypress-run` Makefile aliases to the upstream Makefile (simple aliases to `acceptance-test` / `ci-acceptance-test`)
- **cookiecutter.json** — EEA defaults, `_copy_without_render: [".github/workflows/betterleaks.yml"]`, no docs subtemplate
- **DEVELOP.md** — updated for Volto 19 defaults
- **LICENSE.md** — EEA MIT license
- **RELEASE.md** — EEA release instructions (pnpm-based)
- **.gitleaks.toml** — EEA security scanning config (referenced by betterleaks workflow)
- **.github/workflows/betterleaks.yml** — GitHub Actions secret scanning workflow (copied without Jinja2 rendering)

#### frontend_project template (created, not yet tested)

- **cookiecutter.json** — EEA defaults (@eeacms scope, eea org, Volto 19.3.0, pnpm 10.20.0)
- **Jenkinsfile** — EEA CI (Bundlewatch, Docker build, gitflow, SonarQube)
- **Dockerfile** — multi-stage with `plone/frontend-builder` + `node:22-slim` runtime
- **Makefile** — EEA targets using pnpm (develop, relstorage, staging, demo, cypress)
- **entrypoint.sh** — Sentry upload only (no REBUILD)
- **.bundlewatch.config.json** — basic pattern

#### cookieplone-config.json

- Added `frontend_project` to templates and projects group
- Hidden non-EEA groups (documentation, ci, ide, devops, agents, sub_templates) via `"hidden": true`
- Hidden non-EEA templates (backend_addon, monorepo_addon, seven_addon, project, classic_project) via `"hidden": true` in templates section
- Menu shows only: Add-ons (→ frontend_addon) and Projects (→ frontend_project)

#### Testing results

- `cookieplone@2.0.0b3 frontend_addon --no-input` ✅ generates valid addon with all EEA files
- Interactive mode ✅ shows only 6 prompts (not 11 like upstream)
- No `docs/` folder generated ✅
- Jenkinsfile present ✅
- Dockerfile present ✅
- LICENSE.md, RELEASE.md, .gitleaks.toml present ✅
- .github/workflows/betterleaks.yml present with `${{ }}` intact ✅
- Makefile has cypress/cypress-open/cypress-run aliases ✅
- `frontend_project` template NOT YET TESTED

**Pending**: Test frontend_project generation, test interactive prompts

### Phase 5: Backend upgrade to Plone 6.2 ⏳ (partially complete)
- Makefile: `PLONE_VERSION` updated to `6.2.1`
- requirements.txt: Added `horse-with-no-namespace` (preemptive)
- Dockerfile: Added TODO comment (waiting for EEA 6.2.x backend image)

**Blocked on**: EEA publishing `eeacms/plone-backend:6.2.x-n` Docker image

## Files modified

### eea.docker.gitflow repo (3 files)
- `Dockerfile` — added pnpm to Node 18/20/22 global installs
- `src/js-release.sh` — detect_package_manager() helper, pnpm add/install/prepublish, lockfile handling, changelog filtering
- `src/frontend-release.sh` — pnpm detection for yarn-deduplicate, lockfile handling

### cookieplone-templates repo (extensively modified)
- `cookieplone-config.json` — frontend_project added, non-EEA groups/templates hidden
- `README.md` — fully rewritten
- `templates/frontend_addon/cookiecutter.json` — EEA defaults, _copy_without_render, no docs subtemplate
- `templates/frontend_addon/hooks/pre_prompt.sh` — strips upstream prompts, converts to v2, appends cypress Makefile targets
- `templates/frontend_addon/{{ cookiecutter.__folder_name }}/Jenkinsfile` — dual V19/V18 CI using upstream Makefile targets
- `templates/frontend_addon/{{ cookiecutter.__folder_name }}/Dockerfile` — CI image with Chromium, handles V18+V19
- `templates/frontend_addon/{{ cookiecutter.__folder_name }}/DEVELOP.md` — V19 defaults
- `templates/frontend_addon/{{ cookiecutter.__folder_name }}/LICENSE.md` — EEA MIT
- `templates/frontend_addon/{{ cookiecutter.__folder_name }}/RELEASE.md` — EEA release docs
- `templates/frontend_addon/{{ cookiecutter.__folder_name }}/.gitleaks.toml` — security config
- `templates/frontend_addon/{{ cookiecutter.__folder_name }}/.github/workflows/betterleaks.yml` — GitHub Actions
- `templates/frontend_project/` — new directory with cookiecutter.json, Dockerfile, Makefile, Jenkinsfile, entrypoint.sh, .bundlewatch.config.json

### backend repo (3 files)
- `Dockerfile` — TODO comment added (pending EEA 6.2.x image)
- `develop/Makefile` — PLONE_VERSION updated to 6.2.1
- `requirements.txt` — horse-with-no-namespace added

### frontend addon repos (64 repos, ~70 files total)
- 64 × `babel.config.js` — replaced with `require('@plone/volto/babel')`
- 2 × `razzle.extend.js` — conditional try/catch for @plone/razzle-dev-utils (volto-eea-chatbot, volto-searchlib)
- 1 × `razzle.extend.js` — cleanup dead code (volto-globalsearch)
- 1 × `package.json` — volto-eea-website-theme (added react-dnd, react-dnd-html5-backend, @loadable/component deps)
- 1 × `src/index.js` — volto-eea-website-theme (registered reactDnd + reactDndHtml5Backend loadables)

## Next steps

1. **Phase 0**: Build and push the updated gitflow Docker image, verify a Volto 18 addon release
2. **Phase 1**: Commit and push addon changes to `develop` branches, trigger CI to verify Volto 18 compatibility
3. **Phase 2**: Test `cookieplone@2.0.0b3 frontend_project --no-input` generates valid structure
4. **Phase 3** (after Phase 2 testing): Generate new Volto 19 frontend project using the template
5. **Phase 5** (when EEA image available): Update backend Dockerfile, run tests and upgrade steps

## Key learnings

- cookieplone@2.0.0b3 is required (1.0.0 doesn't support local paths with `cookieplone-config.json`)
- The `extends` merge uses `dict.update()` — can override values but not remove upstream-only keys
- The `pre_prompt.sh` hook runs after merge but before wizard — can modify `cookiecutter.json` or create `cookieplone.json`
- `tui_forms` hides fields with `format: "constant"` or `format: "computed"` from prompts
- The upstream Makefile (pnpm-based) works for local dev — don't override it; append EEA targets via hook
- `plone/frontend-builder:19` has no `/setupAddon` script (unlike 18-yarn) — Dockerfile must copy addon to `/app/packages/` manually
- `_copy_without_render` in cookiecutter.json prevents Jinja2 rendering of files with `${{ }}` syntax (GitHub Actions)
- All template files need trailing newlines to avoid git diff noise

---

# Sessions reconstructed on 2026-09-09 (docs were last written on Session 2, Aug 18)

The sections below document work done **after** Session 2 that was missing from this log, plus the current session. Everything below was reconstructed from git history and verified against the working trees.

## Session 3 (2026-08-21 → 08-26) — `frontend/` migrated to the Volto 19 pnpm workspace

Commits on `frontend/` branch `volto19` (eea-website-frontend): `626c966` (volto19 project), `788c05c` (fix betterleaks), `648ffa4` (volto19 frontend), `02cfc72`/`a12cea3`/`a54cd6e` (fix ci), `d0074c4`/`26c6f21` (fix).

- Full pnpm workspace: `core/` at Volto 19.3.0 (exact tag), 67 add-on checkouts on `volto19` branches, project add-on `packages/eea-website-frontend/` (npm name `eea-website-frontend`, unscoped)
- `razzle.extend.js` in the project add-on — the **official Volto 19 mechanism** (`AddonRegistry.getAddonExtenders()`); compression (gzip + brotli via new `compression-webpack-plugin` API), handsontable `IgnorePlugin`, `performance.hints: false` for the node target (CI promoted asset-size hints to errors)
- Dockerfile: missdev inside the build, `--frozen-lockfile`, prod prune + `pnpm rebuild @sentry/cli` + `check-server-dependencies.cjs` gate; runtime from `plone/frontend-prod-config:19`
- CI-fix commits solved: missing prod deps in the SSR bundle (postcss, react-is, wikibase-sdk), `@sentry/cli` postinstall dropped by `--ignore-scripts` (hence the rebuild + `test -x sentry-cli`), Dockerfile copy list
- `VOLTOCONFIG=$(pwd)/volto.config.js` in root scripts — needed because `pnpm --filter @plone/volto` runs with `core/packages/volto` as cwd
- `.eslintrc.js` switched to AddonRegistry-based aliases; `jsconfig.json` dropped
- EEA helper scripts (`scripts/`) migrated off `yarn`/`src/addons` (none remain)

## Session 4 (2026-08-20 → 09-08) — npm publishes for the add-ons

At least 9 add-ons were published to npm (dates from registry metadata) **before** the Sep 4 restructuring, which reset their `package.json` versions:
datablocks 9.0.1 (Aug 20), website-policy 4.0.4 (Aug 20), taxonomy 6.0.5 (Aug 20), group-block 10.1.0 (Aug 26), accordion-block 13.1.0 + kitkat 33.2.0 + website-theme 4.5.0 (Aug 27), chatbot 4.1.0 (Aug 31), design-system 1.61.1 (Sep 8).
Result: `npm latest` > `volto19` branch version for 9 add-ons — reconciliation open (see TODO Phase 4).

## Session 5 (2026-09-04) — all 67 add-ons restructured + talk prep

- Every add-on repo got `880de8c` "chore: migrate add-on to Volto 19 structure" + `1a71c5c` "fix: satisfy Betterleaks scan", pushed to `volto19`, working trees clean and in sync with origin
- New layout per add-on: root `-dev` shell (`@eeacms/<name>-dev`, packageManager pnpm@10.20.0) + nested `packages/<addon>/` (main `src/index.js`, vitest.config.mjs, peerDeps react/react-dom), dual Jenkinsfile (`CURRENT_VOLTO=19` pnpm + `PREVIOUS_VOLTO=18` pnpm), EEA Makefile (`/dev/tcp` check-ci), Dockerfile overlay on `eeacms/frontend-builder`, `.gitleaks.toml`, cypress junit
- Root repo: Plone Conf 2026 talk prep committed (`b51ee6f`) — separate from the migration

## Session 6 (2026-09-09, current) — docs sync + alignment fixes

Ground-truth audit (git history + npm registry + template diffing), then:

1. **`frontend/` (branch `volto19`)**:
   - `e3c598c` — drop REBUILD from `entrypoint.sh`
   - `6d58e97` — regenerate `pnpm-lock.yaml` for the restructured add-on workspaces; **`pnpm install --frozen-lockfile` verified passing** (12m16s, pnpm 10.20.0)
2. **`helm-charts/`**: `2b0617ce` — drop `REBUILD=True` from `debug-deployment.yaml`
3. **`cookieplone-templates/`**: `38c2abd` (pending prompt/doc wording) + `e32ed29` — `frontend_project` template aligned with the proven implementation; validated by generating a project with `cookieplone@2.0.0b3 --no-input` (structure + syntax checks pass; Volto version resolves 19.4.0 via `latest_volto`)
4. **`docs/`**: TODO.md rewritten to reality (Phase 3 done, Phase 4 partially, Phase 6 REBUILD done), decision log amendments + Q26–Q28, HANDOFF/continue updated

Key learnings (new):

- `razzle.extend.js` from a registered add-on is auto-loaded by Volto core's `razzle.config.js` via `registry.getAddonExtenders()` — the old `razzle.config.js`-spread pattern from the V18 era is obsolete; Q9's premise was wrong
- `scripts/release.py` is **broken** under the new layout (reads `jsconfig.json` + `src/<path>`; both gone) — `make release` in the frontend fails; needs a rewrite against `mrs.developer.json` + `packages/`
- REBUILD is structurally incompatible with the new debug pod: PVC on `/app/packages` would shadow the baked project add-on, and the 3Gi debug pod cannot fit the frontend build — dropped (Q11 now conforms)
- Lockfile spans moving branch heads (`develop: true`): any add-on dep change breaks `--frozen-lockfile` until tags are pinned (Q26)
- cookieplone answers-file move fails across devices (sandbox artifact only, harmless)
- The upstream `frontend_project` template (Aug 18 state) generated a broken Docker build for any project with add-ons in `mrs.developer.json` (no missdev) — fixed by aligning with the proven implementation
- Sandbox has no `uvx`; installed `cookieplone==2.0.0b3` via `pip3 install --user --break-system-packages` (Python 3.14) and ran `~/.local/bin/cookieplone` with `COOKIEPLONE_REPOSITORY=$(pwd)/cookieplone-templates`

## Session 6 addendum (2026-09-09) — both templates generated and run end-to-end

After the push, both templates were generated with `cookieplone@2.0.0b3 --no-input` (local `cookieplone-templates`) and verified functionally:

**`frontend_addon`** (generated `volto-add-on`):
- Root shell package.json matches the real add-ons 1:1; Jenkinsfile dual V19/V18 ✓; Makefile EEA targets ✓
- Found + fixed template gaps (commit `87cdc91`): post_gen hook now adds `test`/`test:fix`/`release-beta`/`release-major-beta` scripts to the nested package.json and removes `towncrier.toml` + `news/` (EEA uses `.release-it.json` auto-changelog) — the nested package.json now matches the 67 restructured add-ons
- `make install` ✅ (missdev fetched core, pnpm install, build:deps) — needed `CYPRESS_INSTALL_BINARY=0`: the sandbox proxy returns 403 for download.cypress.io (environment-only)
- `make test` ✅ (1/1 vitest), `make test-ci` ✅ (junit.xml + v8 coverage report written)

**`frontend_project`** (generated `eea-website-frontend`):
- Found + fixed a real template bug (commit `87cdc91`): the generated `.npmrc` had only the upstream `public-hoist-pattern[]=*babel-preset-razzle`, so `eslint`/`prettier`/`stylelint` were **not hoisted** and `pnpm lint` resolved to the system eslint (crash: `context.getPhysicalFilename is not a function`). The template now ships the full EEA `.npmrc` (hoist list + `engine-strict=true`) and declares the eslint/stylelint stack in root devDependencies (mirroring `eea-website-frontend`)
- Verified: missdev → core@19.4.0; `pnpm install` ✓; `pnpm build:deps` ✓ (registry + components); **`make check` exit 0** (eslint, prettier, stylelint, typecheck, vitest)

**Sandbox-only notes (not template issues)**: cypress + sentry-cli binary downloads blocked by proxy (403) → use `CYPRESS_INSTALL_BINARY=0` and, if installing with `--ignore-scripts`, run `pnpm rebuild lightningcss-cli` afterwards (the lightningcss binary needs its install script to replace the Windows placeholder stub). Transient git clone failures of plone/volto through the proxy need a retry.

## Session 6 addendum 2 (2026-09-09) — pilot merge `develop` → `volto19` on `volto-accordion-block`

Sweep across the 67 add-ons of the `develop` ↔ `volto19` relationship:
- **51 SYNCED** (develop is an ancestor of volto19 — merge = no-op, future PR is clean)
- **13 DIVERGED** (develop moved after the merge-base): the 8 add-ons with npm publishes (accordion, datablocks, chatbot, design-system, kitkat, website-policy, website-theme, taxonomy, group-block) + 4 with code-only commits (searchlib, block-divider, columns-block, statistic-block)
- **3 NO-DEVELOP** (volto-subsites, volto-authomatic, volto-rss-provider — external branching, handle separately)

**Pilot (volto-accordion-block, merge commit `1c0af61`)** — recipe validated:
1. `git merge origin/develop` → 2 content conflicts (root `package.json`, `Edit.test.jsx`) + `jest-addon.config.js` delete/modify
2. Root `package.json` → keep the `-dev` shell (ours); version bump lands on the NESTED package
3. Reconciliation: nested version → `13.1.1` (first patch above npm latest 13.1.0)
4. `Edit.test.jsx` → keep the vitest (vi.mock) side; port develop's `mockBlocksToolbar` enhancement with `vi.fn()`; drop the `uuid` jest-mock (a V18-jest workaround — uuid resolves fine under vitest)
5. `jest-addon.config.js` stays deleted; `jest.uuid.setup.js` kept (harmless, V18-jest-only)
6. **The merge did NOT degrade the suite**: failures are pre-existing on `volto19` (22 fail/36 pre-merge ≈ 23 fail/37 post-merge — the +1 is develop's new clipboard-toolbar test, failing for the same pre-existing rendering-setup reason as its neighbours)

**Found**: `.husky/pre-commit` runs `pnpm lint-staged`, but lint-staged resolves only from the nested package → **every local commit in all 67 restructured repos fails the hook** (automation uses CI-guard/CYPRESS-style skips or --no-verify). Fixed in the template (root -dev shell declares lint-staged). Existing repos need the same one-line fix (Phase 4).

**Merge vs rebase decision**: merge (not rebase) — the `volto19` branches are pushed and referenced by the frontend workspace; rebase would force-push and break everyone's checkouts.
