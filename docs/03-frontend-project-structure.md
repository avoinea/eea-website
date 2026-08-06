# 03 — Frontend Project Structure

## pnpm workspace layout

The Cookieplone-generated Volto 19 project uses a pnpm workspace:

```
frontend/
├── packages/
│   └── website/           # The actual project package (add-on driven development)
│       ├── src/             # Project-specific source code
│       ├── package.json     # Project deps + addon list
│       └── ...
├── packages/               # Local dev addons (via mrs.developer.json, output: "packages")
│   ├── volto-eea-kitkat/
│   ├── volto-embed/
│   └── ... (64 addons)
├── pnpm-workspace.yaml    # Workspace config: packages: ['packages/*']
├── package.json            # Root (thin orchestrator)
├── volto.config.js         # Addon registration
├── razzle.config.js        # Build config
├── Dockerfile              # Multi-stage build
├── Makefile                # EEA make targets
├── Jenkinsfile             # CI pipeline
├── .npmrc                  # pnpm config
├── .pnpmfile.cjs           # pnpm catalog hook
├── tsconfig.json           # TypeScript config (replaces jsconfig.json)
├── mrs.developer.json      # Local dev addon sources
└── ...
```

## Key differences from current setup

| Aspect | Current (Volto 18, yarn) | New (Volto 19, pnpm) |
|---|---|---|
| Package manager | yarn 3.2.3 | pnpm 10.x (`packageManager` field) |
| Addon location | `src/addons/` | `packages/` |
| Path resolution | `jsconfig.json` + yarn workspaces | `tsconfig.json` + pnpm-workspace.yaml |
| Lock file | `yarn.lock` | `pnpm-lock.yaml` |
| Project package | Flat (`src/config.js`, `src/routes.js`) | `packages/website/` (add-on driven) |
| Config | `src/config.js` (deprecated in V19) | `volto.config.js` + addon `index.js` |
| Workspace protocol scripts | `apply-workspace-protocol.js` | Not needed (pnpm native) |

## mrs.developer.json changes

**Current:**
```json
{
  "volto-eea-kitkat": {
    "package": "@eeacms/volto-eea-kitkat",
    "branch": "develop",
    "path": "src"
  }
}
```
Addons are checked out to `src/addons/volto-eea-kitkat/`.

**New:**
```json
{
  "volto-eea-kitkat": {
    "output": "packages",
    "package": "@eeacms/volto-eea-kitkat",
    "branch": "develop",
    "path": "src"
  }
}
```
Addons are checked out to `packages/volto-eea-kitkat/` and automatically resolved as pnpm workspace packages.

## volto.config.js

Addons are registered via `volto.config.js` at the project root (adds to `package.json` `addons` key):

```js
module.exports = {
  addons: [
    '@eeacms/volto-eea-kitkat',
    '@eeacms/volto-redirector',
    // ... all 26 project-level addons
  ],
};
```

The addon chaining mechanism (sub-addons in each addon's `package.json`) remains unchanged — `volto-eea-kitkat` chains 39 sub-addons, etc.