import { LazyFx } from "@/components/LazyFx";

const PRINCIPLES = [
  { title: "No promised cutoffs.", body: "We never guarantee a rank, a cutoff or a sure-shot result. Nobody honestly can." },
  { title: "Scored on our side.", body: "Tests are graded on the server from your raw answers, never trusted from the screen." },
  { title: "Every number explains itself.", body: "Readiness comes from a visible formula, so you can see why it moved." },
  { title: "No false comfort.", body: "If you are behind, HeyMey tells you gently and shows the next step, not a pep talk." },
] as const;

export function TrustPrinciples() {
  return (
    <section id="trust" aria-labelledby="trust-title" className="relative px-5 py-[clamp(5rem,14svh,9rem)] sm:px-8">
      <div className="mx-auto max-w-6xl">
        <p className="t-eyebrow">What we will not do</p>
        <h2 id="trust-title" className="t-h2 mt-4 max-w-3xl text-balance">
          Trust is the <em className="text-mint-300">product</em>.
        </h2>
        <ol className="mt-12">
          {PRINCIPLES.map((p, i) => (
            <li key={p.title} data-trust-row className="relative py-[clamp(1.5rem,3.5vw,2.75rem)]">
              <svg aria-hidden className="absolute inset-x-0 bottom-0 h-px w-full overflow-visible" preserveAspectRatio="none" viewBox="0 0 100 1">
                <line data-trust-line x1="0" y1="0.5" x2="100" y2="0.5" stroke="url(#trust-grad)" strokeWidth="1" vectorEffect="non-scaling-stroke" pathLength={1} />
                {i === 0 && (
                  <defs>
                    <linearGradient id="trust-grad" x1="0" x2="1">
                      <stop offset="0" stopColor="#5df3be" />
                      <stop offset="0.5" stopColor="#38bdf8" />
                      <stop offset="1" stopColor="#a855f7" />
                    </linearGradient>
                  </defs>
                )}
              </svg>
              <div data-trust-reveal className="grid gap-3 md:grid-cols-[6rem_1fr_1.2fr] md:items-baseline">
                <span className="font-[family-name:var(--font-display)] text-2xl text-mint-300">0{i + 1}</span>
                <h3 className="font-[family-name:var(--font-display)] text-[clamp(1.75rem,1rem+2.4vw,3.25rem)] leading-tight">{p.title}</h3>
                <p className="t-lead">{p.body}</p>
              </div>
            </li>
          ))}
        </ol>
      </div>
      <LazyFx name="trust" target="#trust" />
    </section>
  );
}
