# 10 — Backend Upgrade: Plone 6.1 → 6.2

## Strategy: Incremental upgrade

The backend upgrade is an incremental version bump — no Cookieplone regeneration needed.

## Current backend setup

- **Base image**: `eeacms/plone-backend:6.1.4-14` (EEA-customized)
- **Plone version**: 6.1.3 (Makefile) / 6.1.4 (Dockerfile)
- **Python**: 3.12
- **12 EEA packages** + `collective.volto.subsites` + `rss-provider` from EEA egg repo
- **21 development packages** via `mxdev` with `sources.ini`
- **CI**: Jenkins with build/test/release stages via `eeacms/gitflow`

## Plone 6.2 changes (from upgrade guide)

### Native namespaces (main change)
All core Plone packages migrated from `pkg_resources`-style to native (PEP 420) namespaces.

- If EEA packages already use native namespaces: no issue
- If EEA packages use `pkg_resources` style: may need migration or `horse-with-no-namespace` workaround
- `pip` works fine with mixed namespace styles
- `zc.buildout` 4 won't work; buildout 5 works
- The `horse-with-no-namespace` package can be added as a workaround

### Python 3.14 support
- Optional — Python 3.12 is fine and recommended for stability

### Classic UI code separation
- `plone.app.layout` activation — **not relevant for Volto** (we use Volto, not Classic UI)

### TinyMCE 8
- Classic UI only — **not relevant for Volto**

## Upgrade steps

### 1. Update Dockerfile base image
```dockerfile
# Before
FROM eeacms/plone-backend:6.1.4-14

# After
FROM eeacms/plone-backend:6.2.1-<n>
```
(Wait for EEA to publish the 6.2-based backend image)

### 2. Update Plone version in Makefile
```makefile
# Before
PLONE_VERSION=6.1.3

# After
PLONE_VERSION=6.2.1
```

### 3. Update constraints URL
The Makefile bootstraps from Plone constraints:
```makefile
curl -o plone-constraints.txt https://dist.plone.org/release/$(PLONE_VERSION)/constraints.txt
```
This automatically pulls 6.2.1 constraints.

### 4. Check native namespace compatibility
- Run the backend tests
- If `ModuleNotFoundError` occurs for EEA packages, add `horse-with-no-namespace` to `requirements.txt`
- Long-term: migrate EEA backend packages to native namespaces

### 5. Update EEA backend package versions
- Update `requirements.txt` and `constraints.txt` with latest EEA package versions compatible with Plone 6.2
- Update `sources.ini` branches if needed

### 6. Run upgrade steps in Plone
- Go to Add-ons control panel in Plone
- Run any available upgrade steps
- Test the site end-to-end with the Volto 19 frontend

## What stays the same

- `mxdev` development setup (`sources.ini`, `requirements-mxdev.txt`)
- Jenkins CI pipeline (gitflow handles Python releases natively)
- Docker image structure (4-line Dockerfile extending EEA base image)
- `eea.website.policy` as the main integration package
- All backend test infrastructure

## Risk assessment

**Low risk**: The backend changes in Plone 6.2 are mostly about Python packaging (native namespaces) and Classic UI. Since we use Volto, the Classic UI changes are irrelevant. The namespace migration is handled by `horse-with-no-namespace` if needed.