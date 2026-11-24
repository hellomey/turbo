#!/usr/bin/env node
// Validates content/lessons/*.yaml and content/questions/*.yaml against the syllabus map.
//   pnpm content:validate        (exit code 1 on any problem)
// Checks: topic ids exist in content/syllabus/*.yaml, stable UUIDs, no duplicate ids, 4 distinct options,
// exactly one correct option that exists, non-empty explanation, a cited source, and the review_status label.
// Still to build (not checked here): Tamil script only in Tamil Language paper content.
import { readdirSync, readFileSync } from "node:fs";
import { parse } from "yaml";

const root = new URL("../", import.meta.url);
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/;
const errors = [];
const fail = (where, msg) => errors.push(`${where}: ${msg}`);
const load = (dir) =>
  readdirSync(new URL(`${dir}/`, root))
    .filter((f) => f.endsWith(".yaml"))
    .map((f) => ({ file: `${dir}/${f}`, doc: parse(readFileSync(new URL(`${dir}/${f}`, root), "utf8")) }));

// Topic ids from every syllabus file.
const topics = new Set();
for (const { file, doc } of load("syllabus")) {
  for (const s of doc.subjects ?? []) for (const t of s.topics ?? []) {
    if (!UUID.test(t.id)) fail(file, `topic ${t.code} has a non-UUID id`);
    topics.add(t.id);
  }
}

const REVIEW = new Set(["sample", "in_review", "verified"]);
const ids = new Set();
let lessons = 0;
let questions = 0;

for (const { file, doc } of load("lessons")) {
  if (!REVIEW.has(doc.review_status)) fail(file, `review_status must be one of ${[...REVIEW].join(", ")}`);
  if (!doc.source_citation) fail(file, "source_citation is required");
  for (const l of doc.lessons ?? []) {
    lessons++;
    const w = `${file} lesson "${l.title}"`;
    if (!topics.has(l.topic_id)) fail(w, "topic_id is not in the syllabus");
    if (ids.has(`lesson:${l.topic_id}`)) fail(w, "two lessons for one topic");
    ids.add(`lesson:${l.topic_id}`);
    if (!l.title || !l.body || String(l.body).length < 200) fail(w, "title and a body of at least 200 characters are required");
    if (!Number.isInteger(l.reading_minutes) || l.reading_minutes < 1) fail(w, "reading_minutes must be a positive integer");
  }
}

for (const { file, doc } of load("questions")) {
  if (!REVIEW.has(doc.review_status)) fail(file, `review_status must be one of ${[...REVIEW].join(", ")}`);
  if (!doc.source?.citation || !doc.source?.kind) fail(file, "source.kind and source.citation are required");
  for (const q of doc.questions ?? []) {
    questions++;
    const w = `${file} question ${q.id}`;
    if (!UUID.test(q.id)) fail(w, "id is not a UUID");
    if (ids.has(q.id)) fail(w, "duplicate id");
    ids.add(q.id);
    if (!topics.has(q.topic_id)) fail(w, "topic_id is not in the syllabus");
    if (!q.stem || String(q.stem).length < 10) fail(w, "stem too short");
    if (!Number.isInteger(q.difficulty) || q.difficulty < 1 || q.difficulty > 5) fail(w, "difficulty must be 1..5");
    const opts = q.options ?? [];
    if (opts.length !== 4) fail(w, "exactly 4 options are required");
    if (new Set(opts.map((o) => o.id)).size !== opts.length) fail(w, "duplicate option ids");
    if (new Set(opts.map((o) => String(o.text))).size !== opts.length) fail(w, "duplicate option text");
    if (opts.some((o) => !String(o.text).trim())) fail(w, "empty option text");
    if (!opts.some((o) => o.id === q.correct)) fail(w, "correct does not match an option id");
    if (!q.explanation || String(q.explanation).length < 15) fail(w, "an explanation is required");
  }
}

if (errors.length) {
  console.error(errors.map((e) => `  - ${e}`).join("\n"));
  console.error(`content: ${errors.length} problem(s)`);
  process.exit(1);
}
console.log(`content: ok (${topics.size} syllabus topics, ${lessons} lessons, ${questions} questions)`);
