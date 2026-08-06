# EEA Website Volto 19 Upgrade — Documentation

This directory documents the complete plan, decisions, and execution steps for upgrading the EEA Main Website from Volto 18 / Plone 6.1 to Volto 19.3.0 / Plone 6.2.1.

## Scope

- **Frontend**: `./frontend/` — Volto 18.35.1 → 19.3.0, yarn → pnpm
- **Backend**: `./backend/` — Plone 6.1.x → 6.2.x
- **Add-ons**: 64 EEA Volto add-ons — dual-compatible with Volto 18 + 19
- **CI/CD**: Jenkins pipelines, `eeacms/gitflow` automation, Helm charts
- **Templates**: EEA Cookieplone templates for reuse across all EEA projects

## Execution Tracking

| File | Description |
|---|---|
| [TODO.md](TODO.md) | Progress tracker with checkboxes for all 7 phases |
| [HANDOFF.md](HANDOFF.md) | Conversation summary for a fresh agent to pick up |
| [continue.md](continue.md) | Next steps guide for agents picking up the work |

## Documentation Index

| File | Description |
|---|---|
| [01-overview.md](01-overview.md) | Why we're upgrading, scope, constraints |
| [02-strategy.md](02-strategy.md) | Regenerate-and-migrate approach with Cookieplone |
| [03-frontend-project-structure.md](03-frontend-project-structure.md) | pnpm workspace, `packages/website/`, `packages/` layout |
| [04-cookieplone-templates.md](04-cookieplone-templates.md) | EEA `frontend_project` and `frontend_addon` templates |
| [05-addon-migration.md](05-addon-migration.md) | Phased addon migration, dual Volto 18/19 compatibility |
| [06-testing-strategy.md](06-testing-strategy.md) | Cypress for both versions, Vitest for Volto 19 |
| [07-build-and-deployment.md](07-build-and-deployment.md) | Dockerfile, Jenkinsfile, gitflow, Helm charts |
| [08-package-manager-migration.md](08-package-manager-migration.md) | yarn → pnpm, pnpm.overrides, mrs.developer.json |
| [09-volto19-breaking-changes.md](09-volto19-breaking-changes.md) | All Volto 19 breaking changes and how we handle each |
| [10-backend-upgrade.md](10-backend-upgrade.md) | Plone 6.1 → 6.2 incremental upgrade |
| [11-execution-plan.md](11-execution-plan.md) | Step-by-step migration order with dependencies |
| [12-decision-log.md](12-decision-log.md) | All decisions made with rationale |
| [13-redmine-ticket-summary.textile](13-redmine-ticket-summary.textile) | Redmine-compatible summary for the upgrade ticket |

## Target Versions

| Component | Current | Target |
|---|---|---|
| Volto | 18.35.1 | 19.3.0 |
| Plone | 6.1.3/6.1.4 | 6.2.1 |
| Package manager | yarn 3.2.3 | pnpm 10.x |
| Node.js | 22 | 22 (no change) |
| Docker base image | node:22-slim | plone/frontend-builder:19.3.0 |