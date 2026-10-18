import Image from "next/image";
import { LazyFx } from "@/components/LazyFx";

// Real screens from the HeyMey app (heymey-app), captured at 390px on a seeded
// local account. Not mock-ups.
const STEPS = [
  { src: "/assets/app/01-dashboard.webp", title: "Start with where you stand", body: "Your day opens on today's focus, your streak and your readiness." },
  { src: "/assets/app/02-flash.webp", title: "Five minutes, ten questions", body: "The daily Flash Challenge, on a real timer." },
  { src: "/assets/app/03-result.webp", title: "Scored honestly", body: "Graded on the server from your answers. No inflated numbers." },
  { src: "/assets/app/04-dashboard-after.webp", title: "Progress you can trust", body: "Readiness and streak move with what you actually did." },
] as const;

export function PhoneSequence() {
  return (
    <section id="app" aria-labelledby="app-title" className="relative">
      <div className="mx-auto max-w-6xl px-5 pt-[clamp(4rem,10svh,7rem)] sm:px-8">
        <p className="t-eyebrow">Inside the app</p>
        <h2 id="app-title" className="t-h2 mt-4 max-w-2xl text-balance">
          The real thing, <em className="text-mint-300">not</em> a mock-up.
        </h2>
      </div>

      <div className="ph-stage mx-auto max-w-6xl px-5 py-12 sm:px-8">
        <ol className="ph-steps">
          {STEPS.map((s, i) => (
            <li key={s.src} className="ph-step" data-ph-step>
              <p className="font-[family-name:var(--font-display)] text-2xl text-mint-300">0{i + 1}</p>
              <h3 className="t-h3 mt-2">{s.title}</h3>
              <p className="t-lead mt-2 max-w-md">{s.body}</p>
              <figure className="ph-step-figure mt-6 w-[min(78vw,300px)]">
                <div className="phone">
                  <div className="phone-screen">
                    <Image src={s.src} alt={`HeyMey app screen: ${s.title}`} width={390} height={844} sizes="300px" />
                  </div>
                </div>
              </figure>
            </li>
          ))}
        </ol>

        <div className="ph-screens phone" aria-hidden>
          <div className="phone-screen h-full">
            {STEPS.map((s, i) => (
              <Image key={s.src} data-ph-screen src={s.src} alt="" width={390} height={844} sizes="(min-width: 768px) 340px, 60vw" style={{ opacity: i === 0 ? 1 : 0 }} />
            ))}
          </div>
        </div>
      </div>
      <LazyFx name="phone" target="#app" />
    </section>
  );
}
