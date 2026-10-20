# ADR-0009: TypeScript 6.0 for type-checking, SWC for Nest builds

| | |
|---|---|
| Status | accepted |
| Date | 2026-10-20 |
| Deciders | founder, architect agent |
| Blueprint | §20.2 |

## Context
TypeScript 7 (native) is the current release, but NestJS dependency injection relies on legacy decorators and
`emitDecoratorMetadata`.

## Decision
Pin `typescript ~6.0` repo-wide for `tsc --noEmit` and library builds. Nest apps build with **SWC** (`nest build`,
`.swcrc` with decorator metadata); tests use `unplugin-swc`. Revisit when TS 7 + Nest decorator metadata are confirmed.

## Consequences
Two compilers in the toolchain; both are standard for Nest projects.
