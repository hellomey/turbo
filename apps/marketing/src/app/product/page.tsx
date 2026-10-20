import type { Metadata } from "next";
import Link from "next/link";
import { PageIntro } from "@/components/PageIntro";
import { Feature } from "@/components/Feature";
import { GET_STARTED_URL } from "@/lib/site";

export const metadata: Metadata = {
  title: "Product",
  description: "Daily Flash, honest readiness, doubts in Tamil and English, revision and mock tests.",
};

export default function ProductPage() {
  return (
    <>
      <PageIntro
        eyebrow="Product"
        title={
          <>
            Everything points at one question: <em className="text-mint-300">where do you stand?</em>
          </>
        }
        lead="HeyMey is a daily companion, not a content dump. Each part exists to give you an honest answer and a next step."
      />
      <Feature id="daily-flash" eyebrow="Daily Flash" title="Ten questions. Five minutes. Every day.">
        <p>
          A fresh challenge each morning on a real five-minute timer. Everyone preparing for the same exam in your
          district gets the same set, so the leaderboard is fair.
        </p>
        <p>Answers are graded on our server, and every question shows its explanation afterwards.</p>
      </Feature>
      <Feature id="readiness" eyebrow="Readiness" title="One honest number, explained.">
        <p>
          Your readiness is built from what you actually practise: mastery, consistency, coverage and trend. It moves
          when you do, and it shows why it moved.
        </p>
        <p>When there is not enough data yet, it says so. No flattering guesses.</p>
      </Feature>
      <Feature id="doubts" eyebrow="Doubts" title="Ask in the language you think in.">
        <p>
          Type a doubt in Tamil or English and get an explanation straight away. Three doubts a day are free; after
          that, each costs two Sudars.
        </p>
        <p>Other aspirants can answer too, and helpful answers earn Sudars.</p>
      </Feature>
      <Feature id="revision" eyebrow="Revision" title="Bring back what is slipping.">
        <p>Topics you are starting to forget come back for revision before they are gone, based on spaced repetition.</p>
      </Feature>
      <Feature id="tests" eyebrow="Mock tests" title="Practise the real format.">
        <p>
          Start with a free diagnostic test. Full mock tests unlock with Sudars or Pro, and every result comes with a
          breakdown of your strongest and weakest topics.
        </p>
      </Feature>
      <Feature id="sudar" eyebrow="Sudar" title="A simple currency: one Sudar is one rupee.">
        <p>
          Earn Sudars by showing up (Flash Challenges, streaks, helpful answers) and spend them on extra doubts, tests
          and study material. No confusing exchange rates.
        </p>
      </Feature>
      <Feature id="for-creators" eyebrow="For Creators" title="Teachers and past clearers, earn from what you know.">
        <p>Upload notes and question sets; every upload passes a duplicate and quality check before students see it.</p>
        <p>
          <Link href="/creators" className="inline-flex min-h-11 items-center font-semibold text-mint-300 underline-offset-4 hover:underline">
            How creating on HeyMey works →
          </Link>
        </p>
      </Feature>
      <div className="mx-auto flex max-w-6xl justify-center px-5 pb-24 pt-10">
        <a
          href={GET_STARTED_URL}
          className="grad-border flex min-h-14 items-center rounded-full px-8 text-lg font-semibold text-black [--grad-fill:#fff]"
        >
          Get Started →
        </a>
      </div>
    </>
  );
}
