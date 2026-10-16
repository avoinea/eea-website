# Diagnosis: "allows removing a label" fails on the Volto 18 CI stage

## Summary

The failure is **not** caused by a logic difference in the add-on (the add-on
source is identical for the Volto 18 and Volto 19 stages, and the
"adding a label" test passes on both). It is a **Volto-core (volto-slate)
behaviour difference between the two stage base images**, surfaced by commit
`17f98b7` ("load the edit route directly in slateBeforeEach").

* Volto 19 stage base image ships `@plone/volto@19.5.0` (slate-react `0.117.4`) → both tests pass.
* Volto 18 stage base image ships `@plone/volto@18.35.1` (slate-react `0.98.4`) → "adding a label" passes, "removing a label" fails.

Evidence from the CI console (`/tmp/jenkins-assets/slate-label-5-console.txt`):

* Volto 19 stage (lines 1787–1819): `2 passing`, `@plone/volto@19.5.0`.
* Volto 18 stage (lines 2069–2089): `Passing: 1`, `Failing: 1`, `@plone/volto@18.35.1`.
  * `allows adding a label via the editor toolbar` → PASS (testcase line 2070).
  * `allows removing a label` → FAIL (line 2072–2073):
    `Timed out retrying after 4000ms: Expected to find element:
    ".slate-inline-toolbar .button-wrapper a[title=\"Remove label\"]", but never
    found it.` at `cypress/tests/01-slate-label-block.cy.js:44`.
* Screenshot (`/tmp/jenkins-assets/slate-label-attempt4.png`): the slate text is
  visible with the label applied, but **no `.slate-inline-toolbar` is rendered**
  at failure time.

## Where the "Remove label" button comes from (file:line)

* Add-on defines the "Label" button and passes its own i18n messages
  (`edit`/`delete` → "Edit label"/"Remove label"):
  `packages/volto-slate-label/src/editor/index.js:12-38`.
* `makeInlineElementPlugin` registers the Label button on the main toolbar and
  pushes a context-button component into `slate.contextToolbarButtons`
  (`volto18/packages/volto-slate/src/elementEditor/makeInlineElementPlugin.jsx:71-79`).
* The "Remove label" anchor is rendered by the generic context buttons **only
  when `isActiveElement(editor)` is true**
  (`volto18/packages/volto-slate/src/elementEditor/ContextButtons.jsx:24-56`).
* `isActiveElement` = "is the current/saved selection inside a node of type
  `LABEL`" (`volto18/packages/volto-slate/src/elementEditor/utils.js:111-156`)
  → `Editor.nodes(editor, { match: n => n.type === LABEL, at: editor.selection || editor.getSavedSelection() })`.
* The context toolbar is mounted from `InlineToolbar`
  (`volto18/packages/volto-slate/src/editor/ui/InlineToolbar.jsx:47-60` and
  `SlateContextToolbar.jsx:5-13`). The whole `InlineToolbar` is rendered only
  when the block is `selected` (`SlateEditor.jsx` render, `selected ? <InlineToolbar .../> : ''`).

So the "Remove label" anchor exists in the DOM **iff**
`isActiveElement(LABEL)` is true, i.e. iff `editor.selection` (or the saved
selection) resolves to a range inside the freshly-created `label` node. A
missing anchor therefore means the editor's Slate selection does **not** include
the label even though the browser DOM selection visually covers the text.

## Why the test only breaks on the "remove" case

The two tests share the identical prefix
(`cypress/tests/01-slate-label-block.cy.js:10-25` vs `:28-44`):

1. type text, `{selectAll}`, `setSlateCursor('Colorless').dblclick()`,
   `setSlateSelection('Colorless','green')`,
2. click the `a[title="Label"]` toolbar button (`mousedown`, force) → the label
   is inserted (`_insertElement`, `elementEditor/utils.js:15-60`) and the plugin
   sidebar is opened (`show_sidebar_editor: true`).

"adding a label" then just saves and asserts the DOM (`cy.get('label.label')`),
so it never needs the toolbar to re-open. "removing a label" additionally does:

3. `cy.wait(300)` then `cy.setSlateSelection('Colorless','green')` again,
4. `cy.get('... a[title="Remove label"]')` → **fails**.

`cy.setSlateSelection` (`cypress/support/commands.js:388-394`) does
`.focus().click().setSelection(...)`. `setSelection` fires `mousedown`, sets a DOM
range with `setBaseAndExtent`, fires `mouseup` + `selectionchange`. The toolbar
re-opens only if slate-react maps that DOM range back onto `editor.selection`.
Step (4) proves that mapping succeeds **before** the label exists (step 2 finds
`a[title="Label"]`) but fails **after** the label exists — the only structural
change is that the selected text is now wrapped in the add-on's inline `<label>`.

## Root cause

After the label insertion the selection change is **not reflected into
`editor.selection` on Volto 18.35.1**, so `isActiveElement(LABEL)` stays false
and `InlineToolbar`/`SlateContextToolbar` render no "Remove label" button.

The Volto 18.35.1 `@plone/volto-slate` `SlateEditor` is missing the two
selection/focus fixes that the Volto 19.5.0 `SlateEditor` has
(diff of `volto18` 18.35.1 vs `frontend/core` 19.5.0,
`packages/volto-slate/src/editor/SlateEditor.jsx`):

* `handlePointerDown` + `pendingPointerSelection` (restores the pointer
  selection when a block transitions unselected → selected; upstream
  `plone/volto#8406`, shipped in 18.36.0, **not** in 18.35.1), and
* `scheduleFocus` (`requestAnimationFrame`-deferred `ReactEditor.focus`;
  upstream `plone/volto#7477`, 19.x only).

