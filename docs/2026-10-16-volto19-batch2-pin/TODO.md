# TODO (deschis)

- [ ] **Unpin chatbot + searchlib** — owner: user (la PR-ul `volto19→develop`).
      După release-urile **majore** ale `volto-eea-chatbot` / `volto-eea-searchlib`:
      scoate override-urile `github:...#volto19&path:...` din `pnpm.overrides`
      (globalsearch, policy), pune versiunile npm, regen lock, retestează.
      De bifat explicit în checklist-ul PR-ului (sau merge în ordine + retestare).
- [ ] **PR `volto19→develop`** pentru `volto-globalsearch` și `volto-eea-website-policy`
      (include pin-urile + fix-ul de clean-install la globalsearch).
- [ ] **CI `volto-eea-chatbot` roșu** — fail-fast stale (V18 integrare) + 35 lint
      warnings (`--max-warnings=0`); de reparat separat, înainte de release-ul major.
- [ ] **Mini-val fail-fast**: 13 repo-uri rămase (listă în
      `docs/2026-10-16-volto19-coverage-and-migration/TODO.md`).
- [ ] (opțional, preventiv) același `rm -rf /app/node_modules` în Dockerfile-ul
      `volto-eea-website-policy` — acum nu e necesar (verde).
- [ ] De documentat de ce `/Plone/cypress` dispare înainte de cleanup-ul din afterEach
      (datorie mai veche, în docs canonice).

# Închis în sesiunea aceasta

- [x] Batch 2 extins: 6/6 repo-uri verzi (vezi `REPORT.md`).
- [x] Pin git chatbot + searchlib (enabler: `prepare` scos din pachete).
- [x] globalsearch React #423 — clean install în Dockerfile (`1c6e077`).
- [x] Docs canonice actualizate (`46de60b`, `c1dc2ad`).
