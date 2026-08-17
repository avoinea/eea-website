# Plone Conf 2026 — Talk Submission

Submission URL: https://2026.ploneconf.org/call-for-proposals
Deadline: 16 August 2026 (Anywhere on Earth)

---

## Form Fields

**Your Email:** contact@avoinea.com

**Title:** From Volto 17 to 19: Upgrading 64 Addons at the European Environment Agency

**Speaker Name:** Alin Voinea

**Speaker Introduction:**

Alin Voinea has been building Plone solutions at Eau de Web in Romania since 2007, primarily for the European Environment Agency. A member of the Plone Volto Team, he maintains dozens of Volto add-ons used across the community — including EEA Faceted Navigation and the EEA Volto design system — and is currently leading the EEA's upgrade from Volto 17 to 19 across 64 addons. He is a returning Plone Conf speaker, having presented on Volto development, EEA's Plone deployment, and Plone infrastructure.

**Co Speaker Name:** Ionuț Dobricean

**Co Speaker Introduction:**

Ionuț Dobricean is a web developer at Eau de Web in Romania, where he builds Volto-based solutions for the European Environment Agency. A member of the Plone Volto Team and a regular contributor at Plone sprints — including the Bucharest Sprints hosted at Eau de Web — he has been actively working on Volto 19, including link widget improvements, test suite fixes, and addon compatibility work across the EEA's 64 addons.

**Type of proposal:** Talk

**Abstract:**

The European Environment Agency has run on Plone for 20 years — and on Volto since 2019. Today the EEA website (www.eea.europa.eu) depends on 64 Volto add-ons, 1,000 GitHub repositories, and a CI/CD pipeline spanning Jenkins, Docker Hub, and Rancher. Last year the site was still on Volto 17. Now we're targeting Volto 19.3.0 — and the jump is not small.

Volto 19 drops yarn entirely, forks razzle and babel into @plone-scoped packages, replaces Jest with Vitest, upgrades superagent from 3 to 10, swaps react-dnd for dnd-kit, removes language settings from config, and introduces pnpm 10 with workspace support. For a project with one addon, that's a weekend. For 64 addons that must work on both Volto 18 and 19 simultaneously during the transition, it's an engineering project.

This talk walks through the full migration: why we chose to regenerate the project from Cookieplone rather than incrementally patch it, how we approached dual-version compatibility so 64 addons run on both Volto 18 and 19 during the transition, and how we created reusable EEA Cookieplone templates so other projects can follow the same path. We cover the addon breaking changes and their fixes, the build and CI/CD pipeline migration, and the coordinated backend upgrade from Plone 6.1 to 6.2.

You'll leave with reusable patterns for dual-version addon compatibility, a Cookieplone template approach you can adapt for your own organization, and concrete lessons from upgrading one of the largest Plone deployments in Europe.

**Talk Length:** 45 minutes

**Target Level:** Advanced

**Target Audience:** Frontend, Integrator

**Language:** English