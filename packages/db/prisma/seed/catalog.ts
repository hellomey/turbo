// Catalog seed (BOLT-0003): exams + eligibility rules, syllabus (from content/syllabus/*.yaml), lessons, glossary.
// LOCAL / STAGING ONLY. Every exam and rule here is SEED DATA: plausible, NOT verified facts. Production eligibility
// data is entered by Ops and human-checked before `status = published` (blueprint §26.2 rule 5, D-2026-10-20-12).
// Idempotent: every write is an upsert (or a delete+create of a topic's own child rows), so running twice changes nothing.
import { readdir, readFile } from "node:fs/promises";
import { parse } from "yaml";
import type { PrismaClient } from "@heymey/db";

const SEED_MARK = "SEED DATA - verify against the official notification.";
const TNPSC_URL = "https://www.tnpsc.gov.in/";
const SSC_URL = "https://ssc.gov.in/";
const SYLLABUS_DIR = new URL("../../../../content/syllabus/", import.meta.url);
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/;

type Community = "OC" | "BC" | "BCM" | "MBC_DNC" | "SC" | "SCA" | "ST";

interface SeedExam {
  code: string;
  name: string;
  conductingBody: string;
  level: "state" | "central";
  minQualification: string;
  fullPrep: boolean;
  description: string;
  stages: string[];
  patternMode: "omr" | "cbt";
  patternQuestions: number | null;
  patternMinutes: number | null;
  negativeMarking: boolean;
  officialUrl: string;
  rule: {
    ageAsOf: string;
    minAge: number;
    maxAgeByCommunity: Record<Community, number | null>;
    relaxationYears: Partial<Record<"PWD" | "EX_SERVICEMAN" | "DESTITUTE_WIDOW", number>>;
    qualifications: string[];
    degreeSubjects: string[];
    pstmNote: string | null;
  };
}

const TN_PSTM_NOTE =
  "Seed data. In TNPSC exams, some posts are set aside for people who studied in Tamil medium (PSTM). Check the official notification.";
const tnReserved = (oc: number, others: number | null): Record<Community, number | null> => ({
  OC: oc, BC: others, BCM: others, MBC_DNC: others, SC: others, SCA: others, ST: others,
});
// Central exams: TN communities mapped to central categories (BC/BCM/MBC_DNC -> OBC, SC/SCA -> SC). Open question Q-E1.
const central = (general: number): Record<Community, number | null> => ({
  OC: general, BC: general + 3, BCM: general + 3, MBC_DNC: general + 3, SC: general + 5, SCA: general + 5, ST: general + 5,
});

