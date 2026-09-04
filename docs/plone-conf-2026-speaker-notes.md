# Plone Conf 2026 — Speaker Notes (word-for-word)

Companion to `plone-conf-2026-deck-outline.md`. Paste these into Google Slides speaker notes.
Style: spoken English, first person plural where shared. `[...]` = action/cue, not spoken.
Handoff cues marked **HANDOFF**.

---

## S1.1 — Title (Alin)

Good morning, everyone. I'm Alin Voinea, from Eau de Web in Romania, and with me is Ionuț Dobricean. Today: how we're taking the European Environment Agency's website — twenty years of Plone, sixty-four Volto add-ons — from Volto 17 to Volto 19. This is not a "we're done, here are the lessons" talk. This is a migration in flight — you'll see exactly where we are, what's proven, and what comes next.

**Notes:** One-liner: "20 years of Plone, 64 addons, one big jump." Keep under 45 seconds.

---

## S1.2 — EEA in numbers (Alin)

Let me set the scale first, because everything else depends on it. The EEA website has run Plone for twenty years, and Volto since 2019. Today www.eea.europa.eu depends on sixty-four Volto add-ons — all ours, all open source — across more than a thousand GitHub repositories. And it's not just code: releases go through Jenkins, images land on Docker Hub, deployments run on Rancher, quality gates in SonarQube, and releases are automated by our own gitflow tooling. So when I say "upgrade," I don't mean one repo. I mean a fleet.

**Notes:** Everything on this slide is verified — don't round numbers up.

---

## S1.3 — Last year: 17→18 on yarn (Alin)

Now, last year we did a very similar thing: we upgraded from Volto 17 to Volto 18. And honestly? It went well. It was an incremental upgrade — patch the project, bump the deps, keep yarn, keep the same tooling. Painful in places, but manageable. That experience shaped how we started *this* migration — we assumed the same recipe would work again.

**Notes:** Keep to 1-2 min max. This slide exists to be contradicted by the next one.

---

## S1.4 — Why the same recipe dies (Alin)

Except it doesn't. Volto 19 is not "a newer Volto" — it's a new ecosystem. It drops yarn entirely. It forks razzle and babel into @plone-scoped packages. Jest is replaced by Vitest. superagent jumps from 3 to 10. react-dnd is swapped for dnd-kit. Language settings move out of config. And the whole project structure moves to pnpm 10 with workspaces.

For a project with one addon? A weekend. But our sixty-four add-ons have to work on **both** Volto 18 and Volto 19 — simultaneously — for the entire transition, because our satellite sites stay on 18 until we migrate them too. That's not an upgrade anymore. That's an engineering project.

**Notes:** The pivot of the talk. Slow down. Let "both versions simultaneously" land before advancing.

---

## S1.5 — The EEA Volto estate (Alin)

And here's the full estate. One main site with the sixty-four add-ons — that one is already running Volto 19.3.0 in development. Sixty-three of those are maintained by EEA itself — plus volto-sentry, which lives under the Plone collective on GitHub but is maintained by us — so effectively our whole garden. We do consume a little from the community — volto-authomatic, volto-subsites, volto-rss-provider from the Plone collective. And here's the point for this room: we don't fork those. We push `volto19` branches back upstream into the collective repos, so the community gets the compatibility work too. Eight satellite frontends — marine, freshwater, biodiversity, forest, advisory board, insitu, cca, ied — all on Volto 18 on yarn today. And three stragglers: clms on 17, climate-energy on 16, ims still on 15.

Why does this matter? Because dual compatibility was never optional. Our add-ons and our kitkat bundle serve **all** of these sites. While the fleet is mixed, one codebase must speak two Volto dialects.

**Notes:** Screenshot of the GitHub org list. Sets up the templates story in section 3.

---

## S1.6 — volto-eea-kitkat (Alin)

One more piece: volto-eea-kitkat. It's our known-good set — one add-on that pins the versions of dozens of @eeacms add-ons, and every EEA project installs that bundle instead of individual packages. That means one pull request can raise the whole fleet. Remember this slide — it comes back when we talk about releases.

**Notes:** ~45 seconds. Full circle in S4.3.

---

## S1.7 — Why dual compatibility, not big-bang (Alin)

Now, the obvious question: why keep every add-on working on both versions? Why not just freeze everything and migrate it all in one jump? Because that jump needs sixty-four add-ons, eleven frontends and a backend upgrade to land at the same moment — and our projects don't share one budget or one calendar. Different projects, different project managers, different release windows. A big-bang isn't hard technically — it's impossible organizationally.