In 18.35.1, `componentDidUpdate` synchronously calls `ReactEditor.focus()` and,
when the block becomes selected while `window.getSelection().type === 'None'`,
force-selects `Editor.start(editor, [])`
(`volto18/packages/volto-slate/src/editor/SlateEditor.jsx` `componentDidUpdate`,
and the `value`-changed branch that does
`Transforms.select(editor, Editor.end(editor, []))`). That stale/collapsed Slate
selection wins over the DOM selection set by the Cypress command, so
`editor.selection` never lands inside the new `label` node.

Why the base image matters and why the add-on is not at fault: the add-on
`src/**` is byte-identical for the two stages, and the "add label" test passes on
18.35.1, so label creation works. The difference is purely slate-react/Volto
core (`0.98.4` vs `0.117.4`). On `0.117.4` (+ `handlePointerDown`) the DOM range
is mapped/retained and the test passes.

### Why `17f98b7` (direct `/edit` load) changes the outcome

`slateBeforeEach` (`cypress/support/e2e.js:36-47`) changed from
`visit('/cypress/my-page')` + `navigate('/cypress/my-page/edit')` to
`visit('/cypress/my-page/edit')`. With the SPA push the edit route (and the
`SlateEditor`) mounted on an already-hydrated, client-only route change; with a
direct `/edit` load the edit form/`SlateEditor` is server-rendered and hydrated,
which changes the block-mount/focus lifecycle (the content block is not
auto-focused by a route transition). That is precisely the code path 18.35.1
handles incorrectly (no `pendingPointerSelection`, synchronous `ReactEditor.focus`)
and 19.5.0 handles correctly, so the same test is green on 19 and red on 18.

## Proposed minimal patch

The cleanest fix is **test-side** (least invasive; the add-on has no logic to
change and Volto core cannot be patched here): make the re-selection use the same
real pointer interaction that already worked in step (2), instead of relying on a
bare DOM `setBaseAndExtent` to update the Slate selection after the label exists.

In `cypress/tests/01-slate-label-block.cy.js`, replace the second
`cy.setSlateSelection('Colorless', 'green');` (line ~41) with the full sequence
used earlier:

```js
    cy.wait(300);

    // Re-open the inline toolbar the same way the first selection did: a real
    // pointer selection, so the Slate selection is restored on both Volto 18
    // and 19 (18.35.1 does not map a bare setBaseAndExtent after re-render).
    cy.setSlateCursor('Colorless').dblclick();
    cy.setSlateSelection('Colorless', 'green');

    cy.get(
      '.slate-inline-toolbar .button-wrapper a[title="Remove label"]',
    ).trigger('mousedown', { force: true });
```

Rationale: `setSlateCursor('Colorless').dblclick()` issues a real `dblclick`
(a genuine pointer event) before `setSelection`, which is the interaction that
opened the toolbar in the working first pass; the `wait(1000)` inside the
command also lets 18.35.1's 200 ms `onSelect` saved-selection sync settle
(`SlateEditor.jsx` `onSelect`).

Note: reverting `17f98b7` (restoring the `visit` + `navigate` flow) is the other
known-good option — that exact configuration passed on both stages at `9eea633`
— but it re-introduces the hydration race the commit was fixing, so it is the
fallback, not the preferred patch.

## Secondary finding — genuine (latent) add-on product bug

`LabelWrapper` drops Slate's `attributes` (including the required `ref` /
`data-slate-node` / `data-slate-inline`) on the plain-label branch:

```jsx
// packages/volto-slate-label/src/editor/LabelWrapper.jsx:44-46
) : (
  <label className={cx(label_type, label_pointing, 'ui label')}>
    {children}
  </label>
)
```

The tooltip branch does spread them on its `<span>`
(`LabelWrapper.jsx:33-39`), and every other inline element in Volto
(`LinkElement` in `volto18/packages/volto-slate/src/editor/plugins/Link/render.jsx:31`
uses `<a {...attributes} ...>`) spreads them. Not registering the inline `<label>`
DOM node with slate-react makes DOM→Slate selection mapping inside a label
fragile and version-dependent — the exact failure mode seen here. This is worth
fixing regardless, as hardening:

```jsx
) : (
  <label {...attributes} className={cx(label_type, label_pointing, 'ui label')}>
    {children}
  </label>
)
```

(both branches: also spread `{...attributes}` on the `<label>` used as the
`Popup` trigger). Lower confidence that this alone flips the 18.35.1 result
(`toSlatePoint` in both 0.98.4 and 0.117.4 resolves the point via the text node),
so treat it as a complementary fix, not a substitute for the test patch.

## How to verify in CI

1. Apply the test-side patch on the Volto 18 stage only (or as a shared patch).
2. Run the failing spec against both base images so the "remove" test executes on
   Volto 18.35.1 and 19.5.0 (e.g. the Jenkins `Testing` parallel stages, or
   locally `make cypress-ci` once a backend is up).
3. Expected: `Slate label` → `2 passing` on **both** stages; the specific
   assertion `cypress/tests/01-slate-label-block.cy.js:44`
   (`a[title="Remove label"]`) resolves.
4. If it still fails on 18.35.1, add the `LabelWrapper` `{...attributes}` fix and
   re-run; that isolates whether the missing element registration contributes.
5. Also re-check the "adding a label" test and the `#toolbar-save` / `label.label`
   assertions to confirm no regression from the added `dblclick`.

## Confidence / open items

* Confirmed by evidence: failure location/assertion, test pass/fail split,
  toolbar absent from the DOM, add-on source identical, missing Volto-18 focus
  fixes.
* Most-likely-but-not-100 %-verified: the exact slate-react 0.98.4 line that
  drops the selection (needs a live Volto 18.35.1 reproduction, which requires a
  Docker build). The proposed test patch is a low-risk superset that exercises
  the working pointer path and should be validated in CI.
