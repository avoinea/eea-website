# Campania „red → green" Volto 19 (2026-10-17, sesiunea 2)

**Status: 21 add-on-uri reparate și 21 PR-uri `volto19 → develop` deschise; dashboard 50 verzi / 15 roșii** (de la 32 roșii la începutul sesiunii).

## Fapte cheie

- Toate cele 13 repo-uri din mini-valul fail-fast sunt închise (batch A–D, 2026-10-17) + 8 repo-uri cu alte cauze (batch D–E): **21 total**, toate cu `Jenkins` aggregate `success` și `jenkins-stage-scan.sh` = `none`.
- **21 PR-uri** deschise (scriptul campaniei sare peste cele existente): anchors #45 … plotlycharts #208.
- Docs canonice actualizate: `docs/2026-10-16-volto19-coverage-and-migration/{TODO,REPORT}.md` (commit `35ad3f9` pe `main`).
- Design-system: `6c28303ea` (`prepare` → `husky:install`, instalabil din git); `volto-datahub` pinuit pe DS git (`fd7fd5c`).
- Rămân roșii pe branch: `volto-group-block`, `volto-object-widget`, `volto-searchlib`, `volto-slate-zotero`, `theme #395` + specialele (`frontend #284`, `policy #138`, `countup` skip, 3× `collective` excluse).

## Fișiere

- [DECISIONS.md](DECISIONS.md) — decizii, alternative respinse, override-uri.
- [PLAN.md](PLAN.md) — faze, status și operaționalul de continuare.
- [REPORT.md](REPORT.md) — rezultate, commit-uri, dovezi.
- [TODO.md](TODO.md) — ce a rămas deschis + închis.
- [HANDOFF.md](HANDOFF.md) — pentru sesiunea următoare.
