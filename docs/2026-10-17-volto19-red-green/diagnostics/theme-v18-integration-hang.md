# `volto-eea-website-theme` — integrarea V18 expiră (exit 137)

Repo: `frontend/packages/volto-eea-website-theme`, branch `volto19` (`1ad6096`).

## Simptom

Stage-ul `Testing / Volto 18 / Integration tests` rulează
`timeout -s 9 1800 docker exec … make cypress-ci` și e omorît după 30 min (exit 137).
În log se vede doar începutul:

```
Running:  01-block-basics.cy.js   (1 of 10)
… Killed
```

Nu se ajunge la al doilea spec și `cypress/reports` nu există la `docker cp` (deci spec-ul 1 nu se
termină nici măcar o dată). Stagiile V19 (unit 637 + integrare 23) sînt verzi.

## Ce s-a verificat

- **Nu e lipsa imaginii**: după pinul `@plone/babel-preset-razzle@1.0.1` (`b11c034`) imaginea V18 se
  construiește (3 min) și `make start-ci` / `check-ci` trec (portul 3000 răspunde) înainte de Cypress.
- **Nu e un test anume din spec-ul 1**: selectorii V19-only au fost înlocuiți cu fallback-uri V18
  (`.align-buttons`) în `44d1ce9`, iar configul Cypress a fost adus la valorile EEA pre-migrare
  (`defaultCommandTimeout: 8888`, `chromeWebSecurity: false`, `video: false`). Timeout-ul persistă.
- **Nu e runner-ul**: alte add-on-uri (block-image-cards, chatbot) rulează V18 cu același
  `eeacms/frontend-builder:18` + Cypress 13 + Chromium 149 în 3–7 min.
- **Baseline**: pe `develop` (structura pre-migrare) integrarea V18 trecea (`passed: 23`, PR #411/#412).
  Deci regresia apare în migrarea la structura Volto 19 (`33945b3`).

## Ipoteze (de testat în ordine)

1. **Freeze de browser din cauza aplicației V18 construite din structura migrată** — Cypress nu are
   timeout pentru un renderer blocat; asta ar explica lipsa oricărui output. Suspecți: `razzle.extend.js`
   mutat în `packages/<name>/` (rămîne cel din imaginea de bază), `babel.config.js` mutat la fel,
   `volto.config.js` nou care înregistrează doar tema (imaginea de bază înregistra tot setul EEA).
2. **Instrumentarea coverage** (`.coverage.babel.config.js`, `include: ['packages/*/src/**']`) — pe
   `develop` pattern-ul nu prindea sursele temei (erau în `src/` la rădăcină), acum le prinde pe toate;
   bundle-ul V18 instrumentat ar putea fi prea greu pentru browser.
3. **Configurația de add-on pe V18** — tema depinde de design-system/group-block/block-toc etc.; pe V18
   `volto.config.js` înregistrează doar tema. Pe V19 merge, dar V18 poate avea nevoie de lista explicită.

## Pași propuși

1. Reproduce local cu imaginea amd64 (emulată): `docker build --build-arg VOLTO_VERSION=18 …` apoi
   `start-ci` + `cypress-ci` pentru un singur spec; logurile containerului (`docker logs`) dau cauza.
   Capcane: symlink-uri pnpm pe arm64 (vezi skill-ul campaniei).
2. Dacă nu se poate local: acces la consola Jenkins (cookie de sesiune) pentru `docker logs` și pentru
   ieșirea completă a lui Cypress.
3. Bisect pe migrare: un build V18 pe `33945b3` (sau pe un commit intermediar) ar arăta dacă hang-ul
   apare imediat după mutarea `babel.config.js` / `razzle.extend.js` / `volto.config.js`.
4. Ca ultimă soluție, dacă e infrastructură/durată: mărirea timeout-ului din Jenkinsfile nu ajută dacă
   spec-ul 1 nu se termină deloc; de preferat ar fi rularea pe spec-uri separate cu timeout per spec.
