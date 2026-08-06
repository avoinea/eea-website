# 05 — Addon Migration

## Strategy: Phased, Dual-Compatible

All 64 EEA Volto add-ons must work on **both Volto 18 and Volto 19** during the transition. Addons are fixed in backward-compatible ways first, then the project is upgraded, then per-addon pnpm migration happens.

## Addon inventory

- **26 published addons** (in `package.json` dependencies, released to npm)
- **64 local dev addons** (in `mrs.developer.json`, checked out to `src/addons/`)
- Significant overlap: the 26 published addons are also in the 64 local dev addons
- `volto-eea-kitkat` is a bundle addon that chains 39 sub-addons

## Breaking change impact

| Change | Affected addons | Details |
|---|---|---|
| Raw `<img>` → `<Image>` component | 5 | volto-eea-chatbot (tests), volto-eea-design-system (stories), volto-eea-website-theme (Image.jsx, LeadImage/Edit.jsx, Image/Edit.jsx), volto-nextcloud-video-block (tests), volto-object-widget (tests) |
| Razzle internal imports | 0 | None — clean |
| `razzle-dev-utils` → `@plone/razzle-dev-utils` | 2 | volto-searchlib, volto-eea-chatbot (via `razzle.extend.js`) |
| `babel-preset-razzle` → `@plone/babel-preset-razzle` | All addons with `babel.config.js` | Currently use `['razzle']` |
| `react-dnd` / `react-sortable-hoc` via `injectLazyLibs` | 1 | volto-eea-website-theme (ContentsItem.jsx) |
| superagent 3 → 10 | 5 | volto-datablocks, volto-datahub, volto-eea-chatbot, volto-eea-website-theme, volto-plotlycharts |
| Language settings removal | 3 | volto-eea-website-policy, volto-eea-design-system, volto-eea-website-theme |
| Jest → Vitest | All addons with tests | Drop Jest config, add Vitest config |

## Dual-compatibility approach

### `babel.config.js` (all addons)

**Before:** `const presets = ['razzle'];`
**After:** `module.exports = require('@plone/volto/babel');`

This works in both Volto 18 and 19 — the project's `babel.config.js` already uses this pattern.

### `razzle.extend.js` (2 addons)

Conditional require:
```js
let makeLoaderFinder;
try {
  makeLoaderFinder = require('@plone/razzle-dev-utils/makeLoaderFinder');
} catch {
  makeLoaderFinder = require('razzle-dev-utils/makeLoaderFinder');
}
```

### Language settings (3 addons)

Volto 19 removes `defaultLanguage` and `isMultilingual` from config settings — they're now fetched from the backend API. `supportedLanguages` still exists but only controls which locales are in the build.

Affected files:
- `volto-eea-website-policy/src/index.js` — sets `config.settings.isMultilingual` and `config.settings.defaultLanguage`
- `volto-eea-design-system/src/ui/Header/Header.jsx` — uses `isMultilingual` prop
- `volto-eea-website-theme` — uses `config.settings.isMultilingual` and `config.settings.supportedLanguages` in `AlternateHrefLangs.jsx` and `Header.jsx`

These need to read language info from the backend API response instead of config settings. The `isMultilingual` info is available from the backend's `@controlpanel` or site properties API response.

### superagent (5 addons)

Volto 19 upgrades superagent from 3.8.2 to 10.3.0. Key changes:
- Stricter error handling — response object may not always be present
- Redirect handling — `error.response.headers.location` may not exist

Fix pattern (backward-compatible):
```js
// Before
request.end((error, { body }) => { ... });

// After (works in both v3 and v10)
request.end((error, { body } = {}) => { ... });
```

### `<img>` → `<Image>` (5 addons)

Import the Image component from Volto:
```js
import Image from '@plone/volto/components/theme/Image/Image';
// Replace <img src={url} alt={alt} /> with <Image src={url} alt={alt} />
```

This works in both Volto 18 and 19 (the Image component exists since Volto 17).

### react-dnd / react-sortable-hoc (1 addon)

`volto-eea-website-theme` uses `injectLazyLibs` with `reactDnd` and `reactSortableHOC`. In Volto 19 these are replaced with `dnd-kit` and no longer available via `injectLazyLibs`.

Options:
1. Add `react-dnd` and `react-sortable-hoc` as direct dependencies in the addon's `package.json` and register them in `config.settings.loadables`
2. Migrate the shadowed component to use `dnd-kit`

Option 1 is simpler and maintains dual compatibility. The shadowed `ContentsItem.jsx` would need:
```js
import loadable from '@loadable/component';
config.settings.loadables.reactDnd = loadable.lib(() => import('react-dnd'));
config.settings.loadables.reactDndHtml5Backend = loadable.lib(() => import('react-dnd-html5-backend'));
```

## Per-addon pnpm migration (Phase 4)

After the project is upgraded to Volto 19:
1. Update each addon's `package.json` — pnpm-compatible devDependencies
2. Drop Jest config, add `vitest.config.mjs`
3. Publish new npm versions of the 26 published addons
4. Update `mrs.developer.json` branches to point to Volto 19-compatible branches/tags

## Jenkins dual CI

Each addon's Jenkinsfile has two testing pipelines:

| Pipeline | Unit tests | Acceptance tests |
|---|---|---|
| Volto 18 (existing) | ❌ Skipped | ✅ Cypress |
| Volto 19 (new) | ✅ Vitest | ✅ Cypress |