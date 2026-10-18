import type { Metadata } from "next";
import { PageIntro } from "@/components/PageIntro";
import { GET_STARTED_URL } from "@/lib/site";

export const metadata: Metadata = { title: "Pricing", description: "Start free. HeyMey Pro is ₹99 a month or ₹999 a year." };

// Prices and features mirror the app (heymey-app: lib/razorpay.ts PRICING,
// app/student/pro/page.tsx feature lists, app/api/ai/doubt limits).
const FREE = ["Daily Flash Challenge", "3 AI doubts a day", "Free diagnostic test and basic mock tests", "Community access", "Honest readiness score"];
const PRO = [
  "Everything in Free",
  "Unlimited Flash Challenges",
  "Unlimited AI doubts",
  "All creator materials",
  "Spaced repetition engine",
  "Personalised weak-topic reports",
  "Priority exam alerts (TNPSC, TET, SET)",
  "Offline PDF downloads",
];
const PACKS = [
  { price: 49, sudars: 55 },
  { price: 99, sudars: 115 },
  { price: 199, sudars: 240 },
] as const;

export default function PricingPage() {
  return (
    <>
      <PageIntro
        eyebrow="Pricing"
        title={
          <>
            Start free. <em className="text-mint-300">Stay honest.</em>
          </>
        }
        lead="Every aspirant gets the daily habit for free. Pro removes the limits."
      />
      <section aria-label="Plans" className="mx-auto grid max-w-6xl gap-5 px-5 pb-10 sm:px-8 md:grid-cols-3">
        <Plan name="Free" price="₹0" period="forever" items={FREE} />
        <Plan name="Pro" price="₹99" period="per month" note="or ₹999 a year" items={PRO} highlight />
        <Plan
          name="Founding Aspirant"
          price="₹699"
          period="per year"
          note="An early-supporter plan with everything in Pro, for a limited number of early members."
          items={PRO}
        />
      </section>
      <section aria-labelledby="sudar-title" className="mx-auto max-w-6xl px-5 pb-10 sm:px-8">
        <div className="rounded-[1.75rem] border border-line p-7">
          <h2 id="sudar-title" className="t-h3">
            Sudar packs
          </h2>
          <p className="mt-2 text-ink-2">One Sudar is one rupee. Bigger packs include a few extra.</p>
          <ul className="mt-5 grid gap-3 sm:grid-cols-3">
            {PACKS.map((p) => (
              <li key={p.price} className="rounded-2xl bg-white/5 p-5">
                <p className="text-2xl font-semibold">₹{p.price}</p>
                <p className="text-ink-2">{p.sudars} Sudars</p>
              </li>
            ))}
          </ul>
        </div>
      </section>
      <p className="mx-auto max-w-6xl px-5 pb-24 text-sm text-ink-3 sm:px-8">
        Prices in Indian rupees. HeyMey is in closed beta: payments are not open yet, and nothing is charged until they are.
      </p>
    </>
  );
}

function Plan({
  name,
  price,
  period,
  note,
  items,
  highlight,
}: {
  name: string;
  price: string;
  period: string;
  note?: string;
  items: readonly string[];
  highlight?: boolean;
}) {
  return (
    <article
      className={`flex flex-col rounded-[1.75rem] p-7 ${
        highlight ? "grad-border shadow-[0_0_80px_-30px_rgba(93,243,190,0.5)] [--grad-fill:#0d0920]" : "border border-line"
      }`}
    >
      <h2 className="text-lg font-semibold">{name}</h2>
      <p className="mt-4">
        <span className="font-[family-name:var(--font-display)] text-6xl">{price}</span> <span className="text-ink-3">{period}</span>
      </p>
      {note && <p className="mt-2 text-sm text-ink-2">{note}</p>}
      <ul className="mt-6 flex-1 space-y-2.5 text-[0.98rem] text-ink-2">
        {items.map((i) => (
          <li key={i} className="flex gap-2.5">
            <span aria-hidden className="text-mint-400">
              ✓
            </span>
            {i}
          </li>
        ))}
      </ul>
      <a
        href={GET_STARTED_URL}
        className={`mt-8 flex min-h-12 items-center justify-center rounded-full font-semibold ${
          highlight ? "bg-white text-black" : "border border-white/20"
        }`}
      >
        Get Started<span className="visually-hidden"> with {name}</span>
      </a>
    </article>
  );
}
