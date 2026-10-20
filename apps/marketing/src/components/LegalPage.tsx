import { legalContent } from "@/content/legal";
import { INDEPENDENCE_LINE } from "@/lib/site";

// Copy comes from the previous HeyMey site (src/content/legal.ts). It has not
// been reviewed by a lawyer; treat it as a draft until it is.
export function LegalPage({ doc }: { doc: "privacy" | "terms" | "refunds" }) {
  const page = legalContent[doc];
  const g = legalContent.grievance;
  return (
    <article className="mx-auto max-w-3xl px-5 pb-24 pt-[clamp(8rem,18svh,11rem)] sm:px-8">
      <p className="t-eyebrow">Legal</p>
      <h1 className="t-h2 mt-4">{page.title}</h1>
      <p className="mt-3 text-sm text-ink-3">{page.version}</p>
      <p className="t-lead mt-6">{page.summary}</p>
      <div className="mt-10 space-y-8">
        {page.sections.map((s) => (
          <section key={s.heading}>
            <h2 className="t-h3">{s.heading}</h2>
            <p className="mt-3 leading-relaxed text-ink-2">{s.content}</p>
          </section>
        ))}
      </div>
      <section id="grievance" aria-labelledby="grievance-title" className="mt-12 rounded-2xl border border-line p-6">
        <h2 id="grievance-title" className="t-h3">
          {g.title}
        </h2>
        <p className="mt-3 leading-relaxed text-ink-2">
          {g.officerName} ·{" "}
          <a href={`mailto:${g.email}`} className="underline underline-offset-4">
            {g.email}
          </a>{" "}
          · {g.address}
        </p>
        <p className="mt-2 text-sm text-ink-3">{g.responseTimeline}</p>
      </section>
      <p className="mt-12 border-t border-line pt-6 text-sm text-ink-3">{INDEPENDENCE_LINE}</p>
    </article>
  );
}
