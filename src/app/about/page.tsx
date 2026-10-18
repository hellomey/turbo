import type { Metadata } from "next";
import { PageIntro } from "@/components/PageIntro";
import { LazyFx } from "@/components/LazyFx";

export const metadata: Metadata = { title: "About", description: "HeyMey takes its name from மெய் — truth. The idea comes from Thirukkural 423." };

export default function AboutPage() {
  return (
    <>
      <PageIntro
        eyebrow="About HeyMey"
        title={
          <>
            Named for <span lang="ta" className="font-[family-name:var(--font-tamil)] text-mint-300">மெய்</span>: the
            truth beneath the noise.
          </>
        }
        lead="Aspirants are surrounded by forwards, rumours and confident guesses. HeyMey exists to show you the real picture, every day, gently."
      />

      {/* Centrepiece: Thirukkural 423 */}
      <section id="kural" aria-labelledby="kural-title" className="relative px-5 py-[clamp(4rem,14svh,10rem)] sm:px-8">
        <h2 id="kural-title" className="visually-hidden">
          Thirukkural 423
        </h2>
        <figure className="mx-auto max-w-6xl">
          <blockquote>
            <p
              lang="ta"
              data-kural
              className="font-[family-name:var(--font-tamil)] text-[clamp(0.75rem,3.4vw,2.45rem)] font-bold leading-[1.6] tracking-[-0.01em] text-white"
            >
              <span className="block whitespace-nowrap">
                <span className="kural-word inline-block mr-[0.25em]">எப்பொருள்</span>
                <span className="kural-word inline-block mr-[0.25em]">யார்யார்வாய்க்</span>
                <span className="kural-word inline-block mr-[0.25em]">கேட்பினும்</span>
                <span className="kural-word inline-block">அப்பொருள்</span>
              </span>
              <span className="mt-3 block whitespace-nowrap sm:mt-5">
                <span
                  data-mey
                  className="kural-word mey-echo inline-block rounded-2xl px-[0.25em] mr-[0.25em] align-baseline"
                >
                  மெய்ப்பொருள்
                </span>
                <span className="kural-word inline-block mr-[0.25em]">காண்ப</span>
                <span className="kural-word inline-block">தறிவு</span>
              </span>
            </p>
            <p className="t-lead mt-10 max-w-3xl font-[family-name:var(--font-display)] text-[clamp(1.25rem,1rem+1.2vw,2rem)] italic text-white/85">
              “Though things diverse from divers sages&apos; lips we learn, &rsquo;tis wisdom&apos;s part in each the true
              thing to discern.”
            </p>
          </blockquote>
          <figcaption className="mt-6 text-sm text-ink-3">
            <span lang="ta">Thirukkural 423, அறிவுடைமை</span> · English translation by G. U. Pope
          </figcaption>
        </figure>
        <LazyFx name="kural" target="#kural" />
      </section>

      <section aria-labelledby="name-title" className="px-5 pb-[clamp(5rem,14svh,9rem)] sm:px-8">
        <div className="mx-auto grid max-w-6xl gap-12 md:grid-cols-2">
          <div>
            <h2 id="name-title" className="t-h2 text-balance">Why the name.</h2>
          </div>
          <div className="space-y-6">
            <p className="t-lead">
              In the Kural above, <span lang="ta" className="font-[family-name:var(--font-tamil)] text-white">மெய்ப்பொருள்</span> is
              the true substance of a thing. Wisdom, Valluvar says, is finding it, no matter who is speaking.
            </p>
            <p className="t-lead">
              Tamil grammar gives the word a second meaning. Tolkāppiyam divides letters into <em>uyir</em> (உயிர், life:
              the vowels) and <em>mey</em> (மெய், body: the consonants). Only together do they make spoken language. Curiosity
              needs structure before it becomes understanding.
            </p>
            <p className="t-lead">
              That is the whole idea behind HeyMey: show every aspirant, honestly and daily, where they stand and what to do
              next.
            </p>
          </div>
        </div>
      </section>
    </>
  );
}
