// Integration: catalog seeder + syllabus/content repositories against REAL PostgreSQL (Testcontainers, blueprint §44).
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { startPostgres, type StartedDb } from "@heymey/testing";
import { createContentModule } from "../../src/modules/content/index.js";
import { createExamsModule } from "../../src/modules/exams/index.js";
import { createSyllabusModule } from "../../src/modules/syllabus/index.js";
import { systemClock } from "../../src/shared/index.js";
import { seeder } from "../../../db/prisma/seed/catalog.js";

let db: StartedDb;
let prisma: PrismaClient;

const PREAMBLE = "0199f5a0-0101-7000-8000-000000000101";
const PERCENTAGE = "0199f5a0-0601-7000-8000-000000000601";
const RIVERS = "0199f5a0-0302-7000-8000-000000000302";

const counts = async () => ({
  exams: await prisma.exam.count(),
  rules: await prisma.eligibilityRule.count(),
  subjects: await prisma.subject.count(),
  topics: await prisma.topic.count(),
  tags: await prisma.topicExamTag.count(),
  refs: await prisma.textbookRef.count(),
  lessons: await prisma.lesson.count(),
  glossary: await prisma.glossaryTerm.count(),
});

beforeAll(async () => {
  db = await startPostgres();
  prisma = createPrismaClient(db.url);
});

afterAll(async () => {
  await prisma?.$disconnect();
  await db?.stop();
});

describe("catalog seeder (integration)", () => {
  it("runs twice idempotently", async () => {
    await seeder.run(prisma);
    const first = await counts();
    const topicIds = (await prisma.topic.findMany({ select: { id: true }, orderBy: { id: "asc" } })).map((t) => t.id);
    await seeder.run(prisma);
    expect(await counts()).toEqual(first);
    expect((await prisma.topic.findMany({ select: { id: true }, orderBy: { id: "asc" } })).map((t) => t.id)).toEqual(topicIds);
    expect(first).toMatchObject({ exams: 5, rules: 5, subjects: 6, lessons: 4 });
    expect(first.topics).toBeGreaterThanOrEqual(18);
  });

  it("marks every exam as seed data and never as human-verified", async () => {
    for (const e of await prisma.exam.findMany()) {
      expect(e.description.startsWith("SEED DATA - verify against the official notification.")).toBe(true);
      expect(["https://www.tnpsc.gov.in/", "https://ssc.gov.in/"]).toContain(e.officialUrl);
      expect(e.verifiedBy).toBeNull();
    }
    for (const r of await prisma.eligibilityRule.findMany()) expect(r.verifiedAt).toBeNull();
  });

  it("refuses to run in production", async () => {
    const prev = process.env.HEYMEY_ENV;
    process.env.HEYMEY_ENV = "production";
    try {
      await expect(seeder.run(prisma)).rejects.toThrow(/production/);
    } finally {
      process.env.HEYMEY_ENV = prev;
    }
  });
});

