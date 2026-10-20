# ADR-0003: The Next.js marketing site replaces the planned static apps/site

| | |
|---|---|
| Status | accepted |
| Date | 2026-10-20 |
| Deciders | founder, architect agent |
| Blueprint | §35, §46 |

## Context
§35 planned `apps/site` as static HTML legal pages + store links. A finished Next.js marketing site (with legal pages,
e2e tests and a frozen, pixel-tested hero) already exists.

## Decision
Keep it as `apps/marketing` (`@heymey/marketing`, port 4570, `heymey.app`), built as a Next.js **standalone** server image.
It talks to the backend only over HTTP (enforced by dependency-cruiser). Aligning its CTAs and lead form with the
app-only product is INT-005.

## Consequences
One more Node service on the VPS (~512 MB limit). Policy URLs required by the stores stay stable here.
