# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## AI Assistant Instructions

- **Always use Context7 MCP** when you need library/API documentation, code generation, setup or configuration steps - do this proactively without waiting for explicit requests.

## Project Overview

This is a generic EEA (European Environment Agency) Plone monorepo built with **Plone 6** and **Volto**. The repository contains both frontend (Volto/React) and backend (Plone/Python) components in a monorepo structure.

- **Frontend**: Modern React-based frontend using Volto
- **Backend**: Plone 6 CMS with Python 3.10-3.12
- **Architecture**: Headless CMS with REST API communication between frontend and backend

## Repository Structure

```
repo-root/
├── frontend/           # Volto React frontend
│   ├── src/
│   │   ├── addons/    # Local workspace add-ons (development versions)
│   │   ├── customizations/  # Component shadowing/overrides
│   │   ├── config.js  # Volto configuration (mostly delegated to add-ons)
│   │   └── routes.js  # Custom routing
│   ├── package.json   # Dependencies, scripts, and addon registry
│   ├── jsconfig.json  # TypeScript path mappings for add-ons
│   └── mrs.developer.json  # Add-on development configuration
│
├── backend/
│   └── develop/       # Plone backend development environment
│       ├── sources/   # Python add-ons checked out for development
│       ├── sources.ini  # mxdev configuration for backend add-ons
│       └── bin/       # Python executables (after installation)
│
└── .skills/           # Local Claude Code skills for this project
```

## Bootstrap

Run from repo root to clone the frontend/backend and set up `.venv`:

```bash
make init
```

This command will:
1. Clone the frontend repository if not present
2. Clone the backend repository if not present
3. Create a Python virtualenv at `.venv/` for monorepo-level tooling
4. Install basic Python dependencies (pip, pyyaml)

You'll be prompted for the frontend and backend GitHub repo URLs. For non-interactive use:

```bash
FRONTEND_REPO=<url> BACKEND_REPO=<url> make init
```

### Root-Level Make Targets

These convenient targets can be run from the repo root to start services:

```bash
make frontend-start      # Start Volto dev server (same as cd frontend && make start)
make backend-start       # Start Plone standalone (same as cd backend/develop && make start)
make frontend-relstorage # Start Volto with RelStorage backend
make backend-relstorage  # Start Plone with PostgreSQL RelStorage
make help               # Show available targets
```

## Frontend Development

### Initial Setup

```bash
cd frontend
nvm use 20  # Node 20 preferred (18 also supported)
yarn install
```

### Common Commands (from `frontend/`)

```bash
# Development
make start              # Start dev server at http://localhost:3000
yarn start              # Alternative way to start dev server
make develop            # Sync add-ons from mrs.developer.json to src/addons/

# Building
make build              # Production build
yarn build

# Code Quality
make lint               # Lint JavaScript/TypeScript
yarn lint:fix           # Auto-fix linting issues
make prettier           # Check code formatting
yarn prettier:fix       # Auto-fix formatting
yarn stylelint          # Lint CSS/LESS
yarn stylelint:fix      # Auto-fix style issues
yarn typecheck          # Run TypeScript type checking

# Testing
yarn test               # Run Jest tests
make test src/addons/<addon-name>  # Test specific add-on
make cypress            # Run Cypress e2e tests (staging environment)
make cypress-open       # Open Cypress interactive UI
make cypress-local      # Run Cypress against localhost:3000

# Add-on Development
make develop            # Pull/sync add-ons marked with "develop": true
make update             # Git pull all add-ons in src/addons/
make status             # Check git status of all add-ons
make pull               # Git pull all add-ons

# Internationalization
yarn i18n               # Extract and compile i18n messages
```

### Working with Add-ons

The project uses **workspace add-ons** in `frontend/src/addons/`. See `frontend/package.json` for the project-specific add-on list.

**Add-on Development Workflow:**

1. Enable development mode in `mrs.developer.json` by setting `"develop": true`
2. Run `make develop` to checkout the add-on source to `src/addons/`
3. Changes in `src/addons/<addon>` are immediately reflected (hot reload)
4. Each add-on has its own Makefile with targets like `make lint`, `make test`, `make cypress-run`

**Component Shadowing/Customization:**

Volto allows overriding core or add-on components via `src/customizations/`:
- Create a file with the same path structure as the original
- Example: Override `@plone/volto/components/theme/Navigation/Navigation.jsx` by creating `src/customizations/components/theme/Navigation/Navigation.jsx`
- **Important**: Requires server restart to detect new customization files (hot reload works for existing files)

### Frontend Architecture Notes

- **Configuration**: Most config happens in add-ons, not in `src/config.js`
- **Theme**: Uses the project theme add-on and design tokens as configured
- **State Management**: Redux (inherited from Volto core)
- **Styling**: Semantic UI + LESS with custom theme overrides
- **Build Tool**: Razzle (webpack-based)
- **Package Manager**: Yarn 3.2.3 (Berry) with workspace protocol

