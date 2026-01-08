# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the EEA (European Environment Agency) Main Website codebase built with **Plone 6.1** and **Volto 17**. The repository contains both frontend (Volto/React) and backend (Plone/Python) components in a monorepo structure.

- **Frontend**: Modern React-based frontend using Volto 17.23.0
- **Backend**: Plone 6.1.3 CMS with Python 3.10-3.12
- **Architecture**: Headless CMS with REST API communication between frontend and backend

## Repository Structure

```
eea-website/
├── frontend/           # Volto 17 React frontend
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
└── skills/            # Local Claude Code skills for this project
```

## Frontend Development

### Initial Setup

```bash
cd frontend
nvm use 18  # or 20
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

The project uses **workspace add-ons** in `frontend/src/addons/`. Key add-ons include:

- `@eeacms/volto-eea-website-theme` - Main theme
- `@eeacms/volto-eea-website-policy` - Site policies and configurations
- `@eeacms/volto-eea-design-system` - EEA design system components
- `@eeacms/volto-eea-kitkat` - Core EEA functionality
- `@eeacms/volto-searchlib` - Search functionality
- Plus 60+ other specialized add-ons (see `package.json` addons array)

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

- **Configuration**: Most config happens in add-ons (especially `volto-eea-website-policy`), not in `src/config.js`
- **Theme**: Uses `@eeacms/volto-eea-website-theme` with design tokens from `@eeacms/volto-design-tokens`
- **State Management**: Redux (inherited from Volto core)
- **Styling**: Semantic UI + LESS with custom theme overrides
- **Build Tool**: Razzle (webpack-based)
- **Package Manager**: Yarn 3.2.3 (Berry) with workspace protocol

### Running Against Different Backends

```bash
make start              # Default: docker-compose backend
make staging            # Staging backend: https://staging.eea.europa.eu
make demo               # Demo backend: https://demo-www.eea.europa.eu
make relstorage         # Local RelStorage backend on :8080
```

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
- **Key Backend Add-ons**:
  - `eea.kitkat` - Core EEA functionality
  - `eea.dexterity.indicators` - Indicators content type
  - `eea.dexterity.themes` - Thematic content types
  - `eea.api.*` - REST API extensions
  - Plus 15+ other backend packages (see `sources.ini`)

### Python Version

Default: Python 3.12, but supports 3.10, 3.11, 3.12

```bash
make -e PYTHON=python3.11
```

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

### Frontend Release

The project uses `release-it` with automated CI/CD via Jenkins:

1. **Beta releases** (from develop branch):
   ```bash
   yarn release-beta
   ```

2. **Production releases** (develop → master PR):
   - Create PR from develop to master
   - Jenkins automatically updates version and CHANGELOG.md
   - On merge, creates GitHub release and triggers Docker image build
   - Docker images pushed to https://hub.docker.com/r/eeacms/eea-website-frontend

### Version Management

- Version in `package.json` must follow semver: MAJOR.MINOR.PATCH
- CHANGELOG.md auto-generated from commit messages
- Automated commits (with [JENKINS] or [YARN]) excluded from changelog

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

Frontend and backend are containerized and deployed via:
- **Docker**: `eeacms/eea-website-frontend` and `eeacms/eea-website-backend`
- **Rancher**: EEA's Kubernetes-based deployment platform
- **CI/CD**: Jenkins at https://ci.eionet.europa.eu

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
