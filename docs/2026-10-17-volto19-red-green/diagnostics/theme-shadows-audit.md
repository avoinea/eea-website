# `theme`: auditul shadow-urilor (sesiunea 8) + status V18

Context: PR #395 (`Volto19`). V19 e verde (unit 637 + integrare 23); **integrarea V18 expiră** (kill după
`timeout 1800`). User: „trebuie să verificăm și shadow-urile din theme, ca să nu pierdem din featurile
băgate în volto19".

## Metodă

82 de fișiere sub `packages/volto-eea-website-theme/src/customizations/` (55 de „umbre" de producție +
teste/snapshot-uri/`.diff`). Pentru fiecare umbră s-a comparat conținutul cu fișierul corespunzător din
core la tag-urile exacte **18.36.0** (`volto18/`) și **19.5.0** (`volto19/`), cu rezolvarea de extensie
din `@plone/registry` (`getCustomizationPaths`: exact → JS↔TS → `.jsx`). Script: `/tmp/shadow-audit3.py`.

Rezultatul cheie: **unele umbre au ca bază Volto 18, altele Volto 19** — și, fiind unică pentru ambele
matrițe, fiecare ascunde ceva pe una din ele.

## 1. Umbre cu baza pe **Volto 18** → ascund schimbările din core 19 (risc: pierdem features V19)

| Umbră | ascunde din core (18.36 → 19.5) |
| --- | --- |
| `Contents/ContentsItem.jsx` | **+228/-270** (Volto 19 a rescris componenta: hooks + noi acțiuni) |
| `View/DefaultView.jsx` | +10/-37 |
| `Form/Form.jsx` | +43/-3 — după `08967a2` umbra e pe baza 18: dispare `withSaveAsDraft` și importurile din barrel |
| `Blocks/Grid/View.jsx` | +14/-11 |
| `Diff/DiffField.jsx` | +12/-4 |
| `View/NewsItemView.jsx` | +5/-3 |
| `Blocks/Block/Edit.jsx` | +10/-0 |

## 2. Umbre cu baza pe **Volto 19** → înlocuiesc core 18.36 în build-ul V18

`server.jsx` (+126/-36), `History.jsx` (+296/-310), `SlateEditor.jsx`, `Image/Image.jsx`, `Unauthorized`,
`helpers/Html/Html.jsx`, `Toast`, `Toolbar/More`, `ObjectBrowserWidget`, `utils/blocks.js`, `joinBlocks`,
`TableBlockView.jsx`, `public.less`.

**`SlateEditor.jsx` e cea mai importantă**: baza ei e **19.0–19.3** (112 linii delta vs 19.3, 136 vs
18.35.1; are `scheduleFocus` dar **nu** are `handlePointerDown`/`pendingPointerSelection`). Fix-ul
`plone/volto#8406` a intrat în **19.4.0** și, prin backport, în **18.36.0** — umbra îl anulează pe
**ambele** matrițe. Adică tema rulează cu SlateEditor-ul dinainte de fix, indiferent de imagine.

## 3. Umbre care nu sînt umbre (module noi EEA) — nu se șterg

`Form/blocksClipboardUtils.js` (+ test), `Sidebar/objectBrowserSelection.js`,
`theme/Comments/comments.less`, `theme/View/style.less`, `Header/LanguageSwitcher.jsx`,
`Blocks/LeadImage/schema.js`. Sînt importate de umbrele vecine (`./blocksClipboardUtils`,
`./objectBrowserSelection`, `./LanguageSwitcher`, `./schema`) — `.diff`-ul lor spune `NO_UPSTREAM_FILE`.

> Concret: commit-ul local `08967a2` a șters `LeadImage/schema.js` + `.diff` ca „leftover Volto 17", dar
> fișierul e importat de `LeadImageSidebar.jsx` → build-ul a picat
> (`Can't resolve './schema' .../Blocks/LeadImage`, exit 1). Reparat în `94c2ae7`.

## 3b. `SlateEditor` — REZOLVAT (bază 19.5, `b21bd2d`)

Umbra a fost rebazată pe **19.5.0**, păstrînd doar delta EEA (69 linii):
`getEditorValue`/`cloneDeep`, `resetNodes` în loc de `editor.children = value`, `spellCheck`,
plus importuri absolute (o umbră stă în afara arborelui volto-slate). `handlePointerDown` +
`pendingPointerSelection` sînt acum prezente (9 ocurențe) → #8406 nu mai e anulat pe niciuna din
matrițe. `.diff` regenerat contra 19.5.0.

Verificat local: eslint + prettier curate, **unit 625/625** (cele 2 suite care nu se încarcă local sînt
artefacte cunoscute de harness: `src/index.test.js` aliasat la `@eeacms/volto-block-toc`, iar
`Header.test.jsx` e JSX într-un `.js`), **V19 integrare 22/23** — pică doar `07-lead-image.cy.js`
(comportamentul `plone.leadimage`), reprodus și cu `Form` din core 19.5 pus ca umbră → mediu/flaky,
nu regresie de la această schimbare.

## 4. Status V18: hang-ul **persistă** pe 18.36.0

- Imagine V18 construită din arbore (`theme-v18-cdp`), backend `eeacms/plone-backend`
  (`PROFILES=eea.kitkat:testing`), `make start-ci`, spec `01-block-basics.cy.js` → **kill după 300 s**,
  container la **113% CPU** (14 procese chromium) → buclă JS în browser.
