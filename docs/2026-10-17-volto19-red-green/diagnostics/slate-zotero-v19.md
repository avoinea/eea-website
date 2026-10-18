# `volto-slate-zotero` pe Volto 19 — diagnostic și fixuri

Repo: `frontend/packages/volto-slate-zotero`, branch `volto19`.
Înainte: V18 integrare 9/9 verde, V19 integrare 7/9 (2 teste picate), unit 35 verde.

## Rețeta de repro local (funcțională)

Backend:

```bash
docker run -d --rm --name zs-plone -p 8080:8080 -e SITE=Plone \
  -e PROFILES=eea.kitkat:testing eeacms/plone-backend:latest
```

Frontend (configul addon-ului, ca în CI):

```bash
cd frontend/core/packages/volto
export PATH=~/.nvm/versions/node/v24.10.0/bin:$PATH
VOLTOCONFIG=<repo>/frontend/packages/volto-slate-zotero/volto.config.js \
NODE_OPTIONS="--dns-result-order=ipv4first --max-old-space-size=16384" \
npx razzle start
```

Spec:

```bash
cd frontend/packages/volto-slate-zotero
../../node_modules/.bin/cypress run --project . --config-file cypress.config.js \
  --config specPattern='cypress/tests/07-zotero-editor-collections.cy.js',retries=0,video=false \
  --env API_PATH=http://localhost:8080/Plone
```

Două capcane de mediu, fără de care toate spec-urile mor în `slateBeforeEach`:

- `frontend/package.json` cere `engines.node ^24`; cu Node 22 `make start` se oprește.
- razzle pornește bundle-ul client pe `PORT+1` cu `host: localhost` → `[::1]:3001`;
  Electron/Chromium din Cypress nu încarcă resursele (transferSize 0) și aplicația
  nu hidratează. `NODE_OPTIONS=--dns-result-order=ipv4first` rezolvă.

## Spec 07 — `07-zotero-editor-collections.cy.js:77` (bug de produs, cursă)

Al doilea ciclu (redeschidere sidebar, colecția „2009”) pica la
`previewActiveLibraryItem`. DOM-ul arăta 3 rînduri-fantomă în fața itemilor:
colecțiile de top injectate în lista de items. `openLibraryItem(0)` nimerea o
colecție → click-ul naviga în loc să deschidă cardul.

Cauza: `ZoteroDataWrapper.jsx` face două cereri `/collections/top` la remount
(effect-ul pe `zotero_settings` rulează din nou cînd `getZoteroSettings` întoarce
un obiect nou). Al doilea răspuns sosea după ce userul intra în colecție și
`setCollections(...)` se făcea necondiționat, în ciuda `topCollectionFlag=false`.

Fix (`0d9f518`): efectul pe `zotero_collections` eliberează flag-urile de loading
și iese devreme dacă `!topCollectionFlag`. `fetchCollections()` setează
`topCollectionFlag = true` la cerere, deci `pull()`/`handleLoadMore` rămîn corecte.

## Spec 08 — `08-zotero-editor-subcollection.cy.js:77` (cursă de test)

Testul salva imediat după `cy.wait('@item3Resp')`. Widgetul comite citația în
`updatedFormData.footnote` abia după ce React procesează răspunsul; save-ul
înainte de commit trimitea footnote gol → `unwrapElement` → nicio citație.
Spec 07 folosea deja `waitForSidebarCitationCount()` înainte de save.

Fix (`39223bd`): `waitForSidebarCitationCount(1)` înainte de `saveZoteroSidebar()`.

## Rezultat

V18 integrare 9/9, V19 integrare 9/9, unit 35, Jenkins `Success`.
