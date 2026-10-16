# Decizii (în ordine)

1. **Scope: toate cele 36 de repo-uri verzi, nu doar cele 6 din batch-ul 2.**
   User a indicat lista din dashboard; excludere: doar ce nu e pe
   `github.com/eea/` (cele 4 `collective/*`). Respinse: „doar cele 6", „doar
   cele cu pin" (globalsearch/policy).
2. **Batch-uri de 5 + poll până la verde** (~10–18 min/lot). La mijlocul
   sesiunii, override user: „un val de 15 acum, restul după 7 minute, fără
   așteptare" — respectat (15 + 10, cu 7 min pauză).
3. **Titlu PR = `chore: Volto 19 support`** (convenția migrării V18:
   `chore: Volto 18 eslint/jest migration`), body scurt descriptiv. Respins:
   titlul „Volto19" folosit de PR-ul existent #133 (prea sec).
4. **`develop → volto19` prin merge, nu rebase**, pentru cele două repo-uri
   „behind" (datablocks, policy), apoi push în PR. Rezolvări: datablocks —
   conflictele „file location" au fost rezolvate automat de git (fișierele noi
   din develop mutate în layout-ul `packages/`); policy — conflict în
   `Jenkinsfile`, păstrat `SONARQUBE_TAGS` (valoarea nouă din develop, 3 tags)
   peste pipeline-ul V19.
5. **tableau #93: scoatem excluderea `src/**/*schema.*` din
   `vitest.config.mjs` + test nou pentru `Widgets/schema.jsx`.**
   Cauza reală a scăderii de coverage (43.3 vs 46.4 pe master): template-ul
   Vitest exclude fișierele `*schema.*` din raport (master/Jest nu excludea),
   iar `schema.jsx` era acoperit doar de 3 linii din instrumentarea E2E.
   Respins: doar test nou (inutil cât timp fișierul rămâne exclus din coverage).
6. **datablocks #160: conversie `jest.*` → `vi.hoisted`/`vi.mock`** în testele
   venite din develop (setup-ul V19 doar aliază `global.jest = vi`, fără
   hoisting → mock-urile `react-redux`/`RenderBlocks` nu se aplicau → render
   fără store). Respins: înfășurarea în `<Provider>` (ar fi mascat cauza).
7. **datablocks #160 (Sonar 35.2 vs 35.5): teste noi** pentru cache-ul de
   paginare din `connectToProviderData`, HOC-ul `...Unfiltered` (0 teste
   înainte) și `Skeleton`. Rezultat: 38.1% vs 35.5%.
8. **policy #138: NU s-a rezolvat** coverage-ul (26.9 vs 52.0 pe master) —
   branch-ul V19 adaugă `src/customizations/volto/...` neacoperite; lăsat
   explicit pentru sesiunea următoare (vezi `TODO.md`).
9. **frontend #284: NU s-a rezolvat** — job-ul Jenkins de PR rulează pe Node
   18.20.8, repo-ul cere `^24` (`ERR_PNPM_UNSUPPORTED_ENGINE`); e configurație
   Jenkins, nu cod. Owner: user.
10. **Handoff-ul anterior rămâne valid** (`docs/2026-10-16-volto19-batch2-pin/`);
    acest folder se adaugă, nu înlocuiește.