- **Nu** e cauzat de umbra `SlateEditor`: scoasă din build → tot se blochează.
- Nu e cauzat de umbrele din calea „adaugă bloc" (`Block/Edit.jsx`, `BlocksToolbar.jsx`, `Form.jsx`,
  `Order/Item.jsx`): scoase → tot se blochează.
- Înlocuirea tuturor umbrelor cu fișierele din core **nu se poate face** mecanic: fișierele din core au
  importuri relative (`./schema`, `../Container/Edit`) care nu se rezolvă din folderul de customizations.

### Bisect V18 (toate negative, pe imaginea V18 construită din arbore)

| Experiment | Rezultat |
| --- | --- |
| umbra `SlateEditor` scoasă din build | **tot se blochează** |
| umbrele `Block/Edit.jsx`, `Form/BlocksToolbar.jsx`, `Form/Form.jsx`, `Block/Order/Item.jsx` scoase | **tot se blochează** |
| `persistentHelper`-ul `Link` dezactivat în core (`plugins/Link/index.jsx`) | **tot se blochează** |
| `editor/render.jsx` înlocuit cu fișierul din core 18.36 (import absolut la `slate.less`) | **tot se blochează** (~125% CPU, 12 procese chromium) |

Deci `LinkEditor` din stack era simptom (orice componentă din arborele de render apare la pauză), nu
cauza. Ipoteze rămase pentru sesiunea următoare: `applyConfig`-ul temei (înregistrări de plugin/block),
interacțiunea cu `volto-eea-design-system` / `volto-block-style`, umbrele Volto de pe calea
editorului (`Display`, `Toast`, `Widgets/ObjectBrowserWidget`, `Toolbar/More`), `withBlockExtension`,
sau umbrele slate rămase (`TextBlockView`, `TableBlockView`, `utils/*`).

### Stack capturat (CDP, `Debugger.enable` înainte de navigare)

`/tmp/cdp-loop.mjs` (repro + `Debugger.pause`) și `/tmp/cdp-prof.mjs` (profil CPU). Bucla începe la
**click pe `.block.inner`** pe pagina de edit proaspăt încărcată (nu la chooser). Stack-ul mapat prin
sourcemap (`/tmp/smap.py`):

```
react-dom  → react (useRef) → slate-react → slate-react
          → volto-slate/src/hooks/useSelectionPosition.js:13
          → volto-slate/src/editor/plugins/Link/index.jsx:52   (LinkEditor, persistentHelper)
          → react-dom  → ...
```

`LinkEditor` se randează ca `slateSettings.persistentHelpers` din `SlateEditor` cînd blocul e selectat,
și chemă `useSelectionPosition()` (care citește DOM: `ReactEditor.toDOMPoint` +
`getBoundingClientRect`) **în timpul render-ului**. Următorul pas: de verificat dacă umbra
`editor/render.jsx` (customizarea de `attrs`, +46/-15) sau `blocks/Text/TextBlockView.jsx` închide
ciclu render → DOM → render.

## 5. Reproducere / unelte

```bash
# imagine V18 din arbore (context curat!)
rsync -a --exclude .git --exclude node_modules --exclude core --exclude build --exclude coverage \
  --exclude 'cypress/{screenshots,videos,reports}' ./ /tmp/theme-v18-ctx/
cd /tmp/theme-v18-ctx && docker build --platform linux/amd64 \
  --build-arg VOLTO_VERSION=18 --build-arg ADDON_PATH=volto-eea-website-theme . -t theme-v18-cdp

docker run -d --shm-size=4g --link theme-v18-plone2:plone --name theme-cdp \
  -e RAZZLE_INTERNAL_API_PATH=http://plone:8080/Plone --entrypoint sh theme-v18-cdp \
  -c 'make start-ci & exec sleep infinity'
docker exec -d theme-cdp sh -c 'chromium --headless=new --no-sandbox --disable-gpu \
  --disable-dev-shm-usage --remote-debugging-port=9222 --remote-allow-origins=* about:blank'
docker cp /tmp/cdp-loop.mjs theme-cdp:/tmp/ && docker exec theme-cdp node /tmp/cdp-loop.mjs
```

Capcane: `timeout` nu există pe macOS (folosește-l în container); comenzile CDP `Input.*` nu răspund cînd
renderer-ul e blocat (nu le aștepta); `getScriptSource` întoarce gol după pauză — ia bundle-ul +
`build/public/static/js/client.<hash>.js.map` din container și mapează offline.

## 6. Stare la închiderea sesiunii 8

- `volto-eea-website-theme` are **3 commit-uri locale nepusheiate**: `08967a2` (Form rebazat pe 18 de
  către user), `94c2ae7` (fix build: restaurat `LeadImage/schema.js`), `b21bd2d` (SlateEditor pe 19.5).
  Push-ul e amînat intenționat: ar declanșa un CI de ~38 min care se blochează oricum pe V18.
- Decizia userului (sesiunea 8): **shadow-urile pleacă de la Volto 19** și se adaugă compatibilitatea V18
  „ușor ușor"; la fel pentru `SlateEditor`.
- Docker curățat (containere + imagini `theme-*`), build cache pruned; imaginile de bază
  `eeacms/frontend-builder:18/19` rămîn pentru sesiunea următoare.
