#!/usr/bin/env node
// Scaffold a backend domain module with the standard layout and boundary metadata.
//
//   pnpm gen:module <name> --summary "..." [--owns "A,B"] [--does "x; y"] [--depends a,b]
//                          [--publishes "x.happened"] [--week N] [--coverage 90] [--critical]
//
// Writes packages/domain/src/modules/<name>/{module.json, MODULE.md, index.ts, domain/, application/, infrastructure/}
// and packages/db/prisma/schema/<name>.prisma. Never overwrites existing files.
// module.json "dependsOn" is read by .dependency-cruiser.cjs: importing any other module is a CI failure.
import { existsSync, mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { parseArgs } from "node:util";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const { values, positionals } = parseArgs({
  allowPositionals: true,
  options: {
    summary: { type: "string", default: "TODO: one-line purpose" },
    owns: { type: "string", default: "" },
    does: { type: "string", default: "" },
    depends: { type: "string", default: "" },
    publishes: { type: "string", default: "" },
    week: { type: "string", default: "" },
    coverage: { type: "string", default: "70" },
    critical: { type: "boolean", default: false },
  },
});

const name = positionals[0];
if (!name || !/^[a-z][a-z0-9-]*$/.test(name)) {
  console.error("usage: pnpm gen:module <kebab-name> --summary \"...\"");
  process.exit(1);
}

const list = (s, sep = ",") => s.split(sep).map((x) => x.trim()).filter(Boolean);
const meta = {
  name,
  summary: values.summary,
  owns: list(values.owns),
  responsibilities: list(values.does, ";"),
  dependsOn: list(values.depends),
  publishes: list(values.publishes),
  buildWeek: values.week ? Number(values.week) : null,
  coverageTarget: Number(values.coverage),
  founderApprovalRequired: values.critical,
};

const dir = join(root, "packages/domain/src/modules", name);
const write = (rel, content) => {
  const file = join(dir, rel);
  if (existsSync(file)) return;
  mkdirSync(dirname(file), { recursive: true });
  writeFileSync(file, content);
};

const pascal = name.replace(/(^|-)([a-z])/g, (_, __, c) => c.toUpperCase());
const bullet = (xs, empty = "—") => (xs.length ? xs.map((x) => `- ${x}`).join("\n") : empty);

write("module.json", JSON.stringify(meta, null, 2) + "\n");
write(
  "MODULE.md",
  `# Module: \`${name}\`

${meta.summary}

| | |
|---|---|
| Build week (blueprint §43) | ${meta.buildWeek ?? "post-launch"} |
| Coverage target (§44) | ${meta.coverageTarget}% |
| Founder approval on every change | ${meta.founderApprovalRequired ? "**Yes** (money / personal data / game fairness)" : "No (normal review)"} |

## Owns (tables, in \`packages/db/prisma/schema/${name}.prisma\`)
${bullet(meta.owns)}

## Responsibilities
${bullet(meta.responsibilities)}

## May depend on (public \`index.ts\` only)
${bullet(meta.dependsOn.map((d) => `\`${d}\``), "Nothing. This module is a leaf.")}

## Publishes domain events
${bullet(meta.publishes.map((e) => `\`${e}\``), "None yet.")}

## Layout
\`\`\`
${name}/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
\`\`\`

## AIDLC
Unit of work: see \`aidlc/inception/units.md\`. Design artefacts for this module live in
\`aidlc/construction/units/${name}/\` (domain-model.md, logical-design.md) once its first bolt starts.
`,
);
write(
  "index.ts",
  `/**
 * Public API of the \`${name}\` module. ${meta.summary}
 * Export use cases and types only. Never export repositories or Prisma models.
 */
export const ${pascal}Module = { name: "${name}" } as const;
`,
);
for (const layer of ["domain", "application", "infrastructure"]) write(`${layer}/.gitkeep`, "");

const prismaFile = join(root, "packages/db/prisma/schema", `${name}.prisma`);
if (!existsSync(prismaFile)) {
  writeFileSync(
    prismaFile,
    `// Tables owned by the \`${name}\` module. No other module may query these (blueprint §34.8).\n` +
      (meta.owns.length ? `// To model: ${meta.owns.join(", ")}\n` : ""),
  );
}
console.log(`module ${name}: ok`);
