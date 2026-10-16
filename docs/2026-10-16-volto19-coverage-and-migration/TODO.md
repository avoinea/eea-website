# TODO

## Prioritar (pentru sesiunea următoare)

- [x] **Batch-uri masive** — terminate: 61 pushed + 1 skip (`volto-anchors`, rezolvat în pass 2), 0 failed; verificare finală 62 repo-uri = 0 anomalii.
- [x] **Pass 2 hidratare** — `volto-anchors`, `volto-block-image-cards`, `volto-block-toc` patch-uite și push-uite.
- [ ] **Spot-check Jenkins** după push: `volto-tabs-block` (Volto 18 integration), `volto-columns-block`/`volto-datablocks`/`volto-eea-design-system`/`volto-eea-map` (Unit tests), `volto-globalsearch`/`volto-searchlib` (ES lint), `volto-widget-geolocation` (Scan for secrets).
- [ ] **Repo `collective`** (authomatic, rss-provider, sentry, subsites): decizie user — PR/ cherry-pick/ skip; au doar coverage împins, nu și hidratare + `mrs` 19.5.0.

## Secundar

- [ ] Eșecuri preexistente rămase (nu au fost atinse): vezi `checks-summary.txt` — ex. `volto-hero-block` (selector `.inline.field.align-widget`), `volto-anchors` (3 teste pe ambele stage-uri), `volto-eea-kitkat` (30), `volto-object-widget` (12), `volto-block-image-cards` (9), `volto-redmine-helpdesk` (6), `volto-eea-website-theme` (Build test image), etc.
- [ ] Template `cookieplone-templates`: dacă vrea userul, release/cherry-pick din `next`.
- [ ] Curățenie locală: containere `vacb-*`, `qt-*`, `cb-quick*`; proxy-uri `socat` pe porturile 3000/3001; `docker rm -f` după terminarea verificărilor.

## Închise în sesiunea curentă

- [x] Fix Cypress Volto 18 + SonarQube coverage pentru `volto-accordion-block` (Jenkins #5 verde).
- [x] Template `frontend_addon` (coverage + hidratare).
- [x] Replicare coverage pe 66 repo-uri.
- [x] Fix-uri per repo: columns-block, datablocks, design-system, map, searchlib, globalsearch, geolocation.
- [x] Update hidratare + `mrs` 19.5.0 pe toate cele 62 repo-uri EEA (batch-uri + pass 2).
