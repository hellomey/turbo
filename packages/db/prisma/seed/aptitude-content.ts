// Loads content/lessons/*.yaml and content/questions/*.yaml (sample content, under review) into the database.
// Idempotent: every row has a stable id or a unique key and is upserted. LOCAL / STAGING ONLY.
// Run `pnpm content:validate` first. Items are published so the app can serve them; review_status in the YAML
// ("sample") is carried into the source citation, which the app shows, so users see they are under review.
import { readdir, readFile } from "node:fs/promises";
import { createHash } from "node:crypto";
import { parse } from "yaml";
import type { PrismaClient } from "@heymey/db";

const CONTENT = new URL("../../../../content/", import.meta.url);
const PUBLISHED_AT = new Date("2026-11-24T00:00:00.000Z");

const sourceId = (set: string) => {
  const h = createHash("sha1").update(`heymey-source:${set}`).digest("hex");
  return `${h.slice(0, 8)}-${h.slice(8, 12)}-5${h.slice(13, 16)}-8${h.slice(17, 20)}-${h.slice(20, 32)}`;
};

async function yamlFiles(dir: string): Promise<Record<string, any>[]> {
  const names = (await readdir(new URL(`${dir}/`, CONTENT))).filter((f) => f.endsWith(".yaml")).sort();
  return Promise.all(names.map(async (n) => parse(await readFile(new URL(`${dir}/${n}`, CONTENT), "utf8")) as Record<string, any>));
}

export const seeder = {
  name: "aptitude-content",
  async run(prisma: PrismaClient): Promise<string> {
    let lessons = 0;
    let questions = 0;

    for (const doc of await yamlFiles("lessons")) {
      for (const l of doc.lessons as any[]) {
        const data = {
          title: l.title as string,
          bodyMarkdown: String(l.body).trim(),
          readingMinutes: l.reading_minutes as number,
          sourceCitation: doc.source_citation as string,
          sourceUrl: null,
          status: "published",
          publishedAt: PUBLISHED_AT,
        };
        await prisma.lesson.upsert({
          where: { topicId_version: { topicId: l.topic_id, version: 1 } },
          create: { topicId: l.topic_id, version: 1, ...data },
          update: data,
        });
        lessons++;
      }
    }

    for (const doc of await yamlFiles("questions")) {
      const sid = sourceId(doc.set as string);
      const src = {
        citation: doc.source.citation as string,
        url: (doc.source.url as string | null) ?? null,
        kind: doc.source.kind as string,
        setName: doc.set as string, // stable lookup for a set, e.g. the expo challenge (BOLT-0112)
      };
      await prisma.source.upsert({ where: { id: sid }, create: { id: sid, ...src }, update: src });

      for (const q of doc.questions as any[]) {
        await prisma.question.upsert({
          where: { id: q.id },
          create: { id: q.id, topicId: q.topic_id, kind: "single_choice", difficulty: q.difficulty, language: "en", status: "published" },
          update: { topicId: q.topic_id, difficulty: q.difficulty, status: "published" },
        });
        const version = {
          stem: q.stem as string,
          options: q.options as { id: string; text: string }[],
          correctOptionIds: [q.correct as string],
          explanationMarkdown: q.explanation as string,
          sourceId: sid,
          status: "published",
          publishedAt: PUBLISHED_AT,
        };
        await prisma.questionVersion.upsert({
          where: { questionId_version: { questionId: q.id, version: 1 } },
          create: { questionId: q.id, version: 1, ...version },
          update: version,
        });
        questions++;
      }
    }
    return `${lessons} lessons, ${questions} questions (sample content, under review)`;
  },
};
