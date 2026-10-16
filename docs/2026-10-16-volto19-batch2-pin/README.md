# Batch 2 „repo-uri verzi" + pin git (sesiune 2026-10-16 seara)

**Status: 6/6 repo-uri verzi pe Jenkins.** Pin git din branch-ul `volto19` înlocuiește
shim-ul de `node_modules` la globalsearch/policy; globalsearch a mai avut nevoie de
un install curat în Dockerfile (React #423 la hidratare).

## Fapte cheie

- Repo-uri verzi (HEAD-uri): `volto-design-tokens` `003edec`, `volto-embed-content`
  `dd20bcd`, `volto-redirector` `7abd242`, `volto-hero-block` `bf51532`,
  `volto-globalsearch` `1c6e077`, `volto-eea-website-policy` `3b118aa`.
- Fix-uri în dependințe: chatbot `720e124`, searchlib `2cdbd19` (scos `prepare` din
  pachet — altfel pin-ul git e imposibil pe pnpm 10). **Unpin** după release-urile
  majore (vezi `TODO.md`).
- Docs canonice (nu duplica): `docs/2026-10-16-volto19-coverage-and-migration/` —
  `TODO.md`/`REPORT.md` actualizate în `c1dc2ad`; istoric campanie în
  `HANDOFF-BATCH-CAMPAIGN.md`.
- Fără release 4.1.6 chatbot (decizie user): următorul release e **major** (breaking:
  fără Yarn / fără Volto 17).

## Fișiere

- [DECISIONS.md](DECISIONS.md) — decizii și alternative respinse.
- [PLAN.md](PLAN.md) — faze și status.
- [REPORT.md](REPORT.md) — rezultate, dovezi, commit-uri.
- [TODO.md](TODO.md) — ce a rămas de făcut.
- [HANDOFF.md](HANDOFF.md) — pentru agentul următor (stare, primii pași, capcane).
