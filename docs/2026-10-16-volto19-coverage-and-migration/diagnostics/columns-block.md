# Diagnosis: Volto 19 CI failure — `toggles reverse wrap …` in `cypress/tests/04-block-columns-settings.cy.js`

Status: **latent/pre-existing test bug**, not caused by the hydration change (`b7c8938`).
The Volto 19 integration stage simply never ran before, so the bug was never surfaced.

---

## 1. Symptom

```
AssertionError: Timed out retrying after 4000ms:
Expected to find element: `input#field-reverseWrap`, but never found it.
  at setCheckbox (.../cypress/tests/04-block-columns-settings.cy.js:78:5)
  at Context.eval (.../cypress/tests/04-block-columns-settings.cy.js:139:4)
```
Fails deterministically on all 4 attempts. Phase-1 of the same test (before the first save) sets the same checkbox successfully.

CI evidence (`/tmp/jenkins-assets/columns-block-attempt4.png`): after `openColumnsSettings()` the right sidebar is
on the **Page** tab (`Page | Block | Order`, `Page` active) showing the *document* schema (Title / Summary / Change
Note). The columns block is rendered ("Columns block" header, "Column A | Column B") but is **not selected**
(no `.block.columnsBlock.selected`, the title block still shows its drag handle). `input#field-reverseWrap` is not
in the DOM.

---

## 2. Root cause

The test helper only switches the sidebar tab; it never *selects* the columns block. On a fresh `/edit` load the
columns block is not the selected block, so its settings sidebar (which is where `input#field-reverseWrap` lives)
is not rendered at all.

Evidence chain:

1. **Test helper** — `cypress/tests/04-block-columns-settings.cy.js:20-22`
   ```js
   const openColumnsSettings = () => {
     cy.get('.columns-block .columns-header').first().click({ force: true });
   };
   ```

2. **What that click actually does** — the header is defined in
   `packages/volto-columns-block/src/ColumnsBlock/ColumnsBlockEdit.jsx:382-385`
   ```jsx
   <div className="columns-header" onClick={this.openColumnsSettings} aria-hidden="true">
   ```
   and `openColumnsSettings` (`ColumnsBlockEdit.jsx:187-194`) only resets local state and changes the tab — it does
   **not** call Volto's `onSelectBlock`:
   ```js
   openColumnsSettings = () => {
     this.setState({ activeColumn: null, colSelections: {}, multiSelected: [] });
     this.props.setSidebarTab(1);
   };
   ```

3. **Selection is a Volto concern** — the block settings form is only rendered behind
   `<SidebarPortal selected={selected}>` (`ColumnsBlockEdit.jsx:509`), and `SidebarPortal` renders `null` whenever the
   block is not selected (`…/core/packages/volto/src/components/manage/Sidebar/SidebarPortal.tsx:19`):
   ```js
   if (!isClient || !selected) { return null; }
   ```
   `selected` comes from Volto's redux form UI state and is only set by the block wrapper's `onClick`
   (`…/Blocks/Block/Edit.jsx:157-166`, `className={cx('block', type, …)}` at `Edit.jsx:195`, where `type` is
   `columnsBlock`, see `…/Blocks/Block/BlocksForm.jsx:359` `selected: selectedBlock === childId`).

4. **Fresh `/edit` selection default** — `Form`'s constructor auto-selects `blocks_layout.items[0]`
   (`…/manage/Form/Form.jsx:225-254`). On this page `items[0]` is the **title** block, so the columns block is
   unselected (matches the screenshot: Page tab + title block drag handle).

5. **Why phase 1 passes** — `addColumnsBlock()` leaves the newly added columns block selected; the header click's
   `setSidebarTab(1)` then reveals the *already-rendered* form. Phase 2 (`cy.visit('/cypress/my-page/edit')`) has no
   prior selection, and nothing in `openColumnsSettings()` establishes it.

6. **Why Volto 18 is green** — the same latent assumption exists there; the block happens to be selected in that
   flow. It is luck, not a different mechanism (the block-selection code is byte-identical between Volto 18.36 and the
   Volto 19.5.0 core in `core/`: diffing `…/Blocks/Block/Edit.jsx`, `BlocksForm.jsx`, `EditBlockWrapper.jsx`,
   `Form.jsx` selection logic shows no behavioural change for selection).

