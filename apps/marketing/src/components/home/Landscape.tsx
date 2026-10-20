import Link from "next/link";
import { LazyFx } from "@/components/LazyFx";

const PANELS = [
  {
    key: "know",
    label: "Know",
    title: "Where you truly stand.",
    body: "An honest readiness estimate, shown with how confident it is. When there is too little data, HeyMey says so instead of guessing.",
    Visual: KnowVisual,
  },
  {
    key: "practise",
    label: "Practise",
    title: "Five minutes. Every day.",
    body: "One daily challenge of ten questions. Short enough to keep, real enough to count.",
    Visual: PractiseVisual,
  },
  {
    key: "understand",
    label: "Understand",
    title: "Ask in Tamil or English.",
    body: "Get an instant explanation for a doubt, in the language you actually think in.",
    Visual: UnderstandVisual,
  },
  {
    key: "return",
    label: "Return",
    title: "Missed a day? Come back.",
    body: "Habits break. HeyMey forgives a missed day, so one bad evening doesn't erase a month of work.",
    Visual: ReturnVisual,
  },
  {
    key: "stages",
    label: "Exam stages",
    title: "Ready for every stage.",
    body: "The app follows the exam calendar: notification, exam week, answer key and results each get their own mode.",
    Visual: StagesVisual,
  },
] as const;

export function Landscape() {
  return (
    <section id="how" aria-labelledby="how-title" className="relative py-[clamp(4rem,10svh,7rem)]">
      <div className="mx-auto mb-12 max-w-6xl px-5 sm:px-8">
        <p className="t-eyebrow">How it works</p>
        <h2 id="how-title" className="t-h2 mt-4 max-w-3xl text-balance">
          Five honest habits, <em className="text-mint-300">one</em> daily companion.
        </h2>
      </div>

      <div className="ls-viewport relative">
        <ol className="ls-track">
          {PANELS.map(({ key, label, title, body, Visual }, i) => (
            <li key={key} className="ls-panel" data-panel>
              <div className="relative z-10 max-w-xl">
                <p className="flex items-center gap-3 text-sm font-semibold uppercase tracking-[0.18em] text-ink-3">
                  <span className="font-[family-name:var(--font-display)] text-2xl normal-case tracking-normal text-mint-300">
                    0{i + 1}
                  </span>
                  {label}
                </p>
                <h3 className="t-h2 mt-5 text-balance">{title}</h3>
                <p className="t-lead mt-5 max-w-md">{body}</p>
                {key === "stages" && (
                  <Link
                    href="/exams"
                    className="mt-7 inline-flex min-h-11 items-center gap-2 font-semibold text-mint-300 underline-offset-4 hover:underline"
                  >
                    See supported exams <span aria-hidden>→</span>
                  </Link>
                )}
              </div>
              <div data-parallax aria-hidden className="anim-loop relative flex min-h-[260px] items-center justify-center">
                <Visual />
              </div>
            </li>
          ))}
        </ol>
        <div className="ls-progress" aria-hidden>
          <span />
        </div>
      </div>
      <LazyFx name="landscape" target="#how" />
    </section>
  );
}

/* ── Panel visuals (decorative; illustrative values, not user data) ─────── */

function Glow() {
  return (
    <div className="pointer-events-none absolute inset-[8%] -z-10 rounded-full bg-[radial-gradient(circle,rgba(108,66,239,0.45),transparent_65%)] blur-2xl" />
  );
}

function KnowVisual() {
  // Semicircle gauge: estimate 62 with a 54–70 confidence band.
  const r = 120;
  const arc = (from: number, to: number) => {
    const a = (v: number) => Math.PI * (1 - v / 100);
    const p = (v: number) => [150 + r * Math.cos(a(v)), 160 - r * Math.sin(a(v))];
    const [x1, y1] = p(from);
    const [x2, y2] = p(to);
    return `M ${x1} ${y1} A ${r} ${r} 0 0 1 ${x2} ${y2}`;
  };
  return (
    <div className="relative w-full max-w-[420px]">
      <Glow />
      <svg viewBox="0 0 300 200" className="w-full">
        <defs>
          <linearGradient id="know-g" x1="0" x2="1">
            <stop offset="0" stopColor="#5df3be" />
            <stop offset="0.5" stopColor="#38bdf8" />
            <stop offset="1" stopColor="#a855f7" />
          </linearGradient>
        </defs>
        <path d={arc(0, 100)} stroke="rgba(255,255,255,0.1)" strokeWidth="18" fill="none" strokeLinecap="round" />
        <path d={arc(0, 62)} stroke="url(#know-g)" strokeWidth="18" fill="none" strokeLinecap="round" />
        <path
          d={arc(54, 70)}
          stroke="#b1f0cf"
          strokeOpacity="0.35"
          strokeWidth="34"
          fill="none"
          style={{ animation: "hm-pulse 3.2s ease-in-out infinite" }}
        />
        <text x="150" y="150" textAnchor="middle" fill="#fff" fontSize="46" fontWeight="700">
          62
        </text>
        <text x="150" y="178" textAnchor="middle" fill="rgba(255,255,255,0.6)" fontSize="13">
          likely between 54 and 70
        </text>
      </svg>
    </div>
  );
}

