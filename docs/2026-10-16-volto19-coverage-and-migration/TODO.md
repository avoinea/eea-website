# TODO

## Prioritar (sesiunea următoare)

## Campanie batch-uri (repo-uri verzi)

- [x] **Batch 1 VERDE**: `volto-citation` (`2fc4ae1`), `volto-toolbar-actions` (`25bd898`), `volto-eea-versions` (`8df9b27`) — per repo: scoatere praguri coverage (0 teste), cleanup tolerant la 404, scos importul stale `cypress-fail-fast`.
- [x] **Batch 2 extins VERDE (6 repo-uri)**: `volto-design-tokens` (`003edec`), `volto-embed-content` (`dd20bcd`), `volto-redirector` (`7abd242`), `volto-hero-block` (`bf51532`), `volto-globalsearch` (`8814f9b`), `volto-eea-website-policy` (`859ddb9`) — detalii în `REPORT.md`. Fix-uri noi: `react-portal` → `createPortal` (redirector), selector dual V18/V19 la widget-ul de styling (hero-block), `check-ci` 600→1200 + heap Node 8G la build-ul V18 (embed-content), pin `razzle-dev-utils`→chatbot git (globalsearch/policy).
- [x] **Pin chatbot + searchlib** (înlocuiește shim-ul de node_modules): globalsearch `6e0e839` + `1c6e077`, policy `3b118aa` — `pnpm.overrides`: `@eeacms/volto-eea-chatbot` și `@eeacms/volto-searchlib`, ambele `github:eea/<repo>#volto19&path:/packages/<repo>`; scos `razzle-dev-utils-shim.js` + `postinstall`. Chatbot `720e124` + searchlib `2cdbd19`: scos `prepare` din pachet (mutat ca `husky:install`, chemat din `prepare`-ul root) — altfel pnpm rulează `pnpm install` în checkout-ul git și pică pe devDeps `workspace:*`. Lanțul pică pe rând: după chatbot a urmat searchlib (publicat) cu același require legacy. Include refresh de lock (`f19fbe5`, `144558e`) — lock-urile erau deja în urmă față de core-ul 19.5.0 (`a424fdb`), deci `--frozen-lockfile` pica și înainte. La globalsearch a mai fost nevoie de `1c6e077` (install curat în Dockerfile — vezi REPORT.md, store pnpm 9 vs 10 → două instanțe React → #423).
- [ ] **Unpin chatbot + searchlib** (de bifat în PR-ul `volto19→develop`): după release-urile **majore** ale `volto-eea-chatbot`/`volto-searchlib` (breaking: fără Yarn, fără Volto 17) — scoate override-urile din globalsearch/policy, pune versiunile npm, regen lock și retestează. Alternativă de discutat la PR: merge în ordine (întâi release-urile, apoi bump) sau păstrarea pin-urilor până la release.
- [ ] **Mini-val fail-fast** (2 rămase): importul stale `cypress-fail-fast`
      (fără plugin înregistrat + fără dependință declarată) există în:
      `volto-block-image-cards`, `volto-eea-chatbot`. Închise 2026-10-17, toate
      check-urile Jenkins verzi: batch A — `volto-anchors` (`eb350f8`),
      `volto-controlpanel` (`a4f118d`), `volto-flourish` (`3444c74`); batch B —
      `volto-embed` (`90d1719`), `volto-nextcloud-video-block` (`938a583`),
      `volto-redmine-helpdesk` (`e6a419d`); batch C — `volto-eea-kitkat`
      (`f0a6d29`), `volto-widget-theme-picker` (`5c2a92c`),
      `volto-block-data-table` (`e767ef2`), `volto-block-toc` (`4c6a0d4`),
      `volto-embed-static-content` (`6de1b7f`).
- [x] **Unit tests preexistente reparate** (batch C): `volto-block-data-table`
      (praguri coverage fără teste), `volto-block-toc` (CJS `require` → ESM
      imports), `volto-embed-static-content` (mock Popup funcțional + uuid mock
      + prag branch 2%).
- [ ] **`volto-eea-website-theme` #395** — V19 lint (2 warnings
      `react/jsx-no-target-blank`; migrarea `33945b3` a pierdut override-ul
      `allowReferrer: true` din develop) + V18 build `ERR_PNPM_WORKSPACE_PKG_NOT_FOUND`
      (`@plone/babel-preset-razzle: "workspace:*"` nu există în core-ul V18; de
      pin-uit la `1.0.1` sau scos + regen lock). Diagnostic în sesiunea 2026-10-17.