So we inverted it: dual compatibility lets every project move to Volto 19 when *it* is ready, and the fleet stays mixed while that happens. The price is the shim work you're about to see. The alternative price was an org-wide freeze — we chose the one we could pay.

**Notes:** Deliver slowly — the room will recognize "different PMs, different budgets." Bridge to handoff: "so the add-ons must be bilingual. Ionuț shows what that costs in practice."

---

## S2.1 — The 7 breaking changes (Ionuț) — **HANDOFF**

**HANDOFF (Alin):** "So what does bilingual add-ons actually cost? Ionuț did most of that migration — he'll show you exactly what broke and how we fixed it." → leave stage.

Thank you, Alin. Here's the full list of breaking changes we hit. Seven categories. [WALK THE TABLE, one line each:] The babel config — all sixty-four repos. The razzle fork — two add-ons. Jest to Vitest — our test suites. superagent 3 to 10 — five add-ons, already safe. react-dnd — one structural fix. img to Image — five, already handled. Language settings — three add-ons, moved to the backend API.

Notice the shape of this: a **small, known surface** — but a big coordination problem. Every fix must land on sixty-four repos, and each fix must run on Volto 18 *and* 19.

**Notes:** Fast slide, no code yet. The table is the map; the next three slides zoom in.

---

## S2.2 — Deep dive 1: babel × 64 (Ionuț)

Let's start with the one that hit every single repo. [POINT AT DIFF] This is volto-accordion-block — which many of you in this room use — but the same file existed in all sixty-four add-ons. Before: `presets: ['razzle']`. After: `require('@plone/volto/babel')`.

Here's the point I want you to take home: we did not do sixty-four manual edits. The fix is a single line with a mechanical pattern, so a script — driven by agents, which I'll show you in a minute — applied it across the org. A one-line fix is trivial. A one-line fix at sixty-four-repo scale is an automation problem.

**Notes:** Diff: accordion-block babel.config.js before/after. Emphasize "script, not manual".

---

## S2.3 — Deep dive 2: conditional require (Ionuț)

This one is my favourite, because it's the pattern behind everything. [POINT AT DIFF] This is the chatbot add-on's razzle.extend.js. On Volto 18, `razzle-dev-utils/makeLoaderFinder` exists. On Volto 19, razzle is forked into `@plone/razzle` and the utility moved. 

The naive answers are: maintain two branches, or release two versions of the add-on. We did neither. The fix is a conditional require — try the new path, fall back to the old one. One codebase, running on both versions, no forks, no double releases.

That's the pattern I'd like you to remember from this talk: **compatibility shims on detection, not version forks.** You'll see this philosophy again in the pipeline section.

**Notes:** THE takeaway pattern. Annotate the diff live. Slow.

---

## S2.4 — Deep dive 3: Jest → Vitest (Ionuț) — **SKIPPABLE #1**

Now, tests. Volto 19 replaces Jest with Vitest. The good news: the API is deliberately compatible. The honest news: it's not zero-touch. [SHOW TEST DIFF] `jest.mock` becomes `vi.mock`, the snapshot format changed slightly, the jsdom environment is configured differently, and each workspace needs its own config.

To make it concrete: the chatbot add-on alone has seventy-nine test files and twenty-two snapshots. Most of those migrated with minimal edits — but "most" is doing real work in that sentence.

**Notes:** If behind schedule: cut this slide, keep the table row, mention B2 in Q&A.

---

## S2.5 — AI-assisted migration (Alin) — **HANDOFF**

**HANDOFF (Ionuț):** "And now — how did we actually move that fast across sixty-four repos? Alin will tell you, and then show you how we rebuilt the project itself." → leave stage.

Thank you. So — the batch work you just saw, times sixty-four repos, was not done by hand. We ran it with AI agents. [WALK TABLE] I run Ollama locally with open-weights models — GLM-5.x among them — plus pi.dev. Ionuț works with Codex and OpenAI. Our colleagues at Eau de Web use Claude. And — this one I want you to notice — EEA runs Qwen in-house, self-hosted, on our own infrastructure.

That last row is the theme of this conference, isn't it? Digital autonomy. We didn't just *use* AI — we used AI on infrastructure we control.

Two rules made this safe: **no PR went in without human review**, and the agents did batch execution — the judgment stayed with us.

**Notes:** ~2 min. Highlight the Qwen row visually. Line: "AI scaled execution, it did not replace judgment."

---

## S3.1 — Why regenerate, not patch (Alin)

