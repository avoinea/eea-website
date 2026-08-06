# 07 — Build and Deployment

## Dockerfile: Multi-stage with plone/frontend-builder

### Current (single-stage, yarn)
```dockerfile
FROM node:22-slim
COPY . /app/
WORKDIR /app/
RUN ... && npm install -g mrs-developer && corepack enable
USER node
RUN yarn && yarn build && rm -rf .yarn/cache
USER root
EXPOSE 3000 3001
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["yarn", "start:prod"]
```

### New (multi-stage, pnpm, plone/frontend-builder)
```dockerfile
# Stage 1: Build
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

# Stage 2: Runtime (slim)
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

### entrypoint.sh changes
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

## Gitflow automation (eeacms/gitflow)

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