describe("syllabus + content repositories (integration)", () => {
  const syllabus = () => createSyllabusModule({ prisma });
  const content = () => createContentModule({ prisma, syllabus: syllabus() });
  const exams = () => createExamsModule({ prisma, clock: systemClock });
  const ports = () => ({
    publishedExamCodes: () => exams().publishedCodes(),
    topicsWithLesson: (ids: string[]) => content().topicsWithPublishedLesson(ids),
  });

  it("study map: ordered subjects, shared lamps, lesson flags", async () => {
    const map = await syllabus().studyMap("tnpsc-group-4", ports());
    expect(map.subjects.map((s) => s.code)).toEqual(["polity", "history", "geography", "economy", "science", "aptitude"]);
    expect(map.totalTopics).toBe(map.subjects.reduce((n, s) => n + s.topics.length, 0));
    const preamble = map.subjects[0]?.topics[0];
    expect(preamble).toMatchObject({ id: PREAMBLE, hasLesson: true, examCodes: ["ssc-chsl", "tnpsc-group-2", "tnpsc-group-2a", "tnpsc-group-4"] });
    const rivers = map.subjects[2]?.topics.find((t) => t.id === RIVERS);
    expect(rivers?.hasLesson).toBe(false);
  });

  it("study map for a central exam only has its shared topics", async () => {
    const map = await syllabus().studyMap("ssc-mts", ports());
    const ids = map.subjects.flatMap((s) => s.topics.map((t) => t.id));
    expect(ids).toContain(PERCENTAGE);
    expect(ids).not.toContain(PREAMBLE);
  });

  it("glossary: case-insensitive contains, ordered by term; browse without q", async () => {
    expect((await syllabus().glossary("omr")).items.map((i) => i.term)).toEqual(["OMR"]);
    expect((await syllabus().glossary("MARK")).items.map((i) => i.term)).toEqual(["Negative marking"]);
    const all = (await syllabus().glossary()).items.map((i) => i.term);
    expect(all).toEqual([...all].sort((a, b) => a.localeCompare(b))); // Postgres collation: case-insensitive A-Z
    expect(all.length).toBe(16);
  });

  it("lesson: latest published version with textbook refs; drafts ignored; missing -> LESSON_NOT_FOUND", async () => {
    await prisma.lesson.create({
      data: { topicId: PREAMBLE, version: 2, title: "Draft v2", bodyMarkdown: "x", readingMinutes: 1, sourceCitation: "x", status: "draft" },
    });
    const lesson = await content().lesson(PREAMBLE);
    expect(lesson).toMatchObject({ title: "The Preamble", version: 1 });
    expect(lesson.textbookRefs[0]).toMatchObject({ classLevel: 11, chapter: "1", url: "https://textbooksonline.tn.nic.in/" });
    expect(lesson.source.citation).toMatch(/Constitution of India/);
    await expect(content().lesson(RIVERS)).rejects.toMatchObject({ code: "LESSON_NOT_FOUND" });
    await prisma.lesson.deleteMany({ where: { topicId: PREAMBLE, version: 2 } });
  });

  // BOLT-0006 QA additions (§10.6 lessons, §26.2 rule 5: only published content is served).
  it("lesson flags: an empty id list returns an empty set without a query; unknown ids are ignored", async () => {
    expect([...(await content().topicsWithPublishedLesson([]))]).toEqual([]);
    expect([...(await content().topicsWithPublishedLesson([PREAMBLE, RIVERS, "0199f5a0-ffff-7000-8000-00000000ffff"]))]).toEqual([PREAMBLE]);
  });

  it("lesson: a newer published version supersedes; a topic with only a draft has no lesson flag", async () => {
    await prisma.lesson.create({
      data: { topicId: PREAMBLE, version: 3, title: "The Preamble (revised)", bodyMarkdown: "y", readingMinutes: 3, sourceCitation: "Constitution of India, Preamble", sourceUrl: "https://legislative.gov.in/", status: "published" },
    });
    await prisma.lesson.create({
      data: { topicId: RIVERS, version: 1, title: "Rivers draft", bodyMarkdown: "x", readingMinutes: 1, sourceCitation: "x", status: "draft" },
    });
    try {
      expect(await content().lesson(PREAMBLE)).toMatchObject({ version: 3, title: "The Preamble (revised)", readingMinutes: 3, source: { url: "https://legislative.gov.in/" } });
      expect([...(await content().topicsWithPublishedLesson([PREAMBLE, RIVERS]))]).toEqual([PREAMBLE]);
      await expect(content().lesson(RIVERS)).rejects.toMatchObject({ code: "LESSON_NOT_FOUND" });
    } finally {
      await prisma.lesson.deleteMany({ where: { OR: [{ topicId: PREAMBLE, version: 3 }, { topicId: RIVERS, version: 1 }] } });
    }
  });
});
