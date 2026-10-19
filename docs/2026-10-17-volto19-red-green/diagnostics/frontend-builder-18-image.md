# `eeacms/frontend-builder` — imagini V18/V19 (sesiunea 6)

Repo sursă: `/Users/alin/sandbox/eea-website-volto19/frontend-builder` (`eea/frontend-builder`),
branch `18.x` / `19.x` → tag Docker Hub `eeacms/frontend-builder:18` / `:19`.
Build-ul e automat la push pe branch (verificat: push `7cb8c2e` la 15:05 → tag `:18` republicat la 15:13).

## Problema

| Imagine | Volto livrat | Publicată | Observații |
| --- | --- | --- | --- |
| `eeacms/frontend-builder:18` | **18.35.1** | 2026-08-18 | `FROM plone/frontend-builder:18` |
| `eeacms/frontend-builder:19` | 19.5.0 | 2026-10-08 | = ultima 19.x de pe npm |

`plone/frontend-builder:18` (upstream) e **înghețat la 18.35.1** (2026-07-16): pentru 18.36.0 Plone a
publicat doar tag-uri `*-buildtest` (2026-09-02), nu și tag-ul stabil `18`. Deci un simplu rebuild al
imaginii EEA nu ar fi adus 18.36.0 — de unde și eșecul V18 al `volto-block-toc`, dar și orice alt
add-on care atinge bug-ul de focus Slate reparat în 18.36.0 (`plone/volto#8406`).

Dovadă (imaginea veche):

```bash
docker run --rm --entrypoint sh eeacms/frontend-builder:18 \
  -c 'grep -m1 version /app/core/packages/volto/package.json'
# "version": "18.35.1"
```

## Fix (`7cb8c2e` pe `18.x`)

```dockerfile
ARG VOLTO_VERSION=18.36.0

USER node
RUN set -eux; \
    current="$(node -p "require('/app/core/packages/volto/package.json').version")"; \
    if [ "$current" != "$VOLTO_VERSION" ]; then \
      git -C /app/core fetch --no-tags --depth 1 origin "refs/tags/${VOLTO_VERSION}"; \
      git -C /app/core checkout -q FETCH_HEAD; \
      cd /app; \
      pnpm install --no-frozen-lockfile; \
    fi
```

- Pasul e **no-op** când imaginea de bază livrează deja versiunea → de șters după ce Plone republică
  `plone/frontend-builder:18` ≥ 18.36.0.
- `19.x` nu a fost atins: `19.5.0` = ultima versiune pe npm.
- Verificare post-build:

```bash
docker run --rm --entrypoint sh eeacms/frontend-builder:18 -c \
  'node -p "require(\"/app/core/packages/volto/package.json\").version";
   grep -c pendingPointerSelection /app/core/packages/volto-slate/src/editor/SlateEditor.jsx;
   chromium --version'
# 18.36.0
# 6
# Chromium 149.0.7827.196 built on Debian GNU/Linux 12 (bookworm)
```

Cronologie: push 15:05 → tag `:18` republicat 15:13 (`sha256:016c8950…`) → verificat conținutul.

## Capcane

- Jenkins e auth-gated, deci nu se poate urmări build-ul; singurul oracol e Docker Hub API:
  `curl -s https://hub.docker.com/v2/repositories/eeacms/frontend-builder/tags/18`
  (`digest` + `last_updated` se schimbă la republicare).
- `docker build --pull` în Jenkinsfile-ul add-on-urilor ia noul digest automat; nu e nevoie de
  re-tag local.
- Repo-ul vechi (`plone/plone-frontend`, sursa label-ului pentru `:18`) e arhivat; `:19` vine din
  `plone/container-frontend`. Nu presupune că tag-urile instabile upstream se numesc la fel.
