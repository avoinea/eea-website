# Campania PR `volto19 → develop` (sesiune 2026-10-16/17)

**Status: 34/36 PR-uri verzi; 2 blocaje documentate (frontend #284, policy #138).**
Toate cele 36 de repo-uri verzi `eea/*` au acum PR `volto19 → develop`
(35 deschise în această sesiune + `volto-accordion-block` #133 existent).

## Fapte cheie

- Lista sursă: dashboard-ul local `http://127.0.0.1:3210` (citește
  `frontend/mrs.developer.json`) — 68 rânduri, din care 64 `eea/*`; 36 verzi.
  Cele 4 `collective/*` au fost excluse (regula userului).
- Script nou, refolosibil (cu `--dry-run`, sare peste PR-urile existente):
  `.agents/skills/volto19-green-campaign/scripts/open-volto19-prs.sh`.
- Titlu PR: `chore: Volto 19 support`; la `volto-globalsearch` #79 body-ul
  conține nota + checklist-ul de unpin chatbot/searchlib.
- Fix-uri pe branch-urile `volto19` (detalii în `REPORT.md`): `volto-tableau`
  `3c11356`, `volto-datablocks` `56913c3` + `5f8b49a` + `22b3116`,
  `volto-eea-website-policy` `bcd82b3`.
- Docs canonice (nu duplica): `docs/2026-10-16-volto19-coverage-and-migration/`;
  handoff anterior: `docs/2026-10-16-volto19-batch2-pin/`.

## Fișiere

- [DECISIONS.md](DECISIONS.md) — decizii, alternative respinse, override-uri.
- [PLAN.md](PLAN.md) — faze, status și operaționalul de continuare.
- [REPORT.md](REPORT.md) — rezultate, metrici, dovezi.
- [TODO.md](TODO.md) — ce a rămas de făcut.
- [HANDOFF.md](HANDOFF.md) — pentru agentul următor (stare, pași, capcane).