So: the add-ons are handled. Now the project itself. Why did we regenerate from scratch instead of patching our existing frontend? Three reasons. First, our `src/config.js` was already empty — everything lives in add-ons — so regeneration would only touch boilerplate. Second, Volto 19's changes are structural — the razzle and babel forks, pnpm workspaces, Vitest — exactly the kind of thing that's safer to generate than to hand-edit. Third, the official upgrade guide and Cookieplone both point this way.

Last year we patched. This year we regenerated. Remember that contrast — it's the core decision of this migration.

**Notes:** Tie back to S1.3 explicitly.

---

## S3.2 — The pnpm workspace (Alin)

This is the structure Cookieplone generates — and what our real frontend looks like today. [POINT] A `packages/website` workspace, the Volto core in `core/`, and — the important part — all our add-ons land in `packages/` via mrs.developer. pnpm resolves them as workspace packages automatically; no symlinking games.

One clarification, because people ask: this is **not** a monorepo. It's a single-project workspace. Frontend and backend remain separate repos with separate pipelines.

**Notes:** Real `tree packages/` screenshot. Preempt the "is this a monorepo?" question.

---

## S3.3 — The Cookieplone extension mechanism (Alin)

Now — how do you make Cookieplone generate *EEA* projects, with our Jenkins, our Dockerfiles, our conventions — without forking the whole tool? This is the flow. [WALK DIAGRAM] Our config merges with the upstream template. Then a `pre_prompt.sh` hook runs — after the merge, before the wizard — and it does three things: it strips the prompts we don't want, converts the config to the v2 format with our constants, and appends our Makefile targets. Result: the wizard asks six questions instead of eleven, and everything else is baked in.

**Notes:** Show pre_prompt.sh snippet. Public repo — link on final slide.

---

## S3.4 — Lessons from extending Cookieplone (Alin)

Five things we learned that are in exactly zero documentation pages: The `extends` merge is `dict.update` — you can override values but never remove upstream keys. The `pre_prompt` hook runs after merge but before the wizard — that's what makes overrides possible. `format: constant` hides fields from the prompts entirely. `_copy_without_render` is how you stop Jinja from eating `${{ }}` syntax in GitHub Actions files. And: don't override the upstream Makefile — append your targets via the hook.

Photograph this slide. This is the part that would have saved us a week.

**Notes:** This slide gets photographed. Deliver the last line with a smile.

---

## S3.5 — Template as scale plan (Alin)

So why invest in templates, beyond good hygiene? Because the main site was only the first project. [POINT BACK] Remember the eight satellites on Volto 18? For them, this template is the whole plan: generate, fill in your config, done — days, not months. The add-ons they need are already dual-compatible, kitkat carries the versions. And the three stragglers on 15, 16 and 17? Separate projects, but the template still removes the boilerplate phase.

**Notes:** Closes the loop from S1.5. Don't promise timelines for the satellites — "plan, not promise".

---

## S4.1 — Dual-stage pipeline (Ionuț) — **HANDOFF**

**HANDOFF (Alin):** "One more piece makes this fleet manageable: what happens when you press release. Ionuț has the pipeline story." → leave stage.

Thanks. Here's the trick with CI: we run the **same** add-on on **both** Volto versions, in the same pipeline. [POINT AT SCREENSHOT] Stage one: Volto 19 — the full suite: lint, Vitest, Cypress. Stage two: Volto 18 — Cypress only. Why only Cypress on 18? Because maintaining both Jest and Vitest in every add-on, forever, is a tax nobody should pay. Cypress is the primary quality gate; unit tests live on the 19 side.

This is Jenkins at EEA — but there's nothing Jenkins-specific about it. GitHub Actions, GitLab, whatever: two stages, one repo, both versions.

**Notes:** Screenshot, not code. Pattern over tool.

---

## S4.2 — One Dockerfile, two layouts (Ionuț)

The same trick continues into the container. On Volto 18, the frontend-builder image has a `/setupAddon` script and expects a yarn install. On Volto 19? No `/setupAddon` — you copy your add-on into `/app/packages/` and run `pnpm install`. So our Dockerfile detects the layout and does the right thing for each. 

Same philosophy again: detect and adapt — don't fork.

**Notes:** Gotcha callout: `plone/frontend-builder:19` has no `/setupAddon`. We learned this the hard way, now you don't have to.

---

## S4.3 — eea.docker.gitflow (Ionuț)

Now the piece that makes sixty-four repos survivable: our gitflow image. Before any release, it checks the pull request: changelog updated? version bumped? format is x.y.z? not already tagged? bigger than the last release? You literally cannot release by negligence.

When develop merges to master: release-it generates the changelog from commits, cuts the tag, publishes to npm, builds the Docker image to Docker Hub, updates the Rancher catalog, refreshes SonarQube tags. One merge, everything.

