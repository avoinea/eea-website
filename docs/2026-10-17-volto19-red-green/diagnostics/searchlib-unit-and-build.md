# volto-searchlib — unit + integration repair (branch `volto19`)

Rezultat: branch complet verde (Jenkins `Success`; `Volto 18 / Integration` 2, `Volto 19 / Integration` 2,
`Volto 19 / Unit` 303). Plecase cu `Volto 19 / Unit tests: error in 'sh' step` de la începutul campaniei.

## 1. Unit: 16 teste picau, dar jUnit nu apărea în check

Reprodus local cu harness-ul de coverage. Log-ul din Jenkins e trunchiat (vitest scrie doar în jUnit), dar
local se vede exact:

| Fișier | Teste | Cauză |
|---|---|---|
| `searchlib/components/SearchInput/SearchInput.test.jsx` | 4/4 picau | încă `jest.mock`/`jest.fn` după migrare; sub vitest aliasul global `jest = vi` **nu e hoistat** → fabricile nu se înregistrau, `useAppConfig()` întorcea contextul real → `Cannot destructure property 'sortOptions' of 'appConfig'` |
| `searchlib/components/Layout/TopFilterLayout.test.jsx` | 1/2 | același lucru pentru atomii jotai |
| `searchlib/components/AnswerBox/ChatbotAnswer.test.jsx` | 11/41 | **`require('@eeacms/volto-eea-chatbot')` în corpul testelor** — `require` ocolește fabrica `vi.mock` și încarcă pachetul real prin loader-ul Node → `Directory import '.../src/ChatBlock' is not supported resolving ES modules` (index-ul addon-ului face `import installChatBlock from './ChatBlock'`, import de director) |

Fix-uri (toate test-side):
- `vi.hoisted` + `vi.mock` în cele două suite; mock-uit direct `@plone/volto/components/theme/Image/Image`
  (conectat la redux) în loc să ne bazăm pe mock-ul de `semantic-ui-react`; mock-urile de SVG întorc
  `{ default: '...' }` (vitest cere obiect din fabrică).
- `TopFilterLayout`: nu mai mock-uim modulul de stare, ci conducem **atomii reali**
  (`loadingFamily(appName)`), mai puțin mocking.
- `ChatbotAnswer`: import ESM (mock-uit) în loc de `require(...)`.

## 2. Integrare V19: build-ul pica pe o dependință nedeclarată

```
Cannot find module 'razzle-dev-utils/makeLoaderFinder'
  require stack: .../node_modules/@eeacms/volto-eea-chatbot@4.1.x/razzle.extend.js
                 /app/core/packages/volto/razzle.config.js
make: *** [Makefile:145: start-ci] Error 1
```

`razzle.extend.js` (atât al addon-ului, cât și al dependinței `@eeacms/volto-eea-chatbot`) face:

```js
try { makeLoaderFinder = require('@plone/razzle-dev-utils/makeLoaderFinder'); }
catch { makeLoaderFinder = require('razzle-dev-utils/makeLoaderFinder'); }
```

`@plone/razzle-dev-utils` nu există pe npm, iar `razzle-dev-utils` nu e declarat de nimeni. Pe imaginea
**Volto 18** se rezolva prin razzle-ul din core (de aceea `Volto 18 / Integration` trecea), pe **Volto 19**
core-ul folosește `volto-razzle` și nu mai există → build-ul pică. Fix: `razzle-dev-utils` în
`devDependencies` la rădăcina workspace-ului (de acolo e pe calea de rezolvare a addon-urilor).

**De reținut pentru alte repo-uri**: orice addon care depinde de `@eeacms/volto-eea-chatbot` și se
construiește pe Volto 19 are aceeași problemă (pattern-ul „`razzle-dev-utils/makeLoaderFinder` lipsă"
notat pentru `volto-globalsearch` / `volto-eea-website-policy`). Acelea sînt verzi acum, dar dacă
reapar, fix-ul e același.

## Harness local (reamintire)

Vezi `diagnostics/sonar-coverage.md` pentru rețeta completă. Specific aici: addon-urile surori trebuie
**copiate** (nu symlink-uite) în `packages/`; altfel Vite le respinge și mesajele de eroare sînt
înșelătoare („Directory import" în loc de „outside of the allow list").
