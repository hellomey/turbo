// Module manifests (module.json) are boundary metadata read by dependency-cruiser and the module docs generator
// (blueprint §34.8 module ownership, §36 module list, §44 coverage targets). These tests load every manifest and
// check the invariants CI relies on, so a malformed or contradictory manifest fails fast here.
import { readdirSync, existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { describe, expect, it } from "vitest";

interface Manifest {
  name: string;
  summary: string;
  owns: string[];
  responsibilities: string[];
  dependsOn: string[];
  publishes: string[];
  buildWeek: number;
  coverageTarget: number;
  founderApprovalRequired: boolean;
}

const here = dirname(fileURLToPath(import.meta.url));
const MODULES_DIR = join(here, "../../src/modules");
const SCHEMA_DIR = join(here, "../../../db/prisma/schema");
const folders = readdirSync(MODULES_DIR, { withFileTypes: true })
  .filter((d) => d.isDirectory() && existsSync(join(MODULES_DIR, d.name, "module.json")))
  .map((d) => d.name)
  .sort();

async function load(folder: string): Promise<Manifest> {
  const mod = (await import(`../../src/modules/${folder}/module.json`, { with: { type: "json" } })) as { default: Manifest };
  return mod.default;
}

/** §44: "90% or more on economy, billing, mastery, exam-hall, games, and auth. 70% or more elsewhere." */
const NINETY = ["economy", "billing", "mastery", "exam-hall", "games", "auth"];

describe("module manifests (§34.8, §36, §44)", () => {
  it("there are 24 business modules, each with a module.json", () => {
    expect(folders).toHaveLength(24);
  });

  it("each manifest's name matches its folder and has the required fields", async () => {
    for (const f of folders) {
      const m = await load(f);
      expect(m.name, f).toBe(f);
      expect(m.summary.length, f).toBeGreaterThan(0);
      expect(Array.isArray(m.owns) && Array.isArray(m.dependsOn) && Array.isArray(m.publishes), f).toBe(true);
      expect(Number.isInteger(m.buildWeek) && m.buildWeek >= 1 && m.buildWeek <= 4, f).toBe(true);
      expect(typeof m.founderApprovalRequired, f).toBe("boolean");
    }
  });

  it("coverage targets are at least the §44 floor (90 for the six critical modules, 70 elsewhere)", async () => {
    for (const f of folders) {
      const m = await load(f);
      expect(m.coverageTarget, f).toBeGreaterThanOrEqual(NINETY.includes(f) ? 90 : 70);
    }
  });

  it("audit is founder-critical and held to 90% (task BOLT-0006, MODULE.md)", async () => {
    const audit = await load("audit");
    expect(audit).toMatchObject({ coverageTarget: 90, founderApprovalRequired: true, dependsOn: [], owns: ["AuditLog"] });
  });

  it("content depends only on syllabus and ai and targets at least 70%", async () => {
    const content = await load("content");
    expect([...content.dependsOn].sort()).toEqual(["ai", "syllabus"]);
    expect(content.coverageTarget).toBeGreaterThanOrEqual(70);
    expect(content.owns).toContain("Lesson");
  });

  it("dependsOn names existing modules, never itself, and the dependency graph has no cycles", async () => {
    const graph = new Map<string, string[]>();
    for (const f of folders) graph.set(f, (await load(f)).dependsOn);
    for (const [name, deps] of graph) {
      for (const d of deps) {
        expect(folders, `${name} -> ${d}`).toContain(d);
        expect(d, name).not.toBe(name);
      }
    }
    const state = new Map<string, "visiting" | "done">();
    const visit = (n: string, path: string[]): void => {
      if (state.get(n) === "done") return;
      if (state.get(n) === "visiting") throw new Error(`cycle: ${[...path, n].join(" -> ")}`);
      state.set(n, "visiting");
      for (const d of graph.get(n) ?? []) visit(d, [...path, n]);
      state.set(n, "done");
    };
    for (const n of folders) expect(() => visit(n, [])).not.toThrow();
  });

  it("no table is owned by two modules (a module owns its tables, §34.8)", async () => {
    const owner = new Map<string, string>();
    for (const f of folders) {
      for (const t of (await load(f)).owns) {
        const table = t.replace(/\s*\(.*\)$/, ""); // "RefreshToken (family)" -> "RefreshToken"
        expect(owner.get(table), `${table} owned by ${owner.get(table)} and ${f}`).toBeUndefined();
        owner.set(table, f);
      }
    }
  });

  it("every per-module Prisma schema file belongs to an existing module", () => {
    const files = readdirSync(SCHEMA_DIR).filter((f) => f.endsWith(".prisma") && !f.startsWith("_"));
    for (const file of files) expect(folders, file).toContain(file.replace(/\.prisma$/, ""));
  });
});
