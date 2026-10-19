# `volto-eea-website-theme` — integrarea V18 expiră (exit 137)

Repo: `frontend/packages/volto-eea-website-theme`, branch `volto19` (`1ad6096`).

## Simptom (CI)

Stage-ul `Testing / Volto 18 / Integration tests` rulează
`timeout -s 9 1800 docker exec … make cypress-ci` și e omorît după 30 min (exit 137).
În log se vede doar începutul:

```
Running:  01-block-basics.cy.js   (1 of 10)
… Killed
```

Nu se ajunge la al doilea spec și `cypress/reports` nu există la `docker cp` (deci spec-ul 1 nu se
termină nici măcar o dată). Stagiile V19 (unit 637 + integrare 23) sînt verzi.

## Cauza: buclă infinită de JS în browser (confirmat local, 2026-10-19)

Reprodus local pe imaginea V18 amd64 emulată: după `Running: 01-block-basics.cy.js` nu mai apare
nimic, iar un renderer Chromium stă la **~110% CPU** pentru tot restul rulării. Nu e timeout de rețea,
nu e backend, nu e imaginea.

## Repro local (macOS arm64 + Docker Desktop, emulare amd64)

Emularea merge (Rosetta); build-ul imaginii durează ~4 min, un spec ~40 s.

```bash
cd frontend/packages/volto-eea-website-theme
# capcană: `.dockerignore` exclude doar `node_modules` de la rădăcină, nu `packages/*/node_modules`;
# dacă build-ul pornește din worktree, node_modules-urile V19 deja instalate o umbresc pe cea V18
# (eșec: „react-portal doesn't exist”). De aceea, context curat:
rsync -a --exclude '.git' --exclude node_modules --exclude core --exclude build \
  --exclude coverage --exclude 'cypress/screenshots' --exclude 'cypress/videos' \
  --exclude 'cypress/reports' ./ /tmp/theme-v18-ctx/
cd /tmp/theme-v18-ctx
docker build --platform linux/amd64 --build-arg VOLTO_VERSION=18 \
  --build-arg ADDON_PATH=volto-eea-website-theme . -t theme-v18-local
```

```bash
docker run --platform linux/amd64 -d --name theme-v18-plone \
  -e SITE=Plone -e PROFILES=eea.kitkat:testing eeacms/plone-backend
docker run --platform linux/amd64 --shm-size=4g --link theme-v18-plone:plone --name theme-v18-fe \
  -e RAZZLE_INTERNAL_API_PATH=http://plone:8080/Plone \
  --entrypoint=make --workdir=/app theme-v18-local start-ci      # pnpm build + start:prod, ~5 min
docker exec --workdir=/app theme-v18-fe make check-ci
docker exec --workdir=/app theme-v18-fe make cypress-ci \
  CYPRESS_SPEC_PATTERN=/app/cypress/tests/01-block-basics.cy.js
```

Starea la finalul sesiunii 5: ambele containere rămîn **pornite**; imaginea `theme-v18-local` există.
Curățenie: `docker rm -f theme-v18-fe theme-v18-plone && docker rmi theme-v18-local`.

## Ce s-a exclus, cu dovezi

| Probă | Conținut | Rezultat |
| --- | --- | --- |
| `99-smoke` | `cy.visit('/')` + `body` | trece în 1 s |
| `90-p1-autologin` | `cy.autologin()` + cookie | trece în 0.9 s |
| `92-p3-visit` | autologin + 2×`createContent` + `visit('/cypress/my-page/edit')` + `.block.inner` | trece în 2 s |
| `70-a` | `clearSlateTitle` + `getSlateTitle().type()` + heading | trece |
| `60-a` | **doar** `cy.getSlate().click()` | **hang** |
| `60-b` | `cy.getSlate().click()` + `getSlateEditorAndType('Lorem ipsum.')` | hang |
| `80-1` | titlu + toolbar slate + RSS link | hang |
| `01` original | spec complet | hang |

Mediul e sănătos: Chromium simplu încarcă pagina (CDP `Runtime.evaluate`, RTT 1–5 ms) — deci nu e
build-ul V18, nu e Cypress+Chromium 149 în general.

## Declanșatorul: `cy.getSlate().click()` pe pagină goală

`SLATE_SELECTOR = '.content-area .slate-editor [contenteditable=true]'`. Un Document creat prin REST
are doar blocul de titlu, deci `getSlate()` intră în fallback-ul din `cypress/support/commands.js:394-424`
(adăugat în `ef848a8`, „Volto 18 support”): `.block.inner` `.click({force:true})` → `block-add-button`
→ chooser „Text” → buton `.slate`. Acolo intră editorul în buclă. Nu e typing-ul, nu e widget-ul RSS.

## Blocaj curent: stack-ul JS

După ce bucla pornește, renderer-ul Cypress e ocupat; `Debugger.enable` (CDP) e legat de main thread,
deci nu putem atașa debugger-ul „din mers” (`Debugger.pause` expiră). `/json/list` arată un singur
target (runner-ul de pe `localhost:3000/__/`), fără target separat pentru AUT.

## Pași următori

1. **Izolare la nivel de click** (un run ~40 s fiecare): `cy.get('.block.inner').last().click({force:true})`
   singur → apoi + `block-add-button` → apoi + chooser „Text” → apoi + butonul `.slate`.
2. **Stack exact**: repro în Chromium simplu cu `Debugger` activat **înainte** de navigare (cookie
   `auth_token` din `POST /Plone/@login`, conținut creat prin REST, click-uri prin CDP `Input`), apoi
   `Debugger.pause` și mapare coloană → sursă prin sourcemap-ul din `build/static/js/*.map`.
3. **Fix probabil test-side** (nu în aplicație): fie pre-crearea blocului text prin REST în
   `slateBeforeEach` (fără chooser), fie calea V17 (`{enter}`/slash-command) în locul fallback-ului cu
   `force: true`.

Sondele folosite sînt doar în container (`/app/cypress/tests/6x|7x|8x|9x-*.cy.js`) și în `/tmp/probes/`
pe host; repo-ul a rămas curat.
