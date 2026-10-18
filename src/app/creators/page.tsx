import type { Metadata } from "next";
import Link from "next/link";
import { PageIntro } from "@/components/PageIntro";
import { Feature } from "@/components/Feature";

export const metadata: Metadata = {
  title: "For Creators",
  description: "Teachers, retired officers and past clearers: publish study material and earn 75% of every sale.",
};

export default function CreatorsPage() {
  return (
    <>
      <PageIntro
        eyebrow="For Creators"
        title={
          <>
            Your notes deserve <em className="text-mint-300">honest</em> readers.
          </>
        }
        lead="Teachers, retired officers and people who have cleared the exam: publish what you know and earn from it."
      />
      <Feature eyebrow="Earnings" title="You keep 75% of every sale.">
        <p>Material is sold in Sudars. Creators receive 75%; HeyMey keeps 25% to run the platform.</p>
      </Feature>
      <Feature eyebrow="Quality" title="Checked before students see it.">
        <p>Every upload goes through a duplicate check and a quality review, then admin approval, before it appears in the marketplace.</p>
      </Feature>
      <Feature eyebrow="Getting started" title="Creator accounts are set up with us.">
        <p>
          Creator onboarding is handled personally during the beta.{" "}
          <Link href="/contact" className="font-semibold text-mint-300 underline underline-offset-4">
            Get in touch
          </Link>{" "}
          and tell us what you would like to publish.
        </p>
      </Feature>
      <div className="pb-16" />
    </>
  );
}
