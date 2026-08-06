# 09 — Volto 19 Breaking Changes

Complete list of Volto 19 breaking changes and how we handle each.

## Build tooling

### razzle → @plone/razzle (fork)
**Impact**: Minimal. The fork maintains full API compatibility. The Cookieplone-generated project uses `@plone/razzle` automatically.
**Action**: No manual change needed — handled by Cookieplone template.

### babel-preset-razzle → @plone/babel-preset-razzle
**Impact**: All addons with `babel.config.js` use `const presets = ['razzle']`.
**Action**: Replace with `module.exports = require('@plone/volto/babel')` (works in both V18 + V19).

### razzle-dev-utils → @plone/razzle-dev-utils
**Impact**: 2 addons (`volto-searchlib`, `volto-eea-chatbot`) use `require('razzle-dev-utils/makeLoaderFinder')` in `razzle.extend.js`.
**Action**: Conditional require (try/catch) — works in both V18 + V19.

### razzle-plugin-scss → @plone/volto/webpack-plugins/webpack-scss-plugin
**Impact**: Storybook config (`.storybook/main.js`) references `razzle-plugin-scss`.
**Action**: Cookieplone-generated `.storybook/main.js` has the correct import. No manual change.

## Removed features

### Removed support for loading configuration from project
**Impact**: `src/config.js` no longer works in Volto 19.
**Action**: Already handled — our `src/config.js` is empty (all config in addons).

### Jest removed
**Impact**: Jest is no longer in Volto 19 core.
**Action**: Drop Jest config from addons. Add Vitest config. Skip unit tests on Volto 18 CI pipeline.

### Removed packages (@plone/generator-volto, @plone/volto-guillotina, @plone/volto-testing)
**Impact**: None — we don't use these.
**Action**: None.

### @plone/client removed from monorepo
**Impact**: None — we don't use `@plone/client`.
**Action**: None.

## Language settings

### `defaultLanguage` and `isMultilingual` removed
**Impact**: 3 addons use these settings:
- `volto-eea-website-policy/src/index.js`: sets `config.settings.isMultilingual = true`
- `volto-eea-design-system/src/ui/Header/Header.jsx`: uses `isMultilingual` prop
- `volto-eea-website-theme`: uses `isMultilingual` and `supportedLanguages` in `AlternateHrefLangs.jsx` and `Header.jsx`

**Action**: Read language info from backend API response instead of config settings. `supportedLanguages` still exists but only controls build locales.

### `SITE_DEFAULT_LANGUAGE` env var removed
**Impact**: Default language is now fetched from backend API.
**Action**: Remove any env var references; rely on backend API.

## Image handling

### Raw `<img>` tags restricted
**Impact**: 5 addons have raw `<img>` tags. New ESLint rule prevents them.
**Action**: Replace with `<Image>` component from `@plone/volto/components/theme/Image/Image`. Works in both V18 + V19.

### Image component optimized (original image only if necessary)
**Impact**: The `Image` component no longer always includes the original image URL.
**Action**: If the project relied on original image always being present, add larger scales. Plone 6.2 adds `2k` and `4k` scales.

## Drag and drop

### react-dnd, react-dnd-html5-backend, react-sortable-hoc replaced with dnd-kit
**Impact**: 1 addon (`volto-eea-website-theme`) uses `injectLazyLibs` with `reactDnd` and `reactSortableHOC`.
**Action**: Add `react-dnd` and `react-dnd-html5-backend` as direct dependencies in the addon. Register in `config.settings.loadables`.

## HTTP client

### superagent 3.8.2 → 10.3.0
**Impact**: 5 addons use superagent directly. Stricter error handling, response may not always be present.
**Action**: Add defensive destructuring: `request.end((error, { body } = {}) => { ... })`. Guard redirect headers: `error.response?.headers?.location`.

## UI changes

### showRelatedItems enabled by default
**Impact**: Related items component shown below content by default.
**Action**: Not used in our project. If undesired, set `config.settings.showRelatedItems = false`.

### 401 unauthorized redirects to login page
**Impact**: Anonymous users hitting protected resources are redirected to login.
**Action**: No custom handling in our code. Behavior change is acceptable.

### AutoSave opt-in
**Impact**: AutoSave is now experimental and disabled by default.
**Action**: Not used. If needed, set `config.experimental.saveAsDraft = true`.

### Table block wrapped with containers for horizontal scrolling
**Impact**: Table block markup changes (additional wrapper divs).
**Action**: Check custom CSS that assumes table block is a direct child of content area.

### visually-hidden CSS class
**Impact**: `visually-hidden-volto` renamed to `visually-hidden` (suffix removed).
**Action**: Check if any addon uses `visually-hidden-volto` class. Rename if found.

### AlignWidget and ButtonsWidget moved to @plone/components
**Impact**: These widgets are now Semantic UI-free, using different classNames.
**Action**: If any addon shadows or styles these, adjust imports and CSS.

## pnpm 10

### pnpm 10 no longer runs lifecycle scripts
**Impact**: Packages with `preinstall`/`postinstall` scripts need `onlyBuiltDependencies` config.
**Action**: Cookieplone template includes the correct `pnpm.onlyBuiltDependencies` and `pnpm.ignoredBuiltDependencies` settings.

## Cookies

### react-cookie CookiesProvider required in tests
**Impact**: Components using `useCookies` need explicit `CookiesProvider` in unit tests.
**Action**: Add `CookiesProvider` wrapper in affected Vitest test files. `volto-eea-website-theme/server.jsx` already imports it.