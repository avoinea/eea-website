# Plone Conf 2026 — Deck Outline

**Talk:** From Volto 17 to 19: Upgrading Plone at the European Environment Agency
**When:** Friday, 25 September 2026, 11:55 — Maastricht (Van der Valk, de Apostelhoeve / Saal Martinus)
**Speakers:** Alin Voinea (sections 1, 3, 5, 6-7) · Ionuț Dobricean (sections 2, 4)
**Format:** 45 min total → **~38 min talk + ~7 min Q&A** (Q&A included in slot)
**Deck:** Google Slides, ~33 slides + 5 backup slides
**Claim baseline (as of conference):** Phases 0–3 done — 64 addons dual V18/V19 compatible, EEA Cookieplone templates ready, real EEA frontend running on Volto 19.3.0 in dev. No production cutover yet (Phase 6).

**Narrative in one sentence:** "Last year we patched 17→18 on yarn and it worked; this year the same recipe is impossible — Volto 19 is a new ecosystem, so we regenerate with Cookieplone, keep 64 addons dual-compatible, automate releases, and let AI do the batch work."

---

## Section 1 — Context & Scale (Alin, ~7.5 min)

**S1.1 — Title slide**
- Title, speakers, conference, QR to repo links (see S7.4)
- Notes: one-liner: "20 years of Plone, 64 addons, one big jump."

**S1.2 — EEA in numbers**
- Plone for 20 years, Volto since 2019
- www.eea.europa.eu: 64 Volto addons, 1000+ GitHub repos
- CI/CD: Jenkins + Docker Hub (eeacms/) + Rancher + SonarQube, gitflow releases
- Notes: establish scale BEFORE the jump. Everything here is verified — don't round up.

**S1.3 — Last year: 17→18 on yarn (the recipe that worked)**
- Incremental upgrade, yarn-based, patch-in-place
- It worked. Site moved 17 → 18 with manageable pain
- Notes: keep it short (1-2 min). This slide exists to be contradicted by the next one.

**S1.4 — This year: why the same recipe dies**
- Volto 19 drops yarn entirely; forks razzle + babel into @plone-scoped packages; Jest→Vitest; superagent 3→10; react-dnd→dnd-kit; language settings removed from config; pnpm 10 workspaces
- "For one addon, a weekend. For 64 addons on both versions simultaneously — an engineering project."
- Notes: the pivot of the talk. Slow down here.

**S1.5 — The EEA Volto estate (multi-project)**
- 1 main site × 64 addons → migrated to 19.3.0 (in dev)
- Precision for Q&A: 63 EEA-maintained add-ons (github.com/eea) + volto-sentry (hosted under Plone collective but EEA-maintained — our garden too) + 3 true community add-ons from Plone collective (volto-authomatic, volto-subsites, volto-rss-provider) — the community ones get `volto19` branches pushed back upstream, no forks
- 8 satellite frontends already on Volto 18 (yarn): advisory-board, insitu, cca, ied, marine, freshwater, bise, fise
- 3 stragglers: clms (17), climate-energy (16), ims (15)
- Screenshot: GitHub org repo list
- Notes: "8 of 11 are template-ready once addons are dual-compatible; 3 are separate projects." Sets up why templates matter (section 3).

**S1.6 — volto-eea-kitkat: the known-good set**
- KGS bundle pinning dozens of @eeacms addons, used by all EEA projects
- One PR bump = whole fleet updated
- Notes: introduces the release vehicle. Full circle in section 4 (gitflow). Skip deep detail here.

**S1.7 — Why dual compatibility, not big-bang (the org answer)**
- The naive alternative: freeze everything, migrate all 64 addons + 11 frontends + backend in one coordinated jump
- Reality: different projects, different project managers, different budgets, different release windows
- A big-bang needs every PM's budget and every team's calendar aligned at once — that alignment is the single point of failure
- Dual compatibility converts one big-bang into a rolling migration: each project moves to 19 when IT is ready; the fleet stays mixed in the meantime
- Cost of dual: the shim patterns (section 2). Cost of big-bang: org-wide freeze + all-or-nothing risk
- Notes: this is the "why" slide for section 2's premise. One sentence: "big-bang was never an option — not technically, organizationally." Photographable.

---

## Section 2 — Breaking Changes & Dual Compatibility (Ionuț, ~12.5 min)

**S2.1 — Section intro: the 7 breaking changes (table)**
- One row each: change, how many addons affected, one-line fix
  - babel.config.js (`presets: ['razzle']` → `require('@plone/volto/babel')`) — 64
  - razzle-dev-utils → conditional require — 2 (chatbot, searchlib)
  - Jest → Vitest — test suites (79 test files, 22 snapshots in chatbot alone)
  - superagent 3→10 error handling — 5 (already safe)
  - react-dnd → dnd-kit — 1 structural (website-theme)
  - `<img>` → `<Image>` — 5 (already handled)
  - language settings removed from config — 3 (backend API instead)
- Notes: fast slide, no code yet. Message: "small known surface, big coordination problem."