function PractiseVisual() {
  return (
    <div className="relative grid w-full max-w-[360px] place-items-center">
      <Glow />
      <svg viewBox="0 0 220 220" className="w-[min(70vw,260px)]">
        <circle cx="110" cy="110" r="92" stroke="rgba(255,255,255,0.1)" strokeWidth="10" fill="none" />
        <circle
          cx="110"
          cy="110"
          r="92"
          stroke="#5df3be"
          strokeWidth="10"
          fill="none"
          strokeLinecap="round"
          pathLength={100}
          strokeDasharray="100"
          transform="rotate(-90 110 110)"
          style={{ animation: "hm-countdown 12s linear infinite" }}
        />
        <text x="110" y="122" textAnchor="middle" fill="#fff" fontSize="40" fontWeight="700">
          5:00
        </text>
      </svg>
      <div className="mt-5 flex gap-2">
        {Array.from({ length: 10 }).map((_, i) => (
          <span
            key={i}
            className="size-3 rounded-full bg-white/15"
            style={{ animation: `hm-dot 12s ${i * 1.1}s infinite` }}
          />
        ))}
      </div>
    </div>
  );
}

function UnderstandVisual() {
  return (
    <div className="relative flex w-full max-w-[440px] flex-col gap-4">
      <Glow />
      <p lang="ta" className="self-end rounded-3xl rounded-br-md bg-white/10 px-5 py-3 font-[family-name:var(--font-tamil)] text-[1.05rem]">
        அரசியலமைப்பு எப்போது நடைமுறைக்கு வந்தது?
      </p>
      <p
        className="self-start rounded-3xl rounded-bl-md border border-mint-400/30 bg-mint-400/10 px-5 py-3 text-[1.05rem] text-mint-300"
        style={{ animation: "hm-type 4.5s steps(48) infinite alternate" }}
      >
        On 26 January 1950. It was adopted on 26 November 1949.
      </p>
      <p className="self-end rounded-3xl rounded-br-md bg-white/10 px-5 py-3 text-[1.05rem]">Explain it in Tamil?</p>
    </div>
  );
}

function ReturnVisual() {
  const days = ["M", "T", "W", "T", "F", "S", "S"];
  return (
    <div className="relative w-full max-w-[440px]">
      <Glow />
      <div className="flex justify-between gap-2">
        {days.map((d, i) => {
          const missed = i === 3;
          return (
            <div key={i} className="flex flex-col items-center gap-2">
              <span
                className={`grid size-[clamp(2.4rem,9vw,3.4rem)] place-items-center rounded-full border ${
                  missed ? "border-violet-500 bg-violet-500/15" : "border-mint-400/40 bg-mint-400/15"
                }`}
                style={missed ? { animation: "hm-pulse 2.4s ease-in-out infinite" } : undefined}
              >
                {missed ? (
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#bd6cfb" strokeWidth="2">
                    <path d="M12 3l7 3v5c0 5-3.5 8.5-7 10-3.5-1.5-7-5-7-10V6l7-3z" />
                  </svg>
                ) : (
                  <span className="size-2.5 rounded-full bg-mint-400" />
                )}
              </span>
              <span className="text-xs text-ink-3">{d}</span>
            </div>
          );
        })}
      </div>
      <p className="mt-6 text-center text-sm text-ink-2">Streak kept: the missed day is shielded.</p>
    </div>
  );
}

function StagesVisual() {
  const stages = ["Notification", "Exam week", "Answer key", "Results"];
  return (
    <div className="relative w-full max-w-[460px]">
      <Glow />
      <div className="relative">
        <div className="absolute left-[11px] top-3 bottom-3 w-px bg-white/15" />
        <span
          className="absolute left-[6px] top-2 size-3 rounded-full bg-mint-400 shadow-[0_0_16px_#5df3be]"
          style={{ animation: "hm-stage 8s ease-in-out infinite" }}
        />
        <ul className="flex flex-col gap-5">
          {stages.map((s) => (
            <li key={s} className="flex items-center gap-5 pl-10">
              <span className="grad-border rounded-full px-4 py-2 text-[0.95rem] font-medium [--grad-fill:#0b0716]">
                {s}
              </span>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