And here's the part I love — [POINT AT CODE] after `npm publish`, gitflow crawls our entire GitHub org — every non-archived `*-frontend`, every `volto-*-kitkat`, every `volto-*-policy` repo — and automatically bumps the just-released version in each one's develop branch. One addon release ripples across eleven frontends and kitkat automatically. That is why sixty-four-times-eleven is survivable.

**Notes:** ~2 min. The org-crawl bump is the wow moment — annotate the js-release.sh screenshot.

---

## S4.4 — Package manager agnostic (Ionuț) — **SKIPPABLE #2**

One thing that changed for Volto 19: the package manager. But notice *how* it changed. `detect_package_manager` reads the `packageManager` field and routes to pnpm or yarn. Lockfiles handled per manager, changelog tags `[PNPM]` alongside `[YARN]`.

The tool is package-manager-agnostic **by design** — same philosophy as everything else in this talk: detect and adapt, don't fork.

**Notes:** If behind schedule: cut, fold into Q&A (B-slides).

---

## S5.1 — Demo intro (Alin) — **HANDOFF**

**HANDOFF (Ionuț):** "Time to see it run. Alin takes it home." → leave stage.

Enough slides. Let me show you the real thing. This is not a sample project — this is eea-website-frontend. Volto 19.3.0, sixty-four add-ons, the workspace we just talked about, running in development. [RUN DEMO BEATS] ... And last: one minute, recorded — generating a fresh EEA project from our Cookieplone template. Same structure. Zero manual work.

**Notes:** Recorded screencast. Pre-installed repo — never a live pnpm install. If chatbot isn't verified on V19 by 15 Sept → accordion-block demo. 3 screenshots per beat as fallback.

---

## S6.1 — Roadmap (Alin)

Where are we, honestly? Phases zero through three: done — you've seen all of them today. Phase four, moving the add-ons to pnpm publishing: next. Phase five, the backend to Plone 6.2: incremental, currently waiting on our own 6.2 backend image. Phase six, production cutover: planned.

I'm telling you this straight because this is a community of practitioners — you know the difference between "migrated" and "in production." When we cut over, that's part two of this story. Maybe see you in Maastricht again next year for it.

**Notes:** Honesty slide. Don't oversell. The 2027 hook lands well if delivered dry.

---

## S6.2 — Takeaways (Alin)

Five things to take home. One: dual compatibility means shims on detection — never version forks. Two: when the ecosystem shifts, regenerate — don't patch. Three: templates are your migration, distilled — adapt ours or write yours. Four: release automation scales what manual work cannot. And five — build AI-ready repos. Agents in `AGENTS.md`, skills your team curates, execution scaled by machines and judgment kept by humans. AI scaled our execution — not our judgment. And local models kept it ours.

**Notes:** Open with the closing line on the slide. Photographable. Then: "The links are on the next slide."

---

## S7.4 — Links (Alin)

Everything is open source. Here: the Cookieplone templates, the migration docs, the blog post as soon as it's live. Scan it — and come talk to us. Thank you.

**Notes:** Leave this slide up through Q&A.

---

## S7.5 — Thank you / Questions

We'll take questions. Implementation questions — Ionuț. Architecture and strategy — me.

**Notes:** Route Q&A. Backup slides B1–B5 live after this one.

---

## Backup slide answers (2-3 sentences each, either speaker)

**B1 — Why not Playwright?** Volto 19 still uses Cypress natively — templates, Docker images and core all expect it. Moving to Playwright is a separate, worthwhile project, but bundling it into this migration would have doubled the risk. One battle at a time.

**B2 — How much does Jest→Vitest hurt?** The API is compatible so most test files are untouched, but not zero-touch: `vi.mock` instead of `jest.mock`, snapshot format differences, jsdom setup per workspace. Concretely, the chatbot's 79 test files took care but not pain — the batch was automated, edge cases were human.

**B3 — How hard is backend 6.1→6.2?** Genuinely incremental: bump the base image and constraints, add `horse-with-no-namespace` preemptively. It's currently blocked only on our own eeacms/plone-backend:6.2.x image being published. Nothing structural.

**B4 — How long did it take?** [FILL WITH REAL NUMBERS before 12 Sept — weeks for phases 0-3, PR count across 64 repos.] The batch fixes were scripts and agents; the human time went to review, releases and the hard cases.

**B5 — Which addon fought back?** volto-eea-website-theme. The react-dnd to dnd-kit change wasn't cosmetic — it needed new dependencies and registered loadables to keep working on both versions. Every migration has one of these; that was ours.