export const SEED_EXAMS: SeedExam[] = [
  {
    code: "tnpsc-group-4",
    name: "TNPSC Group 4 (including VAO)",
    conductingBody: "TNPSC",
    level: "state",
    minQualification: "sslc",
    fullPrep: true,
    description: `${SEED_MARK} Combined Civil Services Examination - IV: one written exam for posts such as Village Administrative Officer, Junior Assistant and Typist.`,
    stages: ["Written exam (OMR)", "Certificate verification", "Counselling"],
    patternMode: "omr",
    patternQuestions: 200,
    patternMinutes: 180,
    negativeMarking: false,
    officialUrl: TNPSC_URL,
    rule: {
      ageAsOf: "2026-07-01",
      minAge: 18,
      maxAgeByCommunity: tnReserved(32, 42),
      relaxationYears: { PWD: 10, DESTITUTE_WIDOW: 10 },
      qualifications: ["sslc"],
      degreeSubjects: [],
      pstmNote: TN_PSTM_NOTE,
    },
  },
  {
    code: "tnpsc-group-2",
    name: "TNPSC Group 2",
    conductingBody: "TNPSC",
    level: "state",
    minQualification: "degree",
    fullPrep: true,
    description: `${SEED_MARK} Combined Civil Services Examination - II (interview posts): preliminary exam, main written exam and interview.`,
    stages: ["Preliminary exam (OMR)", "Main written exam", "Interview", "Counselling"],
    patternMode: "omr",
    patternQuestions: 200,
    patternMinutes: 180,
    negativeMarking: false,
    officialUrl: TNPSC_URL,
    rule: {
      ageAsOf: "2026-07-01",
      minAge: 21,
      maxAgeByCommunity: tnReserved(32, null),
      relaxationYears: { PWD: 10 },
      qualifications: ["degree"],
      degreeSubjects: [],
      pstmNote: TN_PSTM_NOTE,
    },
  },
  {
    code: "tnpsc-group-2a",
    name: "TNPSC Group 2A",
    conductingBody: "TNPSC",
    level: "state",
    minQualification: "degree",
    fullPrep: true,
    description: `${SEED_MARK} Combined Civil Services Examination - II (non-interview posts): preliminary exam and main written exam.`,
    stages: ["Preliminary exam (OMR)", "Main written exam", "Counselling"],
    patternMode: "omr",
    patternQuestions: 200,
    patternMinutes: 180,
    negativeMarking: false,
    officialUrl: TNPSC_URL,
    rule: {
      ageAsOf: "2026-07-01",
      minAge: 18,
      maxAgeByCommunity: tnReserved(32, null),
      relaxationYears: { PWD: 10 },
      qualifications: ["degree"],
      degreeSubjects: [],
      pstmNote: TN_PSTM_NOTE,
    },
  },
  {
    code: "ssc-chsl",
    name: "SSC CHSL (Combined Higher Secondary Level)",
    conductingBody: "SSC",
    level: "central",
    minQualification: "hsc",
    fullPrep: false,
    description: `${SEED_MARK} Staff Selection Commission exam for clerk-level central government posts.`,
    stages: ["Tier 1 (computer-based)", "Tier 2 (computer-based and skill test)", "Document verification"],
    patternMode: "cbt",
    patternQuestions: 100,
    patternMinutes: 60,
    negativeMarking: true,
    officialUrl: SSC_URL,
    rule: {
      ageAsOf: "2027-01-01",
      minAge: 18,
      maxAgeByCommunity: central(27),
      relaxationYears: { PWD: 10, EX_SERVICEMAN: 3 },
      qualifications: ["hsc"],
      degreeSubjects: [],
      pstmNote: null,
    },
  },
  {
    code: "ssc-mts",
    name: "SSC MTS (Multi-Tasking Staff)",
    conductingBody: "SSC",
    level: "central",
    minQualification: "sslc",
    fullPrep: false,
    description: `${SEED_MARK} Staff Selection Commission exam for Multi-Tasking Staff posts in central government offices.`,
    stages: ["Computer-based exam", "Physical test (some posts)", "Document verification"],
    patternMode: "cbt",
    patternQuestions: 90,
    patternMinutes: 90,
    negativeMarking: true,
    officialUrl: SSC_URL,
    rule: {
      ageAsOf: "2027-01-01",
      minAge: 18,
      maxAgeByCommunity: central(25),
      relaxationYears: { PWD: 10, EX_SERVICEMAN: 3 },
      qualifications: ["sslc"],
      degreeSubjects: [],
      pstmNote: null,
    },
  },
];

export const SEED_GLOSSARY: { term: string; meaning: string }[] = [
  { term: "Age relaxation", meaning: "Extra years added to the upper age limit for some groups, such as persons with disability." },
  { term: "Amendment", meaning: "A change made to the Constitution or to a law." },
  { term: "Answer key", meaning: "The list of correct answers that the exam board publishes after the exam." },
  { term: "Community certificate", meaning: "An official certificate that shows your community, such as BC, MBC or SC." },
  { term: "Counselling", meaning: "The stage after the results where selected people choose their posts, in order of rank." },
  { term: "Cutoff", meaning: "The lowest mark needed to reach the next stage or to be selected." },
  { term: "Fundamental Rights", meaning: "Basic rights that the Constitution of India gives to people. They are in Part III." },
  { term: "Hall ticket", meaning: "The entry card you must bring to the exam. It shows your exam centre and register number." },
  { term: "Negative marking", meaning: "Marks are taken away for each wrong answer." },
  { term: "Notification", meaning: "The official announcement of an exam, with the posts, vacancies, rules and dates." },
  { term: "OMR", meaning: "A printed answer sheet where you shade a bubble for each answer. A machine reads it." },
  { term: "Preamble", meaning: "The short introduction at the start of the Constitution of India." },
  { term: "Preliminary exam", meaning: "The first screening exam. If you pass it, you can write the main exam." },
  { term: "PSTM", meaning: "Person Studied in Tamil Medium. Some TNPSC posts are set aside for them." },
  { term: "Syllabus", meaning: "The official list of topics that the exam can ask about." },
  { term: "Vacancy", meaning: "An empty post that the exam will fill." },
];

