import { LazyFx } from "@/components/LazyFx";

const WHY_SEGMENTS: Array<{ text: string; accent?: boolean }> = [
  {
    text: "Every year, lakhs of aspirants sit for TNPSC, TET, SET, and other Tamil Nadu government exams, and almost none of them can say honestly where they",
  },
  { text: "truly stand.", accent: true },
  {
    text: "They collect PDFs, chase rumours and measure themselves by volume, while posts shrink and the room gets more crowded. HeyMey is built on one belief: the truth, told gently and daily, is the most useful thing a student can have. It shows you where you stand, what to do",
  },
  { text: "today,", accent: true },
  { text: "and never sells you false comfort." },
];

const WORDS = WHY_SEGMENTS.flatMap((segment) =>
  segment.text.split(" ").filter(Boolean).map((word) => ({ word, accent: segment.accent }))
);

/** Copy is verbatim from the brief. Accent phrases are wrapped for the mint reveal. */
export function Why() {
  return (
    <section id="why" aria-labelledby="why-title" className="relative px-5 py-[clamp(6rem,18svh,12rem)] sm:px-8">
      <div className="mx-auto max-w-6xl">
        <h2 id="why-title" className="t-eyebrow">
          Why HeyMey
        </h2>
        <p
          data-why-text
          className="mt-8 font-[family-name:var(--font-display)] text-[clamp(1.85rem,1rem+3.1vw,4.1rem)] leading-[1.12] tracking-[-0.01em] text-white text-balance"
        >
          {WORDS.map((item, idx) => (
            <span
              key={idx}
              data-accent={item.accent ? "true" : undefined}
              className={`why-word inline-block mr-[0.25em] ${item.accent ? "text-mint-300" : ""}`}
            >
              {item.word}
            </span>
          ))}
        </p>
      </div>
      <LazyFx name="why" target="#why" />
    </section>
  );
}