**S2.2 — Deep dive 1: the one-line fix × 64 repos (babel)**
- Diff: `volto-accordion-block/babel.config.js` before/after (the community's most-used addon!)
- Pattern: fix must work on BOTH 18 and 19
- Notes: mention the batch mechanism — a script, not 64 manual edits. Sets up AI slide.

**S2.3 — Deep dive 2: conditional require (razzle fork)**
- Diff: `volto-eea-chatbot/razzle.extend.js` — `razzle-dev-utils/makeLoaderFinder` vs `@plone/razzle-dev-utils`
- Pattern name: **compatibility shim on detection, not version forks** — one codebase, no branches, no double releases
- Notes: this is THE takeaway pattern of the talk. Slow, annotate the diff live.

**S2.4 — Deep dive 3: Jest → Vitest (chatbot)**
- 79 test files, 22 snapshots migrated; API-compatible but not zero-touch: `vi.mock`, snapshot format, jsdom env, per-workspace config
- Notes: be concrete; show one test diff. If time is short → **SKIPPABLE #1**

**S2.5 — How we touched 64 repos: AI-assisted migration**
- Table: Alin → Ollama + open-weights (GLM-5.x), pi.dev · Ionuț → Codex/OpenAI · Eau de Web colleagues → Claude · **EEA in-house: self-hosted Qwen** (highlight: digital autonomy, conference theme)
- "No PR without human review" + "AI scaled execution, it did not replace judgment"
- Notes: Alin takes this slide (handoff #1). ~2 min. Connect Ollama/Qwen to "Own Your Digital Future" theme.

---

## Section 3 — Regenerate, Don't Patch (Alin, ~8 min)

**S3.1 — Why regenerate instead of patch**
- `src/config.js` already empty (all config in addons) → regeneration cost was boilerplate-only
- Volto 19 changes are structural (razzle/babel forks, pnpm workspaces, Vitest)
- Official upgrade guide + Cookieplone recommend it
- Notes: tie back to S1.3: "patching worked on 18; on 19 we regenerate."

**S3.2 — The pnpm workspace structure**
- `packages/website/` + `core/`, workspace globs, `mrs.developer.json` → `packages/` output
- Screenshot: real `tree packages/` from EEA frontend
- Notes: emphasize "not a monorepo — a single-project workspace" (decision-log Q2/Q8).

**S3.3 — EEA Cookieplone templates: the extension mechanism**
- Flow diagram: `cookieplone-config.json` → merge with upstream → `pre_prompt.sh` hook → `cookieplone.json` v2 → wizard with 6 prompts instead of 11
- Snippet: `pre_prompt.sh` (the hook that makes EEA overrides possible WITHOUT forking cookieplone)
- Notes: the mechanism slide. Public repo: github.com/eea (cookieplone-templates fork).

**S3.4 — Lessons from extending Cookieplone (photographable slide)**
- 4-5 bullets: `extends` merge is `dict.update()` (override, not remove) · `pre_prompt.sh` runs after merge, before wizard · `format: "constant"` hides fields from prompts · `_copy_without_render` protects `${{ }}` in GitHub Actions files · upstream Makefile is fine — append targets via hook
- Notes: none of this is in official docs. Pure community value.

**S3.5 — Template as scale plan**
- "frontend_project + frontend_addon: the migration distilled"
- The 8 V18 satellites: generate → config → done (days, not months)
- Notes: closes the loop opened in S1.5.

---

## Section 4 — CI/CD on Two Volto Versions (Ionuț, ~8 min)

**S4.1 — Dual-stage pipeline (screenshot, not code)**
- One Jenkinsfile: V19 stage = full suite (lint, vitest, cypress); V18 stage = Cypress only
- Framed as "any CI can do this" — Jenkins is just our vehicle
- Notes: don't dwell on Jenkins-specifics; the pattern is the product.

**S4.2 — One Dockerfile, two layouts**
- V18: `/setupAddon` + `yarn install` · V19: copy addon to `/app/packages/` + `pnpm install`
- Gotcha: `plone/frontend-builder:19` has no `/setupAddon`
- Notes: layout detection, not version branching — same philosophy as S2.3.

**S4.3 — eea.docker.gitflow: release automation**
- PR checks: changelog updated, version bumped, format `x.y.z`, not already tagged, > last version
- Release on develop→master merge: release-it changelog, tag, npm publish, Docker image → Docker Hub, Rancher catalog entry, SonarQube tags
- The magic (annotate on screenshot of js-release.sh): after `npm publish`, crawls ALL org repos (`*-frontend`, `volto-*-kitkat`, `volto-*-policy`) and auto-bumps the addon version in each `develop` branch
- Notes: "one addon release ripples across 11 frontends + kitkat automatically. That's why 64×11 is survivable." ~2 min.

**S4.4 — Package manager agnostic by design**
- `detect_package_manager()` reads `packageManager` field → `pnpm` vs `yarn`
- Lockfiles (`pnpm-lock.yaml` / `yarn.lock`), changelog tags `[PNPM]` / `[YARN]`
- Notes: what changed for Volto 19 is detection, not architecture. **SKIPPABLE #2** if behind schedule.

---

## Section 5 — Demo (Alin, ~7 min, recorded + screenshots fallback)

**S5.1 — Demo intro slide**
- "The real thing: eea-website-frontend, Volto 19.3.0, 64 addons"

**Demo beats (recorded screencast, pre-installed repo):**
1. `tree packages/` — the 64 addons in the workspace
2. `pnpm --filter ... test` — Vitest passing on volto-eea-chatbot
3. Dev server + chat block live in browser (AI block on Volto 19)
4. (1 min, recorded) `cookieplone frontend_project --no-input` — same structure, zero manual work
- Fallback: if chatbot isn't verified on V19 by 15 Sept → accordion-block demo
- Notes: never live `pnpm install`. 3 screenshots ready per beat.

---

## Section 6+7 — Status & Takeaways (Alin, ~3 min)

**S6.1 — Roadmap: where we are (honesty slide)**
- Phases 0-3: done ✅ · Phase 4 (addon pnpm): next · Phase 5 (backend 6.2): blocked on eeacms/plone-backend:6.2.x image · Phase 6 (cutover): planned
- Notes: honesty is a feature. Potential Part-2 hook for Plone Conf 2027 ("cutover + post-migration lessons").

**S6.2 — Takeaways (photographable slide)**
- Dual compatibility: shims on detection, not version forks
- Regenerate > patch when the ecosystem shifts
- Templates = migration distilled (your org can adapt this)
- Release automation scales what manual work cannot
- AI-ready repo: AGENTS.md + .agents/skills — execution scaled by agents, judgment stays human
- Notes: open with the line: "AI scaled our execution, not our judgment. Local models kept it ours."

**S7.4 — Links slide (QR)**
- cookieplone-templates repo (public) · docs/ of this monorepo · blog post (when live) · talk page
- Notes: leave up through Q&A.

**S7.5 — Thank you / Questions**

---

## Backup slides (after thanks, "Backup" numbered, speaker notes = 2-3 sentence answers)

**B1 — "Why not Playwright?"** Cypress is native to Volto 19; templates + Docker images + core expect it. Playwright migration = separate project. (Decision-log Q7)

**B2 — "How much does Jest→Vitest hurt?"** API-compatible, not zero-touch: `vi.mock`, snapshot format, jsdom. Concrete: chatbot's 79 files. (S2.4 detail)

**B3 — "How hard is backend 6.1→6.2?"** Incremental: image + constraints + `horse-with-no-namespace`. Currently blocked on EEA's own 6.2.x image. Honest status.

**B4 — "How long did it take?"** Phases 0-3 in ~N weeks, X PRs across 64 repos, batch scripts + AI for the bulk, humans for review/release. → **FILL WITH REAL NUMBERS before 12 Sept**

**B5 — "Which addon fought back?"** volto-eea-website-theme: react-dnd structural fix (deps + registered loadables). Every migration has one — here's ours.

---

## Prep timeline (today = 4 Sept; talk = 25 Sept, 11:55)

| When | What | Who |
|---|---|---|
| 5–8 Sept | Fill skeleton slides in Google Slides (titles + 1-2 sentences each) | Alin |
| 8–12 Sept | Collect raw materials: 3 diffs (accordion babel, chatbot razzle.extend, chatbot Vitest), Jenkinsfile screenshot, Dockerfile dual-layout, gitflow js-release.sh screenshot, Cookieplone flow diagram, org repos screenshot | Ionuț (sec 2/4), Alin (rest) |
| 12–14 Sept | Migration status check → confirm or downgrade claims (target b vs a); fill B4 numbers | both |
| 15–19 Sept | Deck complete v1 + demo recorded | both |
| 21–23 Sept | 2 full rehearsals with timer + simulated Q&A (colleagues from Eau de Web) | both |
| 24 Sept | Last pass at hotel | Alin |
| 25 Sept 11:55 | Talk | — |

**Rule:** deck structure freezes 1 Sept-style at v1 (19 Sept) — after that only fill-in, no re-arc.

## Materials checklist

- [ ] Diff: accordion-block babel.config.js (before/after)
- [ ] Diff: chatbot razzle.extend.js (conditional require)
- [ ] Diff: chatbot Vitest test + snapshot (one example)
- [ ] Screenshot: Jenkinsfile dual-stage (V19 full / V18 cypress)
- [ ] Screenshot: Dockerfile V18 vs V19 layout handling
- [ ] Screenshot: gitflow js-release.sh org-crawl bump section
- [ ] Diagram: Cookieplone extension flow (config → merge → pre_prompt → wizard)
- [ ] Screenshot: `tree packages/` from migrated frontend
- [ ] Screenshot: GitHub org `*-frontend` repo list
- [ ] Real numbers: weeks elapsed, PR count, B4 timing
- [ ] Demo screencast (recorded, timed) + 3 screenshots per demo beat
- [ ] Blog post / docs link for final QR slide