interface SeedLesson {
  topicId: string;
  title: string;
  readingMinutes: number;
  sourceCitation: string;
  sourceUrl: string | null;
  bodyMarkdown: string;
}

// Original lessons written for HeyMey in simple English (§10.2). Facts kept to well-established ones.
export const SEED_LESSONS: SeedLesson[] = [
  {
    topicId: "0199f5a0-0101-7000-8000-000000000101",
    title: "The Preamble",
    readingMinutes: 2,
    sourceCitation: "Constitution of India, Preamble (as amended by the Constitution (Forty-second Amendment) Act, 1976); TN State Board Political Science, Class 11",
    sourceUrl: null,
    bodyMarkdown: `# The Preamble

The Preamble is the short introduction at the start of the Constitution of India. It tells us where the Constitution gets its power, what kind of country India is, and what the Constitution wants to achieve.

## Where the power comes from
The Preamble begins with the words "We, the people of India". This means the power of the Constitution comes from the people.

## Key dates
- The Constituent Assembly adopted the Constitution on **26 November 1949**. This day is now observed as Constitution Day.
- The Constitution came into force on **26 January 1950**. This is Republic Day.

## What kind of country India is
The Preamble calls India a **Sovereign, Socialist, Secular, Democratic Republic**.
- **Sovereign**: India makes its own decisions. No outside power controls it.
- **Socialist**: the State works to reduce inequality.
- **Secular**: the State has no religion of its own and treats all religions equally.
- **Democratic**: the people choose their government by voting.
- **Republic**: the head of the State is elected. There is no king or queen.

## The goals
The Preamble promises all citizens **Justice** (social, economic and political), **Liberty** (of thought, expression, belief, faith and worship), **Equality** (of status and of opportunity) and **Fraternity** (a feeling of brotherhood that protects the dignity of each person and the unity and integrity of the Nation).

## The only change so far
The **42nd Amendment (1976)** added three words: "Socialist", "Secular" and "Integrity". It is the only time the Preamble has been changed.

## Exam tip
In the Kesavananda Bharati case (1973), the Supreme Court said that the Preamble is a part of the Constitution.
`,
  },
  {
    topicId: "0199f5a0-0102-7000-8000-000000000102",
    title: "Fundamental Rights",
    readingMinutes: 2,
    sourceCitation: "Constitution of India, Part III (Articles 12-35) and Article 300A; TN State Board Social Science (Civics)",
    sourceUrl: null,
    bodyMarkdown: `# Fundamental Rights

Fundamental Rights are basic rights that the Constitution of India guarantees. They are in **Part III** of the Constitution, in **Articles 12 to 35**.

## The six Fundamental Rights
1. **Right to Equality** (Articles 14 to 18): everyone is equal before the law. Untouchability is abolished (Article 17).
2. **Right to Freedom** (Articles 19 to 22): for example, freedom of speech and expression, and protection of life and personal liberty (Article 21).
3. **Right against Exploitation** (Articles 23 and 24): forced labour is banned. Children below 14 years must not work in factories, mines or other dangerous jobs.
4. **Right to Freedom of Religion** (Articles 25 to 28).
5. **Cultural and Educational Rights** (Articles 29 and 30): minorities can protect their language and culture, and run their own educational institutions.
6. **Right to Constitutional Remedies** (Article 32): you can go straight to the Supreme Court if your Fundamental Rights are violated.

## What changed over time
The Constitution first had seven Fundamental Rights. The **44th Amendment (1978)** removed the Right to Property from the list. It is now a legal right under **Article 300A**.

## Why Article 32 matters
Dr B. R. Ambedkar called Article 32 the "heart and soul" of the Constitution, because it makes the other rights real. The Supreme Court can issue orders called **writs** to protect these rights. High Courts can do the same under Article 226.

## Exam tip
Fundamental Rights can be enforced in a court. The Directive Principles of State Policy (Part IV) cannot.
`,
  },
  {
    topicId: "0199f5a0-0201-7000-8000-000000000201",
    title: "The Harappan (Indus Valley) Civilisation",
    readingMinutes: 2,
    sourceCitation: "TN State Board Social Science (History), Class 6",
    sourceUrl: null,
    bodyMarkdown: `# The Harappan (Indus Valley) Civilisation

The Harappan Civilisation is one of the oldest city civilisations in the world. It grew in the north-western part of the Indian subcontinent, around the Indus river and its branches. Its main phase is usually dated to about **2600 BCE to 1900 BCE**. It belongs to the **Bronze Age**.

## How it was found
- **Harappa** (on the Ravi river, now in Pakistan) was excavated in **1921** under **Daya Ram Sahni**.
- **Mohenjo-daro** (on the Indus river, now in Pakistan) was excavated in **1922** under **R. D. Banerji**.

The civilisation is called "Harappan" after the first site that was found.

## Well-planned cities
- Streets were laid out in a grid and crossed at right angles.
- Houses were built with baked bricks of a standard size.
- Covered drains ran along the streets. Few ancient cities had such good drainage.
- Many cities had a raised **citadel** and a lower town.

## Important sites
- **Mohenjo-daro**: the **Great Bath**, a large public water tank.
- **Lothal** (Gujarat): a brick structure that many experts see as a dockyard. It shows trade by boat.
- **Kalibangan** (Rajasthan) and **Dholavira** (Gujarat) are other well-known sites in India.

## Life and work
People grew wheat and barley, kept animals, and made beads, pottery and bronze tools. They traded with distant lands. They used standard weights and stone **seals** with pictures of animals.

## Exam tip
The Harappan script has **not been deciphered** yet. Nobody can read it today.
`,
  },
  {
    topicId: "0199f5a0-0601-7000-8000-000000000601",
    title: "Percentage",
    readingMinutes: 2,
    sourceCitation: "TN State Board Mathematics, Class 8 (percentage); worked examples written by HeyMey",
    sourceUrl: null,
    bodyMarkdown: `# Percentage

"Per cent" means "out of 100". So **25%** means 25 out of every 100. That is 25/100, or 1/4.

## Changing between forms
- Fraction to percentage: multiply by 100. Example: 3/5 × 100 = **60%**.
- Percentage to fraction: divide by 100. Example: 40% = 40/100 = **2/5**.
- Percentage to decimal: move the decimal point two places to the left. Example: 7.5% = **0.075**.

## Finding a percentage of a number
x% of y = (x × y) ÷ 100.

Example: 15% of 240 = (15 × 240) ÷ 100 = **36**.

## Percentage increase and decrease
Change % = (change ÷ original value) × 100.

Example: a price goes up from ₹400 to ₹500. The change is ₹100. Increase = (100 ÷ 400) × 100 = **25%**.

Always divide by the **original** value, not the new one.

## A common trap
A price goes up by 10% and then down by 10%. It does **not** come back to the start.

Start with ₹100. After a 10% rise: ₹110. After a 10% fall: 110 − 11 = **₹99**. Overall, the price fell by 1%.

## Useful values to remember
- 50% = 1/2
- 25% = 1/4
- 20% = 1/5
- 12.5% = 1/8
- 10% = 1/10

## Practice
1. What is 12% of 350? (Answer: 42)
2. A student scores 45 out of 60. What is the percentage? (Answer: 75%)
3. A town's population grew from 8,000 to 9,200. What is the percentage increase? (Answer: 15%)
`,
  },
];

