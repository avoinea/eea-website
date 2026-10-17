# volto-block-toc — sync with develop: V18 regression (open)

Repo: `eea/volto-block-toc`, branch `volto19`, PR #53 (`chore: Volto 19 support` → `develop`).
Related: `volto-block-data-table` PR #20 (same sync, **fully green**) — see REPORT.md.

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

## Root cause (working hypothesis)

On Volto 18.35.1 `@plone/volto-slate` `SlateEditor.componentDidUpdate` calls `ReactEditor.focus()`
synchronously and force-selects `Editor.start(editor)`, and the `value`-changed branch does
`Transforms.select(editor, Editor.end(editor, []))`. Volto 19.5.0 has `handlePointerDown` +
`pendingPointerSelection` (upstream plone/volto#8406, shipped in **18.36.0**, absent here) and
`scheduleFocus` (rAF-deferred focus), which is why the same test is green on 19 and red on 18 —
this is the same core bug diagnosed for `volto-slate-label`
(`docs/2026-10-16-volto19-coverage-and-migration/diagnostics/slate-label.md`).

Develop's new `TocView` adds a store subscription (`useSelector` with
`config.settings.toc.contextSelector`) and renders a placeholder **instead of** the variation
renderer while the ToC is empty. The variation switch + the extra render path is what now trips
18.35.1's synchronous focus/selection: the block re-renders while the heading is being typed and the
Slate value snaps back to the pre-typing state.

Not verified: the exact re-render trigger (whether `contextSelector` is configured by another add-on
inside the CI container, which would make `shallowEqual` fail on a fresh nested object and re-render
the ToC block on every store dispatch).

## Options (decision pending)

- **(A)** Leave PR #53 red on the Volto 18 stage, documented here. V19 is green and the PR is
  mergeable; the V18 stage only guards the "previous Volto" support matrix.
- **(B)** Ask the feature author (Laszlo Cseh) to make the ToC block render less aggressively on
  update (e.g. do not subscribe to the store when `settings.toc.contextSelector` is undefined).
- **(C)** Product change in `TocView.jsx` from our side — needs the user's explicit approval
  (campaign rule: no product code without approval).

Test-side hardening was tried first (2 CI cycles) and is **not** sufficient: the text itself is lost,
so no selector change can fix it. The stricter assertion from `bb7d802` is kept — it must not go
silent again.

## Environment notes

- The Volto 18 stage of the pipeline finishes ~11 min after the push; the failure can be read from
  the aggregate `Jenkins` check-run `output.text`/`output.summary` (`gh api`), no Jenkins login
  needed (JUnit XML with test names and assertion messages is embedded).
- Force-push (`--force-with-lease`) was used once, to fold the failed first attempt into the final
  fix commit while the remote still pointed at it.
