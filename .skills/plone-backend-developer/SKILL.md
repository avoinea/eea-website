---
name: plone-backend-developer
description: Senior Plone backend development for the EEA website. Use when working on Plone 6.1 server behavior, backend add-ons, Python code, configuration in `backend/develop/`, or when debugging backend bugs and tests.
---

# Plone Backend Developer

## Overview

Implement and debug Plone 6 backend changes with a reliable workflow and repo-specific conventions. Consult `references/eea-website-backend.md` for environment details and commands.

## Core workflow

1. Confirm the failing endpoint, request path, and expected behavior.
2. Locate the relevant package in `backend/develop/sources.ini` or installed add-ons.
3. Reproduce locally; add minimal logging only when needed.
4. Apply the fix in the add-on or config, then restart Plone (or use reload helpers when appropriate).
5. Validate with a targeted `zope-testrunner` invocation or manual verification.

## Common tasks

- Add or update a backend add-on in `backend/develop/` and run `make develop` to refresh sources.
- Adjust Plone configuration and verify the app starts with `make start` or `make relstorage`.
- Investigate errors in `bin/runwsgi` output and trace back to the relevant add-on module.

## Good practices

- Restart Plone after Python changes; hot reload is not available.
- Use the reload endpoint (`@@reload`) only for quick iteration, then restart for confirmation.
- Keep changes small and add targeted tests for regressions.

## Repo context

Use `references/eea-website-backend.md` for environment details, commands, and dev notes.
