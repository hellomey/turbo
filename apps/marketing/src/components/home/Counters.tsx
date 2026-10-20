"use client";
// Verified figures only (TNPSC press releases). Count-up on enter (Motion);
// the final number is in the DOM from the start and announced as-is.
import { useEffect, useRef, useState } from "react";
import { animate, useInView, useReducedMotion } from "motion/react";
import { TNPSC_SOURCES } from "@/lib/site";

const STATS = [
  {
    value: 3935,
    label: "Group IV posts in the April 2025 notification",
    note: "Exam held on 12 July 2025.",
    source: TNPSC_SOURCES.pr44,
  },
  {
    value: 4662,
    label: "posts after 727 more were added in September 2025",
    note: "Still one exam, for lakhs of aspirants.",
    source: TNPSC_SOURCES.pr132,
  },
  {
    value: 17799,
    label: "Group IV posts filled across five financial years",
    note: "From the 2022 and 2024 notifications combined.",
    source: TNPSC_SOURCES.pr132,
  },
] as const;

const fmt = new Intl.NumberFormat("en-IN");

function CountUp({ value }: { value: number }) {
  const ref = useRef<HTMLSpanElement>(null);
  const inView = useInView(ref, { once: true, margin: "0px 0px 25% 0px" });
  const reduce = useReducedMotion();
  const [shown, setShown] = useState(value);
  useEffect(() => {
    if (!inView || reduce) return;
    const controls = animate(0, value, { duration: 1.8, ease: [0.16, 1, 0.3, 1], onUpdate: (v) => setShown(Math.round(v)) });
    return () => controls.stop();
  }, [inView, reduce, value]);
  return (
    <>
      <span ref={ref} aria-hidden className="tabular-nums">
        {fmt.format(shown)}
      </span>
      <span className="visually-hidden">{fmt.format(value)}</span>
    </>
  );
}

export function Counters() {
  return (
    <section id="numbers" aria-labelledby="numbers-title" className="relative px-5 py-[clamp(5rem,14svh,9rem)] sm:px-8">
      <div className="mx-auto max-w-6xl">
        <p className="t-eyebrow">The room is crowded</p>
        <h2 id="numbers-title" className="t-h2 mt-4 max-w-3xl text-balance">
          Lakhs of aspirants. A few thousand posts.
        </h2>
        <dl className="mt-14 grid gap-px overflow-hidden rounded-[2rem] border border-line bg-line md:grid-cols-3">
          {STATS.map((s) => (
            <div key={s.value} className="flex flex-col bg-black p-[clamp(1.5rem,3vw,2.5rem)]">
              <dt className="order-2 mt-3 text-[1.05rem] leading-snug text-white">{s.label}</dt>
              <dd className="order-1 bg-gradient-to-r from-mint-300 via-cyan-400 to-purple-300 bg-clip-text font-[family-name:var(--font-display)] text-[clamp(3.25rem,2rem+5vw,6.5rem)] leading-none text-transparent">
                <CountUp value={s.value} />
              </dd>
              <dd className="order-3 mt-2 text-sm text-ink-3">{s.note}</dd>
              <dd className="order-4 mt-5 text-xs">
                <a href={s.source.url} className="inline-flex min-h-11 items-center text-ink-3 underline underline-offset-4 hover:text-white" rel="noopener" target="_blank">
                  Source: {s.source.label}
                </a>
              </dd>
            </div>
          ))}
        </dl>
      </div>
    </section>
  );
}
