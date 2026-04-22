---
name: volto-cypress-writer
description: Cypress E2E writing and maintenance for Plone Volto add-ons under frontend/src/addons, including UI-first setup, selectors, helpers, flake reduction, and add-on Cypress commands.
---

# Volto Cypress Writer

Use this skill when writing, updating, reviewing, or debugging Cypress tests for Volto add-ons in `frontend/src/addons/*`.

## Workflow

1. Inspect the target add-on before editing:
   - `cypress.config.js`
   - `cypress/support/e2e.js`
   - `cypress/support/commands.js`
   - existing `cypress/support/*.js` helpers
   - nearby `cypress/e2e/*.cy.js` specs
2. Follow the add-on's local file layout, naming, and helper style.
3. Put specs in `frontend/src/addons/<addon>/cypress/e2e/*.cy.js`.
4. Put reusable feature helpers in `cypress/support/<feature>.js`.
5. Keep global Cypress commands minimal; prefer imported helpers for feature-specific flows.
6. Improve fragile selectors and waits when touching nearby test code.

## UI-First Rule

New tests must set up state, navigate, edit, save, and assert through the browser UI.

- Do not add or call `cy.request()` setup helpers for new tests unless the user explicitly asks for legacy/API-seeded style.
- Existing REST helpers such as `autologin`, `createContent`, and `removeContent` may be read for context, but do not copy them into new UI-first flows.
- Use the UI for the behavior under test even when an older suite uses API shortcuts.
- If UI-only setup is impractical for a narrow reason, stop and explain the constraint before changing the approach.

## Selectors

- Prefer stable `data-cy` or `data-testid` selectors.
- If stable selectors are missing and component edits are in scope, add explicit test selectors to the component instead of relying on DOM shape.
- Use role, label, placeholder, or visible text when they describe the user's intent.
- Avoid positional selectors like `:nth-child()` and style-driven selectors like `.ui.basic.icon.button...`.
- If Volto or Semantic UI markup forces a fragile selector, hide it behind a named helper such as `openBlockChooser()` or `saveCurrentPage()`.
- Keep assertions user-visible where possible: URL, heading, block text, saved view output, modal state, toolbar state, validation message.

## Reliability

- Each spec must pass independently; do not depend on previous tests.
- Use `beforeEach` for browser state and content setup.
- Prefer Cypress retry-ability: `cy.get(...).should(...)`, `cy.contains(...).should(...)`, and URL assertions.
- Prefer `cy.intercept().as()` and `cy.wait('@alias')` for network-dependent transitions.
- Avoid arbitrary `cy.wait(ms)`. If a Volto editor limitation requires one, keep it local and add a short comment explaining why.
- Split chains after actions before assertions:

```js
cy.get('[data-cy="toolbar-save"]').click();
cy.get('[data-cy="view-page"]').should('be.visible');
```

- Avoid `{ force: true }` unless Volto overlays or hidden controls make it unavoidable; explain the reason in a helper or nearby comment.
- Do not suppress uncaught exceptions broadly unless the test target is a known third-party integration and the user accepts that tradeoff.

## Volto Add-on Patterns

- Add-on Cypress config usually sets `baseUrl: 'http://localhost:3000'` and passes Plone API settings through `CYPRESS_API_PATH`, `RAZZLE_DEV_PROXY_API_PATH`, or `RAZZLE_INTERNAL_API_PATH`.
- Add-on tests normally live beside the add-on, not in root `frontend/cypress/e2e`.
- Root acceptance tests in `frontend/cypress/e2e` are for broader site checks; use add-on-level suites for add-on behavior.
- For block tests, cover the edit flow and the saved view:
  - create or navigate to a page through the UI
  - add the block through the block chooser
  - configure the fields through the sidebar or inline editor
  - save
  - assert the view mode output
- For editor interactions, prefer existing Slate helpers if the add-on already has them. Add focused helpers only when they reduce repeated low-level selection/type logic.

## Commands

Run commands from `frontend/src/addons/<addon>` when the add-on has its own Makefile:

```sh
make
make start
make cypress-run
make cypress-open
```

Useful alternatives:

```sh
VOLTO_VERSION=17 make
VOLTO_VERSION=17 make start
make lint
make test
```

Root frontend checks are run from `frontend/`:

```sh
make cypress
yarn cypress:run
make cypress-local
```

Use the smallest relevant command for verification. For a Cypress-only change, prefer the target add-on's `make cypress-run`.

## Review Checklist

- The test exercises the feature like a user, not by mutating backend state.
- Selectors are stable or wrapped in named helpers.
- The test asserts both edit-time behavior and saved output when relevant.
- The suite can run test cases independently.
- Network or async transitions wait on observable conditions, not fixed sleeps.
- Helpers are local to the add-on unless multiple specs in the add-on need them.
- The command used to verify is reported back to the user.
