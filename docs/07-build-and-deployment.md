# 07 — Build and Deployment

## `eeacms/frontend-builder` — the common builder image

The `eea/frontend-builder` repo (branches `18.x`, `19.x`) builds **`eeacms/frontend-builder:18` / `:19`** on Docker Hub (auto-build from the branch → image tag `18` / `19`).

Each branch's `Dockerfile`:

```dockerfile
# syntax=docker/dockerfile:1
# EEA frontend builder: Plone frontend-builder (Volto + pnpm) + Chromium for Cypress.
FROM plone/frontend-builder:19   # or :18

ARG CHROMIUM_VERSION=149.0.7827.196-1~deb12u1

ENV HOST="0.0.0.0"
ENV CHROME_BIN="/usr/bin/chromium"
ENV CHROMIUM_BIN="/usr/bin/chromium"
ENV CYPRESS_BROWSER_PATH="/usr/bin/chromium"

LABEL maintainer="European Environment Agency <eea-edw-a-team-alerts@googlegroups.com>" \
      org.label-schema.name="eea-frontend-builder" \
      org.label-schema.description="EEA Plone Volto 19 frontend builder (Volto + Chromium)" \
      org.label-schema.vendor="European Environment Agency"

# Chromium for Cypress (pinned via a Debian snapshot)
USER root
RUN apt-get update -q \
    && apt-get install -qy --no-install-recommends \
        libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 \
        libnss3 libxss1 libasound2 libxtst6 xauth xvfb \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    mkdir -p /etc/apt/sources.list.d /etc/apt/preferences.d /etc/apt/apt.conf.d; \
    printf '%s\n' 'Acquire::Check-Valid-Until "false";' \
      > /etc/apt/apt.conf.d/99snapshot-no-check-valid-until; \
    printf '%s\n' \
      'deb [check-valid-until=no] http://snapshot.debian.org/archive/debian-security/20260630T000000Z bookworm-security main' \
      'deb [check-valid-until=no] http://snapshot.debian.org/archive/debian/20260630T000000Z bookworm main' \
      > /etc/apt/sources.list.d/bookworm-chromium149-snapshot.list; \
    apt-get update -q; \
    apt-get install -qy --no-install-recommends \
      "chromium=${CHROMIUM_VERSION}" "chromium-common=${CHROMIUM_VERSION}"; \
    apt-mark hold chromium chromium-common; \
    rm -rf /var/lib/apt/lists/*

USER node
ENTRYPOINT ["pnpm"]
CMD ["start"]
```

The builder **bakes the common bits** (Volto project + pnpm + Chromium + Cypress deps + `ENTRYPOINT`/`CMD`) so that every add-on's `Dockerfile` is just the overlay.

## Add-on `Dockerfile` — just the overlay

```dockerfile
# syntax=docker/dockerfile:1
# Add-on overlay onto eeacms/frontend-builder (Volto + Chromium base).
ARG VOLTO_VERSION
FROM eeacms/frontend-builder:${VOLTO_VERSION}

ARG ADDON_PATH

# Overlay the add-on onto the base; rm -rf /app/cypress so the add-on's EEA
# cypress replaces the base's upstream Volto one.
COPY --chown=node:node ./ /app/src/addons/${ADDON_PATH}/
RUN rm -rf /app/cypress \
    && cp -r /app/src/addons/${ADDON_PATH}/. /app/ \
    && pnpm install \
    && make build-deps
```