// ---------------------------------------------------------------- syllabus YAML
interface YamlTopic {
  id: string;
  code: string;
  name: string;
  shared_with?: string[];
  textbook_refs?: { book: string; class_level?: number | null; chapter?: number | string | null; pages?: string | null; url?: string | null }[];
}
interface YamlSyllabus {
  exam: { code: string; textbook_site?: string };
  subjects: { code: string; name: string; topics: YamlTopic[] }[];
}

export async function loadSyllabi(dir: URL = SYLLABUS_DIR): Promise<YamlSyllabus[]> {
  const files = (await readdir(dir)).filter((f) => f.endsWith(".yaml") || f.endsWith(".yml")).sort();
  return Promise.all(files.map(async (f) => parse(await readFile(new URL(f, dir), "utf8")) as YamlSyllabus));
}

async function seedSyllabus(prisma: PrismaClient, syllabi: YamlSyllabus[], examCodes: Set<string>) {
  // Merge every file: a topic appears once (stable id); its tags = owning exams + shared_with.
  const topics = new Map<string, { t: YamlTopic; subject: string; order: number; tags: Set<string>; site?: string }>();
  const subjects = new Map<string, { name: string; order: number }>();
  for (const s of syllabi) {
    s.subjects.forEach((subj, si) => {
      if (!subjects.has(subj.code)) subjects.set(subj.code, { name: subj.name, order: si + 1 });
      subj.topics.forEach((t, ti) => {
        if (!UUID.test(t.id)) throw new Error(`syllabus: topic ${t.code} has a bad id ${t.id}`);
        const tags = new Set([s.exam.code, ...(t.shared_with ?? [])]);
        for (const c of tags) if (!examCodes.has(c)) throw new Error(`syllabus: topic ${t.code} tags unknown exam ${c}`);
        const existing = topics.get(t.id);
        if (existing && existing.t.code !== t.code) throw new Error(`syllabus: id ${t.id} used by ${existing.t.code} and ${t.code}`);
        if (existing) for (const c of tags) existing.tags.add(c);
        else topics.set(t.id, { t, subject: subj.code, order: ti + 1, tags, ...(s.exam.textbook_site ? { site: s.exam.textbook_site } : {}) });
      });
    });
  }

  const subjectIds = new Map<string, string>();
  for (const [code, s] of subjects) {
    const row = await prisma.subject.upsert({
      where: { code },
      create: { code, name: s.name, order: s.order },
      update: { name: s.name, order: s.order },
    });
    subjectIds.set(code, row.id);
  }

  for (const { t, subject, order, tags, site } of topics.values()) {
    const subjectId = subjectIds.get(subject) as string;
    await prisma.$transaction([
      prisma.topic.upsert({
        where: { id: t.id },
        create: { id: t.id, subjectId, code: t.code, name: t.name, order },
        update: { subjectId, code: t.code, name: t.name, order },
      }),
      prisma.topicExamTag.deleteMany({ where: { topicId: t.id, examCode: { notIn: [...tags] } } }),
      prisma.topicExamTag.createMany({ data: [...tags].map((examCode) => ({ topicId: t.id, examCode })), skipDuplicates: true }),
      prisma.textbookRef.deleteMany({ where: { topicId: t.id } }),
      prisma.textbookRef.createMany({
        data: (t.textbook_refs ?? []).map((r) => ({
          topicId: t.id,
          book: r.book,
          classLevel: r.class_level ?? null,
          chapter: r.chapter === undefined || r.chapter === null ? null : String(r.chapter),
          pages: r.pages ?? null,
          url: r.url ?? site ?? null,
        })),
      }),
    ]);
  }
  return { subjects: subjects.size, topics: topics.size };
}

