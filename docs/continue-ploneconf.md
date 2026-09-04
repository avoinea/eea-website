# Continue — Plone Conf 2026 Talk

Companion to `docs/HANDOFF-PLONECONF.md` (decisions + context) and
`docs/plone-conf-2026-deck-outline.md` (slide-by-slide plan).
The migration itself has its own continue file: `docs/continue.md`.

## Today = 4 September 2026. Talk = 25 September 2026, 11:55, Maastricht.

## Checklist (checkbox-level)

### Week 1 (5–8 Sept) — Skeleton
- [ ] Create Google Slides deck (2 editors: Alin + Ionuț)
- [ ] S1.1–S7.5 titles from `plone-conf-2026-deck-outline.md`
- [ ] Paste speaker notes from `plone-conf-2026-speaker-notes.md` into each notes field
- [ ] Mark SKIPPABLE #1 (S2.4) and #2 (S4.4) in slide titles (internal marker, delete before showtime)
- [ ] Add B1–B5 backup slides after "Thank you" slide
- [ ] Insert QR + links on S7.4 (cookieplone-templates repo, docs/, blog post placeholder, talk page)

### Week 2 (8–12 Sept) — Materials (owners: Ionuț sec 2/4, Alin rest)
- [ ] Diff: accordion-block babel.config.js before/after
- [ ] Diff: chatbot razzle.extend.js conditional require
- [ ] Diff: chatbot Vitest test + snapshot (one example)
- [ ] Screenshot: Jenkinsfile dual-stage (V19 full / V18 cypress-only)
- [ ] Screenshot: Dockerfile V18 vs V19 layout handling
- [ ] Screenshot: gitflow js-release.sh org-crawl dependency bump
- [ ] Diagram: Cookieplone extension flow (config → merge → pre_prompt.sh → wizard)
- [ ] Screenshot: `tree packages/` from migrated frontend
- [ ] Screenshot: GitHub org `*-frontend` repo list (estate slide)
- [ ] **Real numbers for B4**: weeks for Phases 0–3, PR count across 64 repos
- [ ] Cross-review: Alin reviews Ionuț's sections 2+4, Ionuț reviews Alin's 1+3+5+6-7

### Status check (12–14 Sept) — claims freeze
- [ ] Verify Phase 0: gitflow image built/pushed, V18 addon release works
- [ ] Verify Phase 1: 64 addons green on V18 CI (Cypress)
- [ ] Verify chatbot runs on V19 (demo decision: chatbot → else accordion fallback)
- [ ] Fill B4 numbers
- [ ] Confirm or downgrade claims in outline (target b vs a) + adjust S6.1 roadmap slide

### Week 3 (15–19 Sept) — Completion
- [ ] All 34 slides filled (no more skeleton text)
- [ ] Demo screencast recorded, timed ≤7 min, pre-installed repo
- [ ] 3 screenshots per demo beat stored as fallback
- [ ] Template `--no-input` generation recorded (1 min beat)
- [ ] Deck v1 complete → **structure freezes**

### Week 4 (21–25 Sept) — Delivery
- [ ] Rehearsal 1 with timer (Alin + Ionuț, full 45 min incl. Q&A)
- [ ] Rehearsal 2 with fake audience (Eau de Web colleagues) + simulated Q&A from B1–B5
- [ ] Fix timing leaks; confirm the 2 handoffs are under 15 seconds each
- [ ] 24 Sept: last pass at hotel; test HDMI/USB-C + offline video copy of demo
- [ ] 25 Sept 11:55: talk. After: publish deck + blog post, update links slide

## Rules

- Deck structure frozen after 19 Sept — only fill-in, no re-arc
- No promise on stage about satellite frontends' migration timelines (plan, not promise)
- Never live `pnpm install` in the demo
- If claims can't be verified at status check, downgrade onestly (S6.1 covers it)