- `FROM eeacms/frontend-builder:${VOLTO_VERSION}` (Docker Hub tag `19` or `18`).
- `rm -rf /app/cypress` first — so the add-on's **EEA** cypress replaces the base's **upstream Volto** one (which uses `reset-fixture` → `POST /Plone/RobotRemote` → `404` on the EEA backend).
- `cp -r /app/src/addons/${ADDON_PATH}/. /app/` overlays the add-on's config (`package.json`, `pnpm-workspace.yaml`, `.npmrc`, `.pnpmfile.cjs`, `.eslintrc.js`, etc.) + `packages/<addon>` onto the base Volto project.
- `pnpm install && make build-deps` installs the add-on's deps and builds `@plone/registry` + `@plone/components`.
- `WORKDIR` / `ENTRYPOINT` / `CMD` are **inherited** from the base (`/app`, `pnpm`, `start`).
- `.dockerignore` keeps `.git` / `core` / `node_modules` / `build` / `coverage` / `cypress` artifacts out of the build context.

## Frontend project — multi-stage production build

### Stage 1: Build
```dockerfile
FROM plone/frontend-builder:19.3.0 AS builder
COPY --chown=node packages/website /app/packages/website
COPY --chown=node volto.config.js /app/
COPY --chown=node pnpm-workspace.yaml /app/
COPY --chown=node package.json /app/
COPY --chown=node mrs.developer.json /app/mrs.developer.json
COPY --chown=node pnpm-lock.yaml /app/pnpm-lock.yaml
COPY --chown=node razzle.config.js /app/
COPY --chown=node .bundlewatch.config.json /app/
RUN make develop && pnpm install && pnpm build
RUN CI=1 pnpm install --prod
```

### Stage 2: Runtime (slim)
```dockerfile
FROM node:22-slim AS runtime
RUN apt-get update && apt-get install -y --no-install-recommends gosu && apt-get clean
COPY --from=builder /app/build /app/build
COPY --from=builder /app/node_modules /app/node_modules
COPY --chown=node entrypoint.sh /app/entrypoint.sh
COPY --chown=node .bundlewatch.config.json /app/
WORKDIR /app
EXPOSE 3000 3001
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["node", "build/server.js"]
```

### `entrypoint.sh`
- Drop `REBUILD` logic (debug pod users can install tools manually)
- Keep Sentry source map upload at startup (needs deployment env vars)
- Update commands: `yarn` → `pnpm` where applicable

```bash
#!/usr/bin/env bash
set -Ex
# Upload source maps to Sentry (only when SENTRY_* env vars are set)
gosu node ./node_modules/@plone-collective/volto-sentry/scripts/create-sentry-release.sh
exec "$@"
```

## Jenkinsfile changes

### Bundlewatch stage (only stage using package manager directly)
```groovy
// Before (yarn)
sh "yarn config set -H enableImmutableInstalls false"
sh "yarn"
sh "make develop"
sh "make install"
sh "make build"
sh "make bundlewatch"

// After (pnpm)
sh "pnpm install"
sh "make develop"
sh "pnpm build"
sh "pnpm exec bundlewatch --config .bundlewatch.config.json"
```

### Other stages — no changes
- Docker build (`docker.build`) — unchanged
- Release (gitflow) — unchanged
- SonarQube — unchanged
- Rancher upgrade — unchanged

## Gitflow automation (`eeacms/gitflow`)

### Phase 0: Update gitflow Docker image
- Add `pnpm` alongside `yarn` in the Docker image
- Update `js-release.sh` to detect pnpm vs yarn:
  ```bash
  if jq -r '.packageManager // empty' package.json | grep -q pnpm; then
    pnpm install
  else
    yarn install
  fi
  ```
- `npm publish` works regardless of package manager — no change needed

### Release flow (unchanged)
1. Gitflow handles Git operations (merge, tag, push)
2. Docker image is built and pushed to Docker Hub
3. Rancher catalog is updated (Helm chart)
4. Rancher demo upgrade is triggered
5. SonarQube tags are updated

## Helm chart changes

### Debug deployment
- Remove `REBUILD: "True"` env var
- Update volume mount path: `src/addons/` → `packages/`
- Debug pod users install tools manually if needed

### Production deployment
- No changes needed — the Docker image is built by Jenkins, Helm just deploys it
- The `image.repository` and `image.tag` remain the same