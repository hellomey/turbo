"use client";
import * as m from "motion/react-m";

const ease = [0.16, 1, 0.3, 1] as const;

/** Page header with a staggered entrance (Motion). Text is in the DOM from the start. */
export function PageIntro({ eyebrow, title, lead, children }: { eyebrow: string; title: React.ReactNode; lead?: React.ReactNode; children?: React.ReactNode }) {
  return (
    <m.header
      className="relative mx-auto max-w-6xl px-5 pb-12 pt-[clamp(8rem,20svh,12rem)] sm:px-8"
      initial="hidden"
      animate="show"
      variants={{ show: { transition: { staggerChildren: 0.09 } } }}
    >
      <div aria-hidden className="pointer-events-none absolute -top-24 left-1/2 -z-10 aspect-square w-[min(90vw,900px)] -translate-x-1/2 rounded-full bg-[radial-gradient(circle,rgba(80,45,217,0.35),transparent_65%)]" />
      <m.p className="t-eyebrow" variants={item}>
        {eyebrow}
      </m.p>
      <m.h1 className="t-display mt-5 max-w-4xl text-balance" variants={item}>
        {title}
      </m.h1>
      {lead && (
        <m.p className="t-lead mt-6 max-w-2xl" variants={item}>
          {lead}
        </m.p>
      )}
      {children && <m.div variants={item}>{children}</m.div>}
    </m.header>
  );
}

const item = { hidden: { opacity: 0, y: 28 }, show: { opacity: 1, y: 0, transition: { duration: 0.9, ease } } };
