import { LazyFx } from "@/components/LazyFx";

const CARDS = [
  { time: "Morning", title: "Today's Flash", body: "Ten questions, five minutes. Everyone in your district gets the same set, so the ranking is fair.", tone: "from-purple-700/50" },
  { time: "Afternoon", title: "One doubt, answered", body: "Stuck on a concept? Three doubts a day are free, explained in Tamil or English.", tone: "from-cyan-400/30" },
  { time: "Evening", title: "Revise what is slipping", body: "Topics you are forgetting come back for revision before they are gone, not after.", tone: "from-violet-500/40" },
  { time: "Night", title: "See where you stand", body: "Your readiness updates from what you actually did today. No flattering numbers.", tone: "from-mint-400/25" },
] as const;

export function CardStack() {
  return (
    <section id="day" aria-labelledby="day-title" className="relative px-5 py-[clamp(4rem,12svh,8rem)] sm:px-8">
      <div className="mx-auto max-w-5xl">
        <p className="t-eyebrow">A day with HeyMey</p>
        <h2 id="day-title" className="t-h2 mt-4 max-w-2xl text-balance">
          Small, honest steps that <em className="text-mint-300">add up</em>.
        </h2>
        <div className="mt-14 flex flex-col gap-[14svh] pb-[10svh]">
          {CARDS.map((c, i) => (
            <article
              key={c.title}
              data-stack-card
              className="stack-card grad-border relative isolate overflow-hidden rounded-[2rem] p-[clamp(1.5rem,4vw,3.5rem)] [--grad-fill:#0a0714]"
            >
              {/* Opaque card (solid fill from .grad-border) with a tinted wash on top, so covered cards never show through. */}
              <div aria-hidden className={`absolute inset-0 -z-10 bg-gradient-to-br ${c.tone} to-transparent`} />
              <div className="grid gap-6 md:grid-cols-[auto_1fr] md:items-end">
                <span className="font-[family-name:var(--font-display)] text-[clamp(4rem,10vw,8rem)] leading-none text-white/15">
                  0{i + 1}
                </span>
                <div>
                  <p className="t-eyebrow">{c.time}</p>
                  <h3 className="t-h3 mt-2">{c.title}</h3>
                  <p className="t-lead mt-3 max-w-xl">{c.body}</p>
                </div>
              </div>
            </article>
          ))}
        </div>
      </div>
      <LazyFx name="stack" target="#day" />
    </section>
  );
}
