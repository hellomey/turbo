import { describe, expect, it } from "vitest";
import {
  buildStudyMap,
  createSyllabusModule,
  glossaryQuery,
  type GlossaryQuerySpec,
  type StudyMapPorts,
  type SyllabusRepository,
  type TopicRow,
} from "../../src/modules/syllabus/index.js";

const polity = { code: "polity", name: "Indian Polity", order: 1 };
const aptitude = { code: "aptitude", name: "Aptitude", order: 6 };

const T = (n: number) => `0199f5a0-0000-7000-8000-0000000000${String(n).padStart(2, "0")}`;
const topics: TopicRow[] = [
  { id: T(3), code: "aptitude.percentage", name: "Percentage", order: 1, subject: aptitude, examCodes: ["tnpsc-group-4", "ssc-mts", "tnpsc-group-2"] },
  { id: T(2), code: "polity.rights", name: "Fundamental Rights", order: 2, subject: polity, examCodes: ["tnpsc-group-4", "tnpsc-group-2"] },
  { id: T(1), code: "polity.preamble", name: "Preamble", order: 1, subject: polity, examCodes: ["tnpsc-group-4", "draft-exam"] },
  { id: T(4), code: "polity.only-g2", name: "Only Group 2", order: 3, subject: polity, examCodes: ["tnpsc-group-2"] },
];
const published = new Set(["tnpsc-group-4", "tnpsc-group-2", "ssc-mts"]);

describe("buildStudyMap", () => {
  const map = buildStudyMap("tnpsc-group-4", topics, published, new Set([T(1)]));

  it("groups by subject in order, topics in order, only this exam's topics", () => {
    expect(map.examCode).toBe("tnpsc-group-4");
    expect(map.subjects.map((s) => s.code)).toEqual(["polity", "aptitude"]);
    expect(map.subjects[0]?.topics.map((t) => t.code)).toEqual(["polity.preamble", "polity.rights"]);
    expect(map.totalTopics).toBe(3);
  });

  it("shared lamps list every PUBLISHED exam tagged on the topic, sorted", () => {
    const pct = map.subjects[1]?.topics[0];
    expect(pct?.examCodes).toEqual(["ssc-mts", "tnpsc-group-2", "tnpsc-group-4"]);
    expect(map.subjects[0]?.topics[0]?.examCodes).toEqual(["tnpsc-group-4"]); // draft-exam hidden
  });

  it("hasLesson from the content answer; every ring unlit in Phase 1", () => {
    const [preamble, rights] = map.subjects[0]?.topics ?? [];
    expect(preamble?.hasLesson).toBe(true);
    expect(rights?.hasLesson).toBe(false);
    for (const s of map.subjects) for (const t of s.topics) expect(t.ring).toEqual({ lit: false, steadyLevel: 0, gold: false, dim: "bright" });
  });

  it("empty map for an exam with no topics", () => {
    expect(buildStudyMap("ssc-chsl", topics, published, new Set())).toEqual({ examCode: "ssc-chsl", subjects: [], totalTopics: 0 });
  });
});

describe("study map use case (with fakes)", () => {
  const repo: SyllabusRepository = {
    topicsForExam: async (code) => topics.filter((t) => t.examCodes.includes(code)),
    searchGlossary: async () => [],
    textbookRefs: async () => [],
    topicById: async (id) => topics.find((t) => t.id === id) ?? null,
  };
  const lessonCalls: string[][] = [];
  const ports: StudyMapPorts = {
    publishedExamCodes: async () => published,
    topicsWithLesson: async (ids) => {
      lessonCalls.push(ids);
      return new Set([T(2)]);
    },
  };

  it("serves the map for a published exam, asking content once for lesson flags", async () => {
    const map = await createSyllabusModule({ repository: repo }).studyMap("tnpsc-group-2", ports);
    expect(map.totalTopics).toBe(3);
    expect(map.subjects[0]?.topics.find((t) => t.id === T(2))?.hasLesson).toBe(true);
    expect(lessonCalls).toHaveLength(1);
  });

  it("unpublished or unknown exam -> EXAM_NOT_FOUND", async () => {
    const api = createSyllabusModule({ repository: repo });
    await expect(api.studyMap("draft-exam", ports)).rejects.toMatchObject({ code: "EXAM_NOT_FOUND" });
    await expect(api.studyMap("nope", ports)).rejects.toMatchObject({ code: "EXAM_NOT_FOUND" });
  });
});

describe("glossary query building", () => {
  it("search: trimmed text, max 20", () => {
    expect(glossaryQuery("  omr ")).toEqual({ contains: "omr", take: 20 });
  });
  it("no query or blank: browse first 50", () => {
    expect(glossaryQuery()).toEqual({ contains: null, take: 50 });
    expect(glossaryQuery("   ")).toEqual({ contains: null, take: 50 });
    expect(glossaryQuery(null)).toEqual({ contains: null, take: 50 });
  });
  it("use case passes the spec to the repository", async () => {
    const seen: GlossaryQuerySpec[] = [];
    const api = createSyllabusModule({
      repository: {
        topicsForExam: async () => [],
        textbookRefs: async () => [],
        topicById: async () => null,
        searchGlossary: async (spec) => {
          seen.push(spec);
          return [{ term: "OMR", meaning: "m" }];
        },
      },
    });
    expect(await api.glossary("om")).toEqual({ items: [{ term: "OMR", meaning: "m" }] });
    expect(seen).toEqual([{ contains: "om", take: 20 }]);
  });
});