Note on the header's own click-to-select: the header lives inside the Volto block wrapper (`.block.columnsBlock`,
`Edit.jsx:157`) whose `onClick` selects the block, so a bubbling click *should* also select it. Whatever prevents that
in the Volto 19 stage (the screenshot proves the block stayed unselected and the tab stayed at 0), the test never
depends on it in phase 1 — which is exactly why the bug is invisible there. The fix below removes the dependency
entirely.

---

## 3. Minimal fix (test-side — recommended)

Select the columns block explicitly *before* opening settings, by clicking the element Volto puts the
select-block `onClick` on: the Edit wrapper `.block.columnsBlock` (`Edit.jsx:195`), **not** `.columns-header`
and **not** the outer `.block-editor-columnsBlock` (the outer wrapper has no `onClick`; clicking it bubbles *up*,
away from the handler).

`cypress/tests/04-block-columns-settings.cy.js`:

```js
const selectColumnsBlock = () => {
  // Volto renders a block's settings sidebar only while the block is selected
  // (`SidebarPortal` returns null otherwise). `.columns-header` only switches the
  // sidebar tab (ColumnsBlockEdit.openColumnsSettings), it does not select the
  // block; on a fresh /edit load the columns block is not the initially selected
  // block, so select it first.
  cy.get('.block.columnsBlock').first().click({ force: true });
};

const openColumnsSettings = () => {
  selectColumnsBlock();
  cy.get('.columns-block .columns-header').first().click({ force: true });
};
```

Keep the `.columns-header` click: in phase 1 it is what resets `colSelections` after typing inside the columns
(`openColumnsSettings` clears `colSelections`, otherwise the portal is suppressed by the `Object.keys(this.state.colSelections).length === 0` guard at `ColumnsBlockEdit.jsx:507-508`).
Selecting the block also makes Volto set the sidebar tab to the block tab automatically
(`columnsBlock.sidebarTab: 1` in the addon `…/src/ColumnsBlock/index.js`, applied by `…/Blocks/Block/Edit.jsx:103-113`),
so the tab no longer depends on the header click.

Optionally make the failure mode explicit in phase 2 (it currently fails inside `setCheckbox`):

```js
cy.visit('/cypress/my-page/edit');
openColumnsSettings();
cy.get('input#field-reverseWrap').should('exist'); // block settings sidebar is open
setCheckbox('reverseWrap', false);
```

## 3b. Addon-side alternative (arguably better UX)

Make the header a genuine "open this block's settings" affordance by selecting the block itself. `onSelectBlock` is
already passed down to `ColumnsBlockEdit` by Volto (`Edit.jsx` spreads all props onto the block edit component):

```js
// ColumnsBlockEdit.jsx
openColumnsSettings = () => {
  this.setState({ activeColumn: null, colSelections: {}, multiSelected: [] });
  if (!this.props.selected) {
    this.props.onSelectBlock(this.props.block);
  }
  this.props.setSidebarTab(1);
};
```

This fixes the UI for real users too (clicking the columns header on a freshly loaded page currently does nothing),
and it is a smaller behavioural surface than the test change. It is a product change though, so it needs owner
sign-off; the test-side patch alone is sufficient to make CI green.

---

## 4. How to verify

- Local: from `frontend/packages/volto-columns-block`, `make cypress` (or `make start` + `make cypress-run`) and
  observe `04-block-columns-settings.cy.js` → 2 passing.
- CI: re-run the Jenkins `Volto 19` stage (`Integration tests`); the whole cypress suite must be green
  (`All specs passed`, 6 tests) and the `Volto 18` stage must stay green. No docker image or Volto-version change is
  needed.

---

## 5. Scope / risk

- One test file (`cypress/tests/04-block-columns-settings.cy.js`), helper only. No production code touched.
- The `openColumnsSettings` helper is used by tests 1 and 2 of this spec only; test 1 still passes because the extra
  click is a no-op when the block is already selected (`Edit.jsx:160` guards `!this.props.selected`).
- Residual uncertainty: the precise reason the phase-2 `.columns-header` click neither selected the block nor moved
  the sidebar tab in the Volto 19 run is not fully pinned from source (the mechanism should bubble to
  `.block.columnsBlock`). The proposed fix does not rely on it.
