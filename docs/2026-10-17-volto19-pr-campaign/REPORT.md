# Rezultate

## PR-uri

- 35 PR-uri noi `volto19 → develop` (cele 5+5 verzi din sesiunea anterioară +
  25 deschise în valurile 1–2) plus `volto-accordion-block` #133 (existent).
- **34/36 verzi** la final (toate check-urile `success`, inclusiv SonarQube).
- Rămân roșii: `eea-website-frontend` #284 (config Jenkins) și
  `volto-eea-website-policy` #138 (coverage Sonar).

Verzi (34): accordion-block#133, design-tokens#15, embed-content#11,
redirector#10, hero-block#65, globalsearch#79, block-data-figure#145,
call-to-action-block#47, citation#18, columns-block#122, corsproxy#32,
description-block#42, eea-map#97, eea-versions#15, listing-block#134,
matomo#52, metadata-block#73, quote-block#36, resize-helper#31,
sentry-rancher-config#23, slate-footnote#96, slate-label#37,
slate-metadata-mentions#59, statistic-block#44, tableau#93, tabs-block#114,
tags-block#33, timeline-block#27, toolbar-actions#16, widget-dataprovenance#30,
widget-geolocation#86, widget-toggle#26, workflow-progress#39, datablocks#160.

## Metrici Sonar (PR vs master)

| repo | înainte | după fix | master |
|---|---|---|---|
| volto-tableau #93 | 43.3% (357/700 neacoperite) | **52.0%** (291/700) | 46.4% |
| volto-datablocks #160 | 35.2% (925/1537) | **38.1%** (882/1537) | 35.5% |
| volto-eea-website-policy #138 | 26.9% (84/125) | — nerezolvat — | 52.0% |

## Commit-uri pe branch-urile de addon (pushuite pe `volto19`)

- `volto-tableau` `3c11356` — scoate excluderea `*schema.*` din coverage +
  test nou `src/Widgets/schema.test.jsx` (6 teste; schema.jsx 3/73 → 70/73).
- `volto-datablocks` `56913c3` (merge develop), `5f8b49a` (`vi.mock` în
  `View.test.jsx`), `22b3116` (teste: paginare `connectToProviderData`,
  HOC `...Unfiltered`, `Skeleton`).
- `volto-eea-website-policy` `bcd82b3` (merge develop; Jenkinsfile).

## Dovezi

- Jenkins: `volto-addons/job/<repo>/job/PR-<n>/` (ex. tableau PR-93/2,
  datablocks PR-160/3) — toate verzi pentru cele 34.
- Sonar: interogările din `PLAN.md` (păstrate în istoricul shell-ului);
  link-uri în check-ul `SonarQube` de pe fiecare PR.
- Repro local: 10/10 fișiere de test la tableau și 17/17 la datablocks
  (rulate cu clone-ul în afara monorepo-ului).
