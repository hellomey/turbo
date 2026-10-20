# ADR-0001: One monorepo: Turborepo + pnpm, plus a Dart pub workspace

| | |
|---|---|
| Status | accepted |
| Date | 2026-10-20 |
| Deciders | founder, architect agent |
| Blueprint | §35 |

## Context
The blueprint asks for one Git repository (§35) containing a Flutter app + Desk, a TypeScript backend, infra and content.
The founder also has a Next.js marketing site and asked for "all in one repository" with Turborepo.

## Decision
- One repo. **pnpm workspaces** for every Node package (`apps/*`, `packages/*`, `content`, `dart` wrapper).
- **Turborepo** orchestrates `codegen → build → lint/typecheck/test` with caching across TS **and** Flutter
  (Flutter is driven through thin `package.json` wrappers: `dart/`, `apps/mobile`, `apps/desk`).
- Layout adapts §35 to Turborepo conventions: `server/apps/*` → `apps/{api,realtime,worker}`; `server/libs/*` → `packages/*`;
  Flutter packages in `dart/`; `apps/mobile_app` → `apps/mobile`, `apps/desk_web` → `apps/desk`.
- Node 24 LTS, pnpm 12 via corepack; ESM everywhere.

## Consequences
One `pnpm verify` checks everything. pnpm's release-age guard is on: very new versions need an explicit
`minimumReleaseAgeExclude` entry (reviewed by `security`).

## Alternatives
Nx (heavier, less needed); separate repos (breaks "one contract" and atomic changes); Melos for Dart (pub workspaces now cover it).
