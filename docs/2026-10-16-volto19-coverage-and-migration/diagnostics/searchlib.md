# searchlib — unit stage (Volto 19), diagnostic

## Simptom CI

- `Tests / Testing / Volto 19 / Unit tests` pică, dar check-ul publicat zice
  "No test results found".
- `make test-ci` → vitest iese cu cod 1 cu `--reporter=junit` (fără output de
  erori); Jenkins face `docker cp` pentru `junit.xml` abia după `sh`-ul care a
  picat, deci raportul nu ajunge la `junit` → "None of the test reports
  contained any result".

## Cauze (reproducere în imaginea construită local, amd64 emulat)

1. **Stub `localStorage` în Volto 19.5** —
   `core/packages/volto/test-setup-globals.js` face
   `vi.stubGlobal('localStorage', { getItem: vi.fn(), ... })` (no-op), deci
   testele `searchlib/lib/aiSummaryToggle.test.js` (11) pică.
   - Fix aplicat: commit `bdd6708` — `packages/volto-searchlib/vitest.setup.jsx`
     (rulează după setup-ul Volto) reinstalează un `localStorage` in-memory.
   - Verificat local în imagine: `aiSummaryToggle.test.js` 11/11 pass.
2. **Eșecuri preexistente rămase** (fără legătură cu coverage/hidratarea):
   - `searchlib/components/AnswerBox/ChatbotAnswer.test.jsx` — 11 teste:
     `Directory import '.../@eeacms/volto-eea-chatbot/src/ChatBlock' is not
     supported resolving ES modules`.
   - `searchlib/components/Layout/TopFilterLayout.test.jsx` — 1 test:
     "shows the page dimmer while the search results are loading".
   - `src/index.test.js`, `src/SearchBlock/hocs.test.js`,
     `searchlib/components/SearchInput/SearchInput.test.jsx` — în imaginea
     locală erau erori de rezolvare a dependințelor din **symlink-uri pnpm
     rupte (emulare arm64)**, nu probleme de CI: `@testing-library/jest-dom`,
     `@testing-library/react-hooks`, `lodash.isfunction`, `regenerator-runtime`.
3. Stage-ul de unit tests nu rulase niciodată pe acest branch (ES lint pica
   primul), deci toate erorile rămase sunt datorii preexistente de migrare.

## Cum se reverifică

În container din imaginea repo-ului (sau pe CI):

```bash
CI=1 pnpm run test --passWithNoTests --coverage --coverage.reporter=text \
  --reporter=default --reporter=junit --outputFile=junit.xml
```

Pentru diagnostic se poate rula doar fișierul dorit:

```bash
pnpm --filter @eeacms/volto-searchlib exec vitest run \
  --reporter=default --coverage=false ChatbotAnswer
```
