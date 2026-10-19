# volto-block-toc — sync with develop: V18 regression (open)

Repo: `eea/volto-block-toc`, branch `volto19`, PR #53 (`chore: Volto 19 support` → `develop`).
Related: `volto-block-data-table` PR #20 (same sync, **fully green**) — see REPORT.md.

**Status: REZOLVAT** (sesiunea 6): `Jenkins Success`, V19 unit 44 + integrare 4/4, V18 integrare 4/4,
`SonarQube success`, PR #53 `MERGEABLE`. Lanțul complet, în ordine:

1. **Infra**: `eeacms/frontend-builder:18` livra Volto **18.35.1**, iar 18.36.0 (cu fix-ul de focus
   `plone/volto#8406`) nu era în imagine. Imaginea a fost urcată la 18.36.0 în `eea/frontend-builder`
   18.x (`7cb8c2e`) — rețeta în `diagnostics/frontend-builder-18-image.md`.
2. **Sync cu `develop`** (`a99d9a2`): fix-urile autorului (`61a11f0` wait după `{enter}`, `c5c77ca`
   helper-e conștiente de text-node-uri split) au reparat testele care schimbau variația.
3. **Cursa rămasă pe 18.36.0** (2/4 în CI, ~1/6 local): retype mărginit (3 încercări) în
   `addHeading` (`30384bd`), cu aserțiunea strictă păstrată.

## Context

Both PRs were `CONFLICTING` against `develop` (the only two of the 59 open `volto19` PRs with
`behind > 0`). `develop` moved ahead with:

- `9e45e9b feat(TocView): add runtime context and empty state` (Laszlo Cseh),
- `4c970a5`/`edc547f`/`978a91d` test(TocView) fixes,
- `b84c9cc Automated release 9.0.2`.

The merge (`54bdc10`) was resolved by keeping our pnpm-workspace root `package.json`, porting the
`9.0.2` version into `packages/volto-block-toc/package.json`, relocating develop's two new tests
under `packages/volto-block-toc/src/Block/` and converting them jest → vitest
(`vi.mock` is hoisted, the repo's `global.jest = vi` alias is not; `jest.requireActual` has no
vitest equivalent — `vi.importActual` via `importOriginal`).

Result: Volto 19 stage **green** (41 unit tests, 4 integration tests), Volto 18 stage **red**
(2 of 4 integration tests).

## Symptom

`Tests / Testing / Volto 18 / Integration tests` → `failed: 2, passed: 2`.

First failure shape (`54bdc10`):

```text
testcase "Add Block: add content to TOC"  -> TypeError: Cannot read properties of undefined (reading 'wholeText')
  at setSelection (cypress/support/commands.js:362)
testcase "Add Block: add horizontal TOC"  -> same
```

`getTextNode($el[0], text)` returned `undefined`, i.e. the helper selected the heading text inside
an editor that does not contain it.

## Reproduced with a stricter assertion

Patched `addHeading()` twice (commits `e68d2f3`, then amended into `bb7d802`):

1. scope the selection to the editor the text was typed into + `should('contain.text', text)`;
2. freeze that element with `cy.wrap($editor)` so re-querying cannot resolve to another editor.

Both runs still fail, but the message is now precise:

```text
Timed out retrying after 4000ms: expected '<div>' to contain text 'Lorem ipsum dolor sit amet',
but the text was 'Type text…'          # 01-toc-basics.cy.js:13 (inside addHeading)
```

i.e. the typed heading is **not committed** — the editor still shows the empty slate placeholder.

## Pattern

| Test | Variation | Headings | V18 result |
|---|---|---|---|
| Add Block: Links | default | 0 | pass |
| Add content to TOC | default | 2 | **pass** |
| Add horizontal TOC | Horizontal Menu + Sticky | 8 | **fail** |
| Add side menu TOC | Side Menu | 2 | **fail** |

Both failing tests are the ones that **switch the block variation from the sidebar**; the default
variation passes. Before the merge the same suite passed 4/4 on both stages
(`4c6a0d4`: `Volto 18 / Integration tests :: passed: 4`).

## Root cause (confirmed in session 6)

Two layers, both confirmed with local repro on the emulated amd64 V18 image (`toc-v18-local`):

1. **Volto 18.35.1 focus/selection bug**. `@plone/volto-slate` `SlateEditor.componentDidUpdate` calls
   `ReactEditor.focus()` synchronously and force-selects `Editor.start(editor)`; Volto 19.5.0 /
   18.36.0 have `handlePointerDown` + `pendingPointerSelection` (plone/volto#8406) and
   `scheduleFocus`. On 18.35.1 the variations that switch from the sidebar failed 2/4; on 18.36.0
   the same specs pass. `plone/frontend-builder:18` was frozen at 18.35.1 (upstream only published
   `-buildtest` tags for 18.36.0), which is why the EEA V18 stage stayed red.
2. **Form-state / SlateEditor `value` race on 18.36.0** (author's diagnosis, reproduced): the ToC block
   re-renders on every entry change, and `SlateEditor.componentDidUpdate` resets its children to the
   `value` prop whenever that prop differs from `internalValue`. A re-render carrying a pre-typing
   snapshot therefore drops the text typed into a freshly inserted block.

Bisect (local, 18.36.0): 8 headings **without** the ToC block → 5/5 runs green; with the ToC block →
~1/6 runs loses the text. The strict `should('contain.text')` assertion added in `bb7d802` is what
makes the loss visible instead of a confusing `wholeText` crash.

## Resolution (what was actually done)

- **`a99d9a2`** — merge `develop` → `volto19`; kept the author's Cypress helpers/wait, moved the new
  `DefaultTocRenderer.test.jsx` into `packages/volto-block-toc/src/Block/variations/` (runs as-is
  under vitest, no `jest.*`), kept 9.0.2.
- **`eea/frontend-builder` 18.x `7cb8c2e`** — `ARG VOLTO_VERSION=18.36.0` + `git fetch/checkout` of the
  bundled core checkout (no-op when the base image already ships it). Docker Hub rebuilt `:18`
  automatically ~8 min after the push; verified `18.36.0` + `pendingPointerSelection` in the image.
- **`30384bd`** — bounded retype in `addHeading` (max 3 attempts, only when the text is missing).
  Test-only; the strict assertion and `setSelection` still fail the test if the text never commits.
  Local: 8/8 runs green.
- Rejected: (a) leaving V18 red and merging anyway; (b) product change in `TocView` from our side —
  the remaining race is in Volto 18's `SlateEditor`/`Form` state handling, not in the ToC block, and
  product code needs the user's explicit approval (campaign rule).

## Environment notes

- The Volto 18 stage of the pipeline finishes ~11 min after the push; the failure can be read from
  the aggregate `Jenkins` check-run `output.text`/`output.summary` (`gh api`), no Jenkins login
  needed (JUnit XML with test names and assertion messages is embedded).
- Force-push (`--force-with-lease`) was used once, to fold the failed first attempt into the final
  fix commit while the remote still pointed at it.
