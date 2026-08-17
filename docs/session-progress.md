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
