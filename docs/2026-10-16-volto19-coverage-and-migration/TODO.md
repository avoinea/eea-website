# TODO

## Prioritar (sesiunea următoare)

- [ ] **Re-verificare finală Jenkins** pe repo-urile re-pushuite în sesiunea 2 (rezultate parțiale în `REPORT.md`):
  - [x] `volto-columns-block` (`e544509`) — ✅ verde complet
  - [ ] `volto-slate-label` (`7cdbac4`) — V18 integrare ✅ 2/2; rebuild triggerat după „Agent was removed"
  - [ ] `volto-searchlib` (`bdd6708`) — rebuild triggerat după „Agent was removed" la build image; unit preexistent (ChatbotAnswer 11, TopFilterLayout 1)
  - [ ] `volto-group-block` (`64f5128` auto) — lint reparat; unit stage pică preexistent (fără detalii în junit)
  - [ ] `volto-globalsearch` (`9ac1e33`) — V19 unit ✅ 108; build razzle pică preexistent pe `razzle-dev-utils/makeLoaderFinder`
- [ ] **Repo `collective`** (authomatic, rss-provider, sentry, subsites): decizie user — PR / push direct / skip; au doar coverage împins, nu și hidratare + `mrs` 19.5.0.
- [ ] (opțional) Continuă catalogul de eșecuri preexistente rămase: `checks-summary.txt`, `regressions-per-check.txt`, `regressions-per-title.txt` (hero-block, anchors, kitkat, object-widget, block-image-cards, redmine-helpdesk, etc.).

## Secundar

- [ ] `volto-slate-zotero`: pe lângă testul „adds a citation from a Zotero subcollection" (precedent), pică determinist și „adds Zotero citations from collections and reuses the same footnote index for duplicates" (Volto 19). De decis dacă e efect de timing (hidratare) sau problema de fond a pane-ului Zotero.
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
