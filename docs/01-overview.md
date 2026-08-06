# 01 — Overview

## Why we're upgrading

The EEA Main Website (`www.eea.europa.eu`) runs on Plone 6 with Volto 18 as the frontend.
Plone 6.2 and Volto 19 are both stable releases. Upgrading ensures:

- **Security support**: Plone 6.1 is out of maintenance support; 6.2 is the current maintained version
- **Modern tooling**: Volto 19 brings Vitest, pnpm 10, forked Razzle, `@plone/components` in core
- **Accessibility improvements**: numerous a11y fixes across the editor and CMS UI
- **New features**: subpath domain support, restore unsaved changes, improved image upload widget
- **Future-proofing**: Volto 18's yarn-based setup is deprecated; Volto 19 drops yarn support entirely

## Scope

### In scope

- **Frontend** (`./frontend/`): Complete regeneration from Cookieplone template, migration of all project config
- **Backend** (`./backend/`): Incremental upgrade from Plone 6.1 to 6.2 (base image + constraints)
- **Add-ons** (64 repos): Fix Volto 19 breaking changes, maintain dual Volto 18 + 19 compatibility
- **Cookieplone templates** (`./cookieplone-templates/`): Create `frontend_project` template, update `frontend_addon` template
- **CI/CD**: Update Jenkinsfiles, gitflow Docker image, Helm charts
- **Documentation**: This `docs/` folder

### Out of scope

- Playwright migration (staying with Cypress)
- Mono-repo restructuring (frontend and backend remain separate repos)
- Backend Cookieplone regeneration (incremental upgrade only)
- New features or content changes

## Constraints

1. **Dual addon compatibility**: All 64 EEA Volto add-ons must work on both Volto 18 and Volto 19 during the transition
2. **Separate repos**: Frontend and backend remain independent git repos with separate Jenkins pipelines
3. **EEA CI conventions**: Jenkins (not GitHub Actions), Docker Hub (`eeacms/`), SonarQube, gitflow
4. **No mono-repo**: Keep the `packages/website/` workspace but don't combine frontend + backend
5. **Stable releases only**: Target Volto 19.3.0 and Plone 6.2.1 (no alphas/betas)
6. **Reusable templates**: The Cookieplone templates must work for other EEA Volto projects, not just this one

## Key risks

- **64 addon repos need simultaneous updates** — mitigated by phased approach (fix breaking changes first)
- **pnpm workspace structure** differs significantly from current flat yarn setup — mitigated by Cookieplone template
- **Language settings removal** in Volto 19 requires code changes in 3 addons — identified and scoped
- **Gitflow automation** uses yarn — mitigated by Phase 0 (update gitflow image before addon migration)