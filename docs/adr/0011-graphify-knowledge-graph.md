# ADR-0011: Graphify knowledge graph for agent navigation

| | |
|---|---|
| Status | accepted |
| Date | 2026-10-20 |
| Deciders | founder (request), architect agent |
| Blueprint | §26 (AI agents build HeyMey) |

## Context
Many agents work in one large monorepo (TypeScript, Dart, Prisma, YAML, docs). Agents that discover code by
repeated grep and whole-file reads waste context and miss cross-file relationships (module boundaries, contract →
controller → domain chains).

## Decision
Use **Graphify** (`pip install graphifyy`, https://github.com/Graphify-Labs/graphify) as the code knowledge graph:
- Project-scoped install: Claude Code skill `.claude/skills/graphify`, AGENTS.md-compatible skill `.agents/skills/graphify`,
  PreToolUse hooks in `.claude/settings.json` that steer search/read calls to `graphify query` when a graph exists.
- Graph lives in `graphify-out/` (`graph.json`, `GRAPH_REPORT.md`, `graph.html`); `graphify-out/cache/` is git-ignored.
  Scope is set by `.graphifyignore` (generated code, platform folders, lockfiles excluded).
- Git hooks (`graphify hook install`) rebuild the graph on commit/checkout/merge; agents run `graphify update .`
  after code changes (AST-only, no LLM cost). A merge driver union-merges `graph.json`.
- Every agent definition and lifecycle skill requires querying the graph before raw reads, and requires putting
  that rule into any subagent prompt.

## Consequences
Faster, cheaper orientation for agents; `graph.json` diffs in PRs are expected and not churn. Requires Python on
developer machines and CI (`pip install graphifyy`). Semantic extraction of docs (LLM pass) is optional and not used by default.
