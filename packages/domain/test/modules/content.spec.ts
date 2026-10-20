import { describe, expect, it } from "vitest";
import { createContentModule, latestPublished, type LessonRecord, type LessonRepository } from "../../src/modules/content/index.js";

const TOPIC = "0199f5a0-0000-7000-8000-000000000001";

function lesson(version: number, status = "published"): LessonRecord {
  return {
    id: `0199f5a0-0000-7000-8000-00000000010${version}`,
    topicId: TOPIC,
    version,
    title: `Preamble v${version}`,
    bodyMarkdown: "text",
    readingMinutes: 2,
    sourceCitation: "Constitution of India, Preamble",
    sourceUrl: null,
    status,
    updatedAt: new Date("2026-10-20T00:00:00.000Z"),
  };
}

const ref = { book: "TN State Board Class 11 Political Science", classLevel: 11, chapter: "1", pages: null, url: null };

describe("latestPublished", () => {
  it("highest published version wins; drafts and superseded are ignored", () => {
    expect(latestPublished([lesson(1), lesson(3, "draft"), lesson(2)])?.version).toBe(2);
    expect(latestPublished([lesson(1, "superseded"), lesson(2, "in_review")])).toBeNull();
    expect(latestPublished([])).toBeNull();
  });
});

// BOLT-0006 QA additions (§10.6 lessons, §26.2 rule 5).
describe("latestPublished (edge cases)", () => {
  it("is order-independent and a single published version is returned as-is", () => {
    expect(latestPublished([lesson(2), lesson(5), lesson(1)])?.version).toBe(5);
    expect(latestPublished([lesson(5), lesson(1), lesson(2)])?.version).toBe(5);
    expect(latestPublished([lesson(4)])).toEqual(lesson(4));
  });

  it("status matching is exact: only 'published' counts", () => {
    expect(latestPublished([lesson(1, "Published"), lesson(2, "archived"), lesson(3, "published ")])).toBeNull();
  });
});

describe("getLesson", () => {
  const repo = (versions: LessonRecord[]): LessonRepository => ({
    publishedVersions: async () => versions,
    topicsWithPublished: async (ids) => new Set(ids.filter((id) => id === TOPIC)),
  });
  const syllabus = { textbookRefs: async () => [ref] };

  it("serves the latest published version with textbook refs and source", async () => {
    const api = createContentModule({ repository: repo([lesson(1), lesson(2)]), syllabus });
    expect(await api.lesson(TOPIC)).toEqual({
      id: lesson(2).id,
      topicId: TOPIC,
      title: "Preamble v2",
      bodyMarkdown: "text",
      readingMinutes: 2,
      textbookRefs: [ref],
      source: { citation: "Constitution of India, Preamble", url: null },
      version: 2,
      updatedAt: "2026-10-20T00:00:00.000Z",
    });
  });

  it("no published lesson -> LESSON_NOT_FOUND", async () => {
    const api = createContentModule({ repository: repo([lesson(1, "draft")]), syllabus });
    await expect(api.lesson(TOPIC)).rejects.toMatchObject({ code: "LESSON_NOT_FOUND" });
  });

  it("lesson flags for the Study Map", async () => {
    const api = createContentModule({ repository: repo([]), syllabus });
    expect([...(await api.topicsWithPublishedLesson([TOPIC, "other"]))]).toEqual([TOPIC]);
  });

  it("asks the syllabus for textbook refs of the requested topic only, and not at all when there is no lesson", async () => {
    const asked: string[] = [];
    const spy = { textbookRefs: async (id: string) => (asked.push(id), []) };
    const ok = createContentModule({ repository: repo([lesson(1)]), syllabus: spy });
    expect((await ok.lesson(TOPIC)).textbookRefs).toEqual([]);
    const missing = createContentModule({ repository: repo([]), syllabus: spy });
    await expect(missing.lesson("0199f5a0-0000-7000-8000-0000000000ff")).rejects.toMatchObject({
      code: "LESSON_NOT_FOUND",
      details: { topicId: "0199f5a0-0000-7000-8000-0000000000ff" },
    });
    expect(asked).toEqual([TOPIC]);
  });

  it("a lesson with a source URL keeps it; updatedAt is ISO-8601 UTC", async () => {
    const withUrl = { ...lesson(1), sourceUrl: "https://textbooksonline.tn.nic.in/", updatedAt: new Date("2026-10-20T18:45:00+05:30") };
    const api = createContentModule({ repository: repo([withUrl]), syllabus });
    expect(await api.lesson(TOPIC)).toMatchObject({
      source: { citation: "Constitution of India, Preamble", url: "https://textbooksonline.tn.nic.in/" },
      updatedAt: "2026-10-20T13:15:00.000Z",
    });
  });
});
