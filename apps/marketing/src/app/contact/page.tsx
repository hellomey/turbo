import type { Metadata } from "next";
import { PageIntro } from "@/components/PageIntro";
import { LeadForm } from "@/components/LeadForm";

export const metadata: Metadata = { title: "Contact", description: "Join the HeyMey beta, ask a question, or bring HeyMey to your institution." };

export default function ContactPage() {
  return (
    <>
      <PageIntro
        eyebrow="Contact"
        title={
          <>
            Talk to a <em className="text-mint-300">person</em>.
          </>
        }
        lead="Join the closed beta, ask a question, or tell us about your coaching centre. Every message is read."
      />
      <section aria-label="Contact form" className="mx-auto max-w-3xl px-5 pb-24 sm:px-8">
        <LeadForm />
      </section>
    </>
  );
}
