# HANDOFF — Plone Conf 2026 Talk Prep

**Next session focus:** Continue preparing the Plone Conf 2026 talk (deck build, materials collection, demo recording). The design interview (grill-me) is complete; all talk-level decisions are frozen in the two artifacts below. Do not re-open them without the speakers.

## Talk identity

- **Title:** From Volto 17 to 19: Upgrading Plone at the European Environment Agency
- **Slot:** Friday 25 September 2026, 11:55 — Maastricht (Van der Valk). 45 min = ~38 talk + ~7 Q&A
- **Speakers:** Alin Voinea (sections 1, 3, 5, 6-7) · Ionuț Dobricean (sections 2, 4)
- **Submission page:** https://2026.ploneconf.org/schedule/talks/from-volto-17-to-19-upgrading-plone-at-the-european-environment-agency
- **Status of the migration being presented:** Phases 0–3 done (64 addons dual V18/V19 compatible, EEA Cookieplone templates ready, real EEA frontend running on Volto 19.3.0 in dev). **No production cutover before the talk.** Talk claims degrade to Phase 0–2 if verification slips (decision at status check, 12–14 Sept).

## Frozen decisions (do not re-litigate)

1. Narrative: migration in flight — honest, not "we're done"
2. Structure: 7 sections, slide-by-slide in `docs/plone-conf-2026-deck-outline.md` (33 slides + 5 backup)
3. Deep dives: accordion-block (babel ×64), chatbot (razzle conditional require + Jest→Vitest); kitkat as narrative vehicle in S1.6/S4.3
4. New slides added this session: S1.7 "Why dual, not big-bang" (different projects/PMs/budgets) and S2.5 AI-assisted migration (Ollama+open-weights GLM/pi.dev for Alin, Codex/OpenAI for Ionuț, Claude at Eau de Web colleagues, EEA self-hosted Qwen)
5. Demo: real `frontend/` (Volto 19.3.0, 64 addons) as hero; template `--no-input` generation as recorded static beat; chatbot in demo with accordion-block fallback
6. Estate precision: 63 EEA addons + volto-sentry (collective-hosted, EEA-maintained) + 3 community addons (authomatic, subsites, rss-provider) — `volto19` branches pushed upstream, no forks
7. gitflow gets a dedicated slide (S4.3): PR checks, release automation, org-wide dependency bump after npm publish
8. 5 backup slides (B1–B5) with pre-written answers; B4 needs real numbers (weeks, PR count) before 12 Sept
9. Google Slides deck, ~34 slides; deck structure freezes at v1 (19 Sept)

## Artifacts (read these, don't duplicate)

- `docs/plone-conf-2026-deck-outline.md` — slide-by-slide outline + prep timeline + materials checklist
- `docs/plone-conf-2026-speaker-notes.md` — word-for-word speaker notes + handoff cues + backup answers
- `docs/plone-conf-2026-submission.md` — accepted abstract (source of headline numbers)
- Migration context (only if asked during Q&A prep): `docs/HANDOFF.md`, `docs/session-progress.md`, `docs/12-decision-log.md`

## Next session tasks (in order)

1. **Skeleton in Google Slides** (5–8 Sept): copy slide titles from outline, paste speaker notes into each notes field, mark SKIPPABLE #1/#2 and Backup slides
2. **Collect materials** (8–12 Sept): the 12 items in the outline's materials checklist (diffs, screenshots, diagram, numbers)
3. **Status check** (12–14 Sept): verify Phases 0–3 reality vs claims; fill B4 numbers; decide chatbot vs accordion demo fallback
4. **Record demo** (15–19 Sept): real frontend repo, pre-installed, timed screencast + 3 screenshots per beat
5. **Rehearsals** (21–23 Sept): 2 full runs with timer + simulated Q&A using backup slides

## Suggested skills for next session

- `grill-me` — if any talk decision is reopened, re-interview that branch only
- `plone-frontend-developer` — if the demo needs debugging (chatbot on V19, dev server)
- `handoff` — update this file after each work session

## Open items this session could not resolve

- B4 real numbers (weeks elapsed, PR count across 64 repos) — needs git history / Alin's memory
- Whether `frontend_project` template generation works end-to-end (claimed done in `continue.md`, but demo doesn't depend on it — slide static)
- Demo fallback decision (chatbot vs accordion) — blocked on 12–14 Sept status check