export const seeder = {
  name: "catalog",
  async run(prisma: PrismaClient): Promise<string> {
    if (process.env.HEYMEY_ENV === "production") throw new Error("catalog seed: refusing to run in production");

    for (const e of SEED_EXAMS) {
      const { rule, ...fields } = e;
      const data = { ...fields, notificationUrl: null, status: "published", sourceUrl: e.officialUrl, verifiedBy: null, verifiedAt: null };
      const exam = await prisma.exam.upsert({ where: { code: e.code }, create: data, update: data });
      const ruleData = {
        ageAsOf: new Date(`${rule.ageAsOf}T00:00:00.000Z`),
        minAge: rule.minAge,
        maxAgeByCommunity: rule.maxAgeByCommunity,
        relaxationYears: rule.relaxationYears,
        qualifications: rule.qualifications,
        degreeSubjects: rule.degreeSubjects,
        pstmNote: rule.pstmNote,
        status: "published",
        sourceUrl: e.officialUrl,
        verifiedBy: null,
        verifiedAt: null,
      };
      await prisma.eligibilityRule.upsert({
        where: { examId_version: { examId: exam.id, version: 1 } },
        create: { examId: exam.id, version: 1, ...ruleData },
        update: ruleData,
      });
    }

    const { subjects, topics } = await seedSyllabus(prisma, await loadSyllabi(), new Set(SEED_EXAMS.map((e) => e.code)));

    for (const l of SEED_LESSONS) {
      const data = { ...l, status: "published", publishedAt: new Date("2026-10-20T00:00:00.000Z") };
      await prisma.lesson.upsert({
        where: { topicId_version: { topicId: l.topicId, version: 1 } },
        create: { ...data, version: 1 },
        update: data,
      });
    }

    for (const g of SEED_GLOSSARY) {
      await prisma.glossaryTerm.upsert({ where: { term: g.term }, create: g, update: { meaning: g.meaning } });
    }

    return `${SEED_EXAMS.length} exams (SEED rules), ${subjects} subjects, ${topics} topics, ${SEED_LESSONS.length} lessons, ${SEED_GLOSSARY.length} glossary terms`;
  },
};