- [ ] De documentat de ce `/Plone/cypress` dispare înainte de cleanup-ul din afterEach (subagent local pe citation, în curs).


- [ ] **Re-verificare finală Jenkins** pe repo-urile re-pushuite în sesiunea 2 (rezultate parțiale în `REPORT.md`):
  - [x] `volto-columns-block` (`e544509`) — ✅ verde complet
  - [ ] `volto-slate-label` (`7cdbac4`) — V18 integrare ✅ 2/2; rebuild triggerat după „Agent was removed"
  - [ ] `volto-searchlib` (`bdd6708`) — rebuild triggerat după „Agent was removed" la build image; unit preexistent (ChatbotAnswer 11, TopFilterLayout 1)
  - [ ] `volto-group-block` (`64f5128` auto) — lint reparat; unit stage pică preexistent (fără detalii în junit)
  - [ ] `volto-globalsearch` (`9ac1e33`) — V19 unit ✅ 108; build razzle pică preexistent pe `razzle-dev-utils/makeLoaderFinder` (rezolvat în campanie: pin chatbot `8814f9b`)
- [ ] **Repo `collective`** (authomatic, rss-provider, sentry, subsites): decizie user — PR / push direct / skip; au doar coverage împins, nu și hidratare + `mrs` 19.5.0.
- [ ] (opțional) Continuă catalogul de eșecuri preexistente rămase: `checks-summary.txt`, `regressions-per-check.txt`, `regressions-per-title.txt` (hero-block, anchors, kitkat, object-widget, block-image-cards, redmine-helpdesk, etc.).

## Secundar

- [ ] `volto-slate-zotero`: pe lângă testul „adds a citation from a Zotero subcollection" (precedent), pică determinist și „adds Zotero citations from collections and reuses the same footnote index for duplicates" (Volto 19). De decis dacă e efect de timing (hidratare) sau problema de fond a pane-ului Zotero.
- [ ] `volto-eea-chatbot`: CI roșu — fail-fast stale (V18 integrare) + 35 lint warnings (`--max-warnings=0`); de reparat înainte de release-ul **major**.
- [ ] `volto-searchlib`: `ChatbotAnswer.test.jsx` (11) + `TopFilterLayout.test.jsx` (1) — datorii preexistente (vezi `diagnostics/searchlib.md`).
- [ ] `volto-slate-label`: `LabelWrapper.jsx` nu împrăștie `{...attributes}` pe `<label>` (hardening non-blocant) — vezi `diagnostics/slate-label.md`.
- [ ] Template `cookieplone-templates`: dacă vrea userul, release/cherry-pick din `next`.
- [ ] Curățenie locală: containere `sb-*`, `lock-test`; imaginea `sb-searchlib` (~7 GB); proxy-uri `socat` pe porturile 3000/3001.

## Închise în sesiunea 2 (2026-10-16)

- [x] Spot-check Jenkins pe 63 repo-uri după valul masiv: 2 regresii reale găsite și reparate (`volto-columns-block`, `volto-slate-label`); restul eșecurilor = preexistente.
- [x] `volto-datablocks` `c30ac71` — `DELETE /@lock` înainte de PATCH; Jenkins verde (5/5 × 2 stage-uri, 71 unit).
- [x] `volto-widget-geolocation` `64ceb5f` — allowlist betterleaks; Jenkins verde (26/26 × 2 stage-uri, 46 unit).
- [x] `volto-group-block` `01688ee` — `});` orfan în `Edit.test.jsx` (lint Volto 19).
- [x] `volto-searchlib` `bdd6708` — localStorage funcțional în `vitest.setup.jsx` (11 teste reparate local).

## Închise în sesiunea 1

- [x] Fix Cypress Volto 18 + SonarQube coverage pentru `volto-accordion-block` (Jenkins #5 verde).
- [x] Template `frontend_addon` (coverage + hidratare).
- [x] Replicare coverage pe 66 repo-uri.
- [x] Fix-uri per repo: columns-block, datablocks, design-system, map, searchlib (lint), globalsearch (lint), geolocation (secrets).
- [x] Update hidratare + `mrs` 19.5.0 pe toate cele 62 repo-uri EEA (batch-uri + pass 2).
