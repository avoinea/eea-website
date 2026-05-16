---
name: plone-frontend-developer
description: Senior Plone Volto frontend engineering for debugging Volto add-ons, fixing UI bugs, adjusting blocks/components, and handling all Plone 6.1 + Volto 17 frontend tasks (theme, routing, tokens, build/test issues). Use when the request involves Volto/Plone frontend behavior, add-on code, or UI fixes.
---

# Plone Frontend Developer

## Overview

Diagnose and fix Volto/Plone frontend issues with a production-grade workflow. Use repo-specific guidance from `references/eea-website-frontend.md`.

## Core workflow

1. Clarify the symptom, the affected URL, and the expected behavior. Note the language/locale if the site is multilingual.
2. Locate the code path in `frontend/src/` or a local add-on in `frontend/src/addons/`.
3. Reproduce and isolate: use minimal changes, add short-lived logs if needed, and confirm the exact component/block responsible.
4. Implement the fix in the most appropriate layer (add-on). Favor tokenized values and shared helpers when updating styles.
5. Verify with the smallest relevant check (unit test, lint, or targeted runtime verification), and note any follow-ups.

## Common tasks

- Debugging a Volto add-on: find the add-on entry in `frontend/package.json` and trace the component in `frontend/src/addons/`.
- Token updates: replace hard-coded values with design tokens and update shared theme/config entries to keep consistency.
- Multilingual links: check locale-aware routing and URL generation before hardcoding language paths.

## Good practices

- For new features, add or update Cypress and/or Jest coverage.
- When adding Cypress DO NOT use API calls, cypress should test the UI as a user would interact with it, so use the UI to set up the test state.
- When modifying add-ons, run `make lint` inside the add-on folder.
- Add-ons live in `frontend/src/addons/`; check each add-on's `make help` for available targets.
- When developing and add-on, start Volto 18 dev environment with `make; make start` in the add-on folder for faster feedback loops.
- To start Volto 17 dev environment, run `VOLTO_VERSION=17 make; make start` in the add-on folder.
- To run cypress tests, use `make cypress=run` in the add-on folder.
- After defining i18n messages, run `make i18n`.
- Use Playwright MCP for quick UI verification when needed; Volto hot reload covers most changes.
- If adding new shadow customizations, ask to restart the frontend server.

## Repo context

Use `references/eea-website-frontend.md` for environment details, repo layout, and commands.

## Notes

- Prefer readable, minimal diffs and avoid refactors unless they are required for the fix.
- Keep temporary logs out of the final patch.
- When unsure about conventions, inspect nearby code or similar components in this repo.
