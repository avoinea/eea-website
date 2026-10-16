# Rezultate

## 6/6 verzi (dovezi: check-runs pe HEAD, Jenkins)

| Repo | HEAD | Commit-uri | Verificare |
|---|---|---|---|
| `volto-design-tokens` | `003edec` | `f4fb188`, `003edec` | V18+V19 integrare, unit, Jenkins, secrets ✅ |
| `volto-embed-content` | `dd20bcd` | `ed2f293`, `6c8e06a`, `6831055`, `36f669a`, `dd20bcd` | idem ✅ |
| `volto-redirector` | `7abd242` | `846e2d5`, `93670eb`, `aec0aa9`, `7abd242` | idem ✅ |
| `volto-hero-block` | `bf51532` | `0259934`, `bf51532` | idem ✅ |
| `volto-globalsearch` | `1c6e077` | `f19fbe5`, `8814f9b`, `6e0e839`, `1c6e077` | Jenkins build #16 ✅ |
| `volto-eea-website-policy` | `3b118aa` | `144558e`, `859ddb9`, `3b118aa` | idem ✅ |

Dependințe (pentru pin): chatbot `720e124`, searchlib `2cdbd19` (branch `volto19`).

## Detalii și dovezi

- Analiza completă per repo (cauze, fix-uri, capcane) e în docs canonice (nu duplic):
  `docs/2026-10-16-volto19-coverage-and-migration/REPORT.md` → secțiunile
  „Batch 2 extins, 6 repo-uri” și „Capcane noi”.
- globalsearch #423 (hidratare): dovada repro-ului local:
  - build izolat (repo în afara monorepo-ului): `01-block-basics.cy.js` **pass**;
  - setup cu node_modules-ul părinte: **fail** — `TypeError: Cannot read properties of
    null (reading 'useEffect')` în `MatomoAppExtra` (dev) / React #423 (prod);
  - cauza: store pnpm 9 (`react-dom@18.2.0_react@18.2.0`) în imaginea de bază + install
    pnpm 10 (`react-dom@18.2.0(react@18.2.0)`) → două instanțe React;
  - fix `1c6e077` (clean install) → Jenkins #16 verde.
- Verificări auxiliare: `--frozen-lockfile` trece pe lock-urile noi; lock-urile vechi
  picau deja (drift față de core `a424fdb`).

## Metrici

- 6 repo-uri verzi; 2 dependințe (chatbot, searchlib) pinned pe branch-ul `volto19`.
- 1 commit de packaging în chatbot + 1 în searchlib (enabler pentru pin).
- 5 cicluri CI consumate pe globalsearch (razzle → hydration → clean-install).

## Igienă locală

- Containere de test șterse (`frontend-backend-1`, `gs-backend`); procese dev oprite;
  repo-ul globalsearch mutat la loc în `frontend/packages/` (fusese temporar în
  `/Users/alin/sandbox/gs-iso` pentru repro izolat).