### Running Against Different Backends

Check `frontend/Makefile` for project-specific targets (commonly `make start` and `make relstorage`).

## Backend Development

### Initial Setup

```bash
cd backend/develop
make                    # Bootstrap, install Plone, and develop add-ons
make start              # Start Plone at http://localhost:8080
```

Default credentials: `admin:admin`

### Common Commands (from `backend/develop/`)

```bash
# Setup
make bootstrap          # Create Python virtualenv and install tools
make install            # Install Plone and dependencies
make develop            # Checkout and install add-ons from sources.ini

# Running
make start              # Start standalone Plone (FileStorage)
make relstorage         # Start with PostgreSQL RelStorage (requires docker compose up -d)

# Development
make status             # Check git status of all sources
make pull               # Git pull all sources
make release            # Show release candidates

# Testing
bin/zope-testrunner --test-path sources/<package-name>
# Example: bin/zope-testrunner --test-path sources/eea.kitkat
```

### Backend Architecture Notes

- **Add-on Management**: Uses `mxdev` (replacement for mr.developer)
- **Configuration**: Add-ons listed in `sources.ini` are checked out to `sources/`
- **Hot Reload**: Not available by default. After Python changes, restart Plone or use `plone.reload` at http://localhost:8080/@@reload
- **Testing**: Uses `zope.testrunner` with `plone.app.testing`
See `backend/develop/sources.ini` for project-specific backend add-ons.

### Python Version

Default: Python 3.12, but supports 3.10, 3.11, 3.12

```bash
make -e PYTHON=python3.11
```

The repository includes a virtualenv at `.venv/` (created during `make init`) for monorepo-level Python tooling. Use it when running Python scripts at the root level:

```bash
.venv/bin/python
```

Note: The backend has its own separate virtualenv in `backend/develop/` which is used for Plone itself.

## Testing Strategy

### Frontend Tests

1. **Jest Unit Tests**: Component and utility testing
   ```bash
   yarn test
   make test src/addons/<addon-name>
   ```

2. **Cypress E2E Tests**: Acceptance testing against live environments
   ```bash
   make cypress              # Run against staging
   make cypress-local        # Run against localhost:3000
   make cypress-open         # Interactive mode
   ```

### Backend Tests

```bash
cd backend/develop
bin/zope-testrunner --test-path sources/<package>
```

## Release Management

Release workflows are project-specific. Check the frontend and backend repositories for CI/CD and release automation details.

## Development Best Practices

### Frontend

1. **Always read files before modifying** - Never propose changes to code you haven't examined
2. **Check `src/customizations/` first** - Component may already be overridden
3. **Use design tokens** - Don't hardcode colors/spacing, use theme tokens
4. **Multilingual aware** - Check locale routing for language-specific features
5. **Add-on isolation** - Keep feature code in appropriate add-on, not project root
6. **Run add-on tests** - Use `cd src/addons/<addon> && make lint && make test`

### Backend

1. **Hot reload limitations** - Must restart Plone after Python changes (or use @@reload)
2. **Add-on patterns** - Follow Plone conventions for content types, views, REST API
3. **Test coverage** - Write tests in add-on's `tests/` directory

### Code Quality

- **Linting**: ESLint for JS/TS, Black for Python
- **Formatting**: Prettier for frontend, Black for backend
- **Type checking**: TypeScript for frontend (gradual typing)
- **Style linting**: Stylelint for CSS/LESS

## Docker & Deployment

Docker images and deployment tooling are project-specific. Review the frontend/backend repo docs or CI configuration for details.

## Important Environment Variables

### Frontend
- `RAZZLE_API_PATH` - Backend API URL
- `RAZZLE_INTERNAL_API_PATH` - Internal API URL (SSR)
- `RAZZLE_DEV_PROXY_API_PATH` - Dev proxy path
- `NODE_OPTIONS="--max-old-space-size=16384"` - Increase memory for builds

## Key Configuration Files

- `frontend/package.json` - Add-on registry, scripts, dependencies
- `frontend/jsconfig.json` - Path mappings for TypeScript/IDE
- `frontend/mrs.developer.json` - Add-on development configuration
- `frontend/razzle.config.js` - Build configuration
- `backend/develop/sources.ini` - Backend add-on sources (mxdev)
- `backend/develop/requirements.txt` - Python dependencies

## Skills Available

This repository has custom Claude Code skills:
- **plone-frontend-developer**: Frontend debugging, UI fixes, Volto add-on work
- **plone-backend-developer**: Backend development, Python add-ons, REST API

Invoke with `/plone-frontend-developer` or `/plone-backend-developer`

## Resources

- Plone Training: https://training.plone.org
- Volto Documentation: https://docs.plone.org/volto
- EEA GitHub: https://github.com/eea
