import type { Metadata } from "next";
import { PageIntro } from "@/components/PageIntro";
import { TNPSC_SOURCES } from "@/lib/site";

export const metadata: Metadata = {
  title: "Exams",
  description: "Comprehensive preparation for TNPSC, TET, SET, and all Tamil Nadu Government Exams on HeyMey.",
};

const EXAMS = [
  {
    name: "TNPSC Group IV & VAO",
    tamil: "தொகுதி IV & VAO",
    body: "Village Administrative Officer, Junior Assistant, Typist and other Group IV posts. Daily Flash and a curated general-studies bank.",
  },
  {
    name: "TNPSC Group II & IIA",
    tamil: "தொகுதி II & IIA",
    body: "Daily Flash, free diagnostic tests, full mock tests and topic-level readiness diagnostics.",
  },
  {
    name: "Tamil Nadu TET (TNTET)",
    tamil: "ஆசிரியர் தகுதித் தேர்வு (TET)",
    body: "Complete preparation for Paper I & II with child development, pedagogy, language, and subject-specific banks.",
  },
  {
    name: "Tamil Nadu SET (TNSET)",
    tamil: "மாநிலத் தகுதித் தேர்வு (SET)",
    body: "State Eligibility Test preparation for assistant professorship with research and teaching aptitude modules.",
  },
  {
    name: "TN Police & Uniformed Services",
    tamil: "சீருடைப் பணியாளர் தேர்வு (TNUSRB)",
    body: "Sub-Inspector (SI) and Police Constable preparation with focused practice sets, current affairs, and aptitude tests.",
  },
  {
    name: "Other TN Govt Examinations",
    tamil: "பிற அரசுத் தேர்வுகள்",
    body: "TRB, MRB, Forest Services, and departmental recruitment exams across Tamil Nadu state boards.",
  },
] as const;

export default function ExamsPage() {
  return (
    <>
      <PageIntro
        eyebrow="Exams"
        title={
          <>
            Built for <em className="text-mint-300">Tamil Nadu Government Exams</em>.
          </>
        }
        lead="Comprehensive, honest preparation for TNPSC, TET, SET, and all major Tamil Nadu government examinations."
      />
      <section aria-label="Supported exams" className="mx-auto grid max-w-6xl gap-5 px-5 pb-20 sm:px-8 md:grid-cols-3">
        {EXAMS.map((e) => (
          <article key={e.name} className="grad-border rounded-[1.75rem] p-7 [--grad-fill:#0a0714]">
            <p lang="ta" className="font-[family-name:var(--font-tamil)] text-mint-300">
              {e.tamil}
            </p>
            <h2 className="t-h3 mt-2">{e.name}</h2>
            <p className="mt-3 leading-relaxed text-ink-2">{e.body}</p>
          </article>
        ))}
      </section>
      <section aria-labelledby="g4-title" className="border-t border-line">
        <div className="mx-auto max-w-6xl px-5 py-20 sm:px-8">
          <h2 id="g4-title" className="t-h2 max-w-3xl text-balance">
            Group IV in 2025, by the official numbers.
          </h2>
          <ul className="mt-8 max-w-3xl list-disc space-y-4 pl-5 text-[1.08rem] leading-relaxed text-ink-2">
            <li>The notification for 3,935 Group IV posts was issued on 25 April 2025, and the exam was held on 12 July 2025.</li>
            <li>On 26 September 2025, 727 more posts were added, for 4,662 in total.</li>
            <li>Across the 2022 and 2024 notifications, 17,799 Group IV posts were filled over five financial years.</li>
          </ul>
          <p className="mt-8 text-sm text-ink-3">
            Sources:{" "}
            <a className="underline underline-offset-4 hover:text-white" href={TNPSC_SOURCES.pr44.url} target="_blank" rel="noopener">
              {TNPSC_SOURCES.pr44.label}
            </a>
            {"; "}
            <a className="underline underline-offset-4 hover:text-white" href={TNPSC_SOURCES.pr132.url} target="_blank" rel="noopener">
              {TNPSC_SOURCES.pr132.label}
            </a>
            .
          </p>
        </div>
      </section>
    </>
  );
}
