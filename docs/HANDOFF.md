# Handoff — Cookieplone frontend_addon template fixes

## What was done this session

Fixed the EEA `cookieplone-templates` `frontend_addon` template for Volto 19. The generated addon now works end-to-end: `make install`, `make test`, `make test-ci`, `make cypress-run` all verified.

### Key changes

1. **Custom EEA Makefile** (replaces upstream's bloated ~160-line one)
   - 24 targets, pnpm-based, ports 3000/8080 (not upstream's 55001)
   - EEA target names: `ci-fix`, `test-ci`, `start-ci`, `check-ci`, `cypress-ci`
   - `RAZZLE_INTERNAL_API_PATH` exported with default `http://localhost:8080/Plone`
   - `make start` = `docker compose up -d backend && pnpm start` (one command)
   - Cypress: `--project $(CURRENT_DIR)` + absolute `specPattern` (fixes screenshots/videos going to Volto core dir)
   - `test-ci`: Vitest with `--coverage --coverage.reporter=lcov --reporter=junit --outputFile=junit.xml`

2. **docker-compose.yml** — backend only (`eeacms/plone-backend` on 8080)

3. **Jenkinsfile** — based on existing EEA V18 Jenkinsfile + V19 path swaps
   - `CURRENT_VOLTO = "19"`, `PREVIOUS_VOLTO = "18-yarn"`
   - Three separate lint stages (ES lint, Style lint, Prettier)
   - `RAZZLE_INTERNAL_API_PATH` as Docker env var (not make argument)
   - Coverage/junit copied from `/app/packages/$GIT_NAME/` (V19 paths)

4. **Cypress files** (EEA override, not upstream pattern)
   - `commands.js` — EEA commands (autologin, createContent, removeContent, Slate helpers)
   - `e2e.js` — `@cypress/code-coverage/support`, `slateBeforeEach`/`slateAfterEach`
   - `example.cy.js` — EEA-style block basics test

5. **Hooks**
   - `pre_prompt.sh` — removed Makefile append sections (Makefile is now a template file)
   - `post_gen_project.py` — adds `@cypress/code-coverage`, `@vitest/coverage-v8`, `prepare: "cd ../.. && husky install || true"`

6. **`.husky/pre-commit`** moved to repo root (not addon package)

7. **`src/config/settings.test.ts`** — example Vitest test

8. **AGENTS.md** — added rule: always end files with trailing newline

9. **README.md** — updated with all new files

## What's left for the next agent

### High priority

- **V18-yarn Jenkinsfile stage**: The `npx cypress run --browser chromium` command in the Volto 18-yarn stage is unverified. The generated V19 addon doesn't have a `cypress:run` script in its `package.json`. Need to verify that `npx cypress run` works in the V18 Docker image (after `/setupAddon && yarn install`). The `CYPRESS_API_PATH` env var is set in the Docker run command.

- **Interactive mode testing**: `cookieplone@2.0.0b3 frontend_addon` (without `--no-input`) — verify prompts show correctly.

### Medium priority

- **64+ addon migration**: The new Makefile + Jenkinsfile need to be applied to all 64+ EEA addons. The Jenkinsfile changes are minimal (just V18→V19 path swaps from the existing EEA V18 Jenkinsfile pattern). The Makefile replaces the old docker-compose-based V18 Makefile with the new pnpm-based V19 one.

- **DEVELOP.md update**: The DEVELOP.md in the template should be updated to reflect the new `make start` (docker-compose backend + pnpm start) workflow, `make cypress-open`, `make test`, etc.

### Lower priority

- **`frontend_project` template**: Was created in a previous session and not modified this session. May need similar fixes (cypress --project, husky, etc.) — but it has its own Makefile already.

- **CI Docker image verification**: The Dockerfile copies the Makefile to `/app/Makefile` and runs `make build-deps`. This was verified locally but not in the actual CI Docker build.

## Files modified in cookieplone-templates

```
templates/frontend_addon/
├── hooks/
│   ├── pre_prompt.sh              (modified — removed Makefile appends)
│   └── post_gen_project.py        (modified — added coverage deps, fixed prepare script)
└── {{ cookiecutter.__folder_name }}/
    ├── .husky/pre-commit           (moved from packages/ to repo root)
    ├── Jenkinsfile                 (modified — EEA targets, V19 paths)
    ├── Makefile                    (NEW — custom EEA Makefile)
    ├── docker-compose.yml          (NEW — backend only)
    ├── cypress/support/commands.js (NEW — EEA commands)
    ├── cypress/support/e2e.js     (NEW — EEA support)
    ├── cypress/tests/example.cy.js (NEW — EEA example test)
    └── packages/.../src/config/settings.test.ts (NEW — example Vitest)
```

## How to test

```bash
cd /Users/alin/sandbox/eea-website/cookieplone-templates
COOKIEPLONE_REPOSITORY=$(pwd) uvx cookieplone@2.0.0b3 frontend_addon --no-input -o /tmp/test
cd /tmp/test/volto-add-on
git init
make install    # installs deps, husky
make test       # runs Vitest (1 test passes)
make test-ci    # runs Vitest with coverage + junit
make cypress-run  # runs Cypress (needs backend+frontend running first)
```
