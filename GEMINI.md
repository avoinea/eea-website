# EEA Plone Monorepo (Plone 6 / Volto)

## AI Assistant Instructions

- **Always use Context7** when you need library/API documentation, code generation, setup or configuration steps - do this proactively without waiting for explicit requests.

## Project Overview

This is a generic monorepo for EEA (European Environment Agency) Plone projects, built on Plone 6 and Volto. The project is structured as a monorepo that composes the frontend and backend applications from separate Git repositories.

*   **Backend:** A Plone 6 application. The development happens in the `backend/` directory, which is cloned via `make init`.
*   **Frontend:** A Volto (React) application. The development happens in the `frontend/` directory, which is cloned via `make init`.
*   **Skills:** The `.skills/` directory contains context and instructions for AI agents on how to work with this specific repository, separated by roles (backend, frontend).

The architecture emphasizes separation of concerns, with a headless Plone CMS providing content and a modern React-based frontend consuming it.

## Building and Running

### Initial Setup

To clone the necessary `frontend` and `backend` repositories, run the following command from the project root:

```sh
make init
```

You'll be prompted for the frontend and backend GitHub repo URLs. For non-interactive use:

```sh
FRONTEND_REPO=<url> BACKEND_REPO=<url> make init
```

Use the repository virtualenv for Python tooling:

```sh
.venv/bin/python
```

### Backend Commands (run from `/backend/develop`)

*   **Build:** `make`
*   **Start (Standalone):** `make start`
*   **Start (RelStorage/PostgreSQL):** `make relstorage`
*   **Run tests:** `bin/zope-testrunner --test-path sources/<package>`

*Note: The backend does not have hot-reloading. The server must be restarted to see changes.*

### Frontend Commands (run from `/frontend`)

*   **Start Dev Server:** `make start` or `yarn start`
*   **Sync Add-on Development:** `make develop`
*   **Run Jest Tests:** `make test src/addons/<addon>`
*   **Run Cypress Tests:** `make cypress` or `yarn cypress:run`

*Note: The frontend uses hot-reloading for most changes. Shadowing customizations in `frontend/src/customizations/` requires a server restart.*

## Development Conventions

### Backend (Plone)

*   Backend add-ons are located in `backend/develop/sources/`.
*   Configuration is managed within the `backend/develop/` directory.
*   Use the `@@reload` browser view for quick Python iterations, but always restart the server to confirm changes.
*   New features or bug fixes should be accompanied by targeted tests.

### Frontend (Volto)

*   Custom Volto add-ons are located in `frontend/src/addons/` and are registered as workspace packages in `frontend/package.json`.
*   Shadowed component customizations are placed in `frontend/src/customizations/`.
*   The project uses design tokens for styling to maintain consistency.
*   Internationalization (i18n) is managed with `make i18n` after adding new message strings.
*   Linting should be run via `make lint` within the specific add-on being modified.
