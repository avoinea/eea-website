# TODO (deschis)

- [ ] **`volto-eea-website-policy` #138 — coverage Sonar** (26.9% vs 52% pe
      master). Cauza: branch-ul V19 adaugă `src/customizations/volto/...`
      (`components/manage/Blocks/HTML/Edit.jsx` — 66 linii, 62 neacoperite;
      `middleware/blacklistRoutes.js` — 20 linii, 8 neacoperite). De decis:
      teste unitare noi sau altă abordare (owner: user + sesiunea următoare).
      Metoda de diagnostic: `api/sources/lines` pe master vs PR (vezi `PLAN.md`).
- [ ] **`volto-eea-website-policy` #138 — body**: adaugă nota + checklist-ul de
      unpin chatbot/searchlib (deocamdată e doar la `volto-globalsearch` #79).
- [ ] **`eea-website-frontend` #284** — job-ul Jenkins de PR rulează pe Node
      18.20.8, repo-ul cere `^24` (`ERR_PNPM_UNSUPPORTED_ENGINE`): de actualizat
      job-ul `volto/eea-website-frontend/PR-*` la Node 24 sau de închis PR-ul
      (owner: user, configurație Jenkins).
- [ ] **Unpin chatbot + searchlib** după release-urile majore (moștenit; vezi
      `docs/2026-10-16-volto19-batch2-pin/TODO.md`).
- [ ] **CI `volto-eea-chatbot` roșu** (fail-fast stale + lint) — moștenit.
- [ ] **Mini-val fail-fast: 13 repo-uri rămase** — moștenit, neînceput.
- [ ] (opțional) Alte addon-uri V19 au aceeași excludere `*schema.*` în
      `vitest.config.mjs`; niciun alt PR din această sesiune nu a picat pe
      coverage, dar merită verificat dacă reapare.
- [ ] (opțional) Sincronizarea docs canonice
      (`docs/2026-10-16-volto19-coverage-and-migration/{TODO,REPORT}.md`) cu
      campania de PR-uri.

# Închis în sesiunea aceasta

- [x] 35 PR-uri `volto19 → develop` deschise (toate cele 36 verzi au PR).
- [x] Sync `develop → volto19` la datablocks + policy (ambele `mergeable`).
- [x] `volto-tableau` #93 verde (config coverage + test schema).
- [x] `volto-datablocks` #160 verde (`vi.mock` + teste de coverage).
- [x] Script `open-volto19-prs.sh` în skill-ul campaniei.
