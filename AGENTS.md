# AGENTS.md

## AI Assistant Instructions

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## Skills
- `plone-frontend-developer`: Senior Plone Volto frontend engineering for debugging add-ons, fixing UI bugs, and handling Plone 6 + Volto frontend tasks. (path: .agents/skills/plone-frontend-developer/SKILL.md)
- `plone-backend-developer`: Plone backend development for server behavior, add-ons, configuration, and tests in `backend/develop/`. (path: .agents/skills/plone-backend-developer/SKILL.md)
- `volto-cypress-writer`: Cypress E2E writing and maintenance for Volto add-ons in `frontend/src/addons`, with UI-first setup and project-specific commands. (path: .agents/skills/volto-cypress-writer/SKILL.md)
- `caveman`: Ultra-compressed communication mode for token-efficient, terse responses with adjustable intensity levels. (path: .agents/skills/caveman/SKILL.md)
- `grill-me`: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. (path: .agents/skills/grill-me/SKILL.md)
- `handoff`: Compact the current conversation into a handoff document for another agent to pick up. (path: .agents/skills/handoff/SKILL.md)

## Repo Overview
- `.agents/skills/`: Local agent skills for this repo.
- `.venv/`: Local Python virtual environment for tooling (use `.venv/bin/python`).
- `volto18/`: Volto 18 Core code
- `volto17/`: Volto 17 Core code
- `frontend/`: Volto frontend for Plone 6 (cloned during `make init`).
- `backend/`: Plone 6 backend (development in `backend/develop/`, cloned during `make init`).

## Frontend Conventions
- Add-ons live in `frontend/src/addons/` and are registered in `frontend/package.json`.
- Preferred runtime: Node 22 with Yarn 3.2.3 (see `engines` in `frontend/package.json`).

## Frontend Commands
- Dev: `make start` (run from `frontend/`).
- Add-on dev sync: `make develop` (uses `mrs.developer.json`).
- Tests: `make test src/addons/<addon>` for Jest; Cypress via `make cypress` or `yarn cypress:run`.

## Backend Conventions
- Dev workflow runs from `backend/develop/` with `make` then `make start`.
- Hot reload is not available;

## Backend Tests
- Run `bin/zope-testrunner --test-path sources/<package>` from `backend/develop/`.

## Bootstrap
- Run `make init` from the repo root. It also clones `volto17/` (`https://github.com/plone/volto` branch `17.x.x`) and `volto18/` (`https://github.com/plone/volto` branch `18.x.x`) if missing.
- Provide frontend/backend GitHub repo URLs when prompted (or pass `FRONTEND_REPO`/`BACKEND_REPO` env vars).
- Optional Volto override env vars: `VOLTO_REPO`, `VOLTO17_BRANCH`, `VOLTO18_BRANCH`.
