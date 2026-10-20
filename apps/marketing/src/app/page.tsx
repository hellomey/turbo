import { Hero, HERO_POSTER } from "@/components/hero/Hero";
import { Why } from "@/components/home/Why";
import { Landscape } from "@/components/home/Landscape";
import { CardStack } from "@/components/home/CardStack";
import { PhoneSequence } from "@/components/home/PhoneSequence";
import { Counters } from "@/components/home/Counters";
import { TrustPrinciples } from "@/components/home/TrustPrinciples";
import { FinalCta } from "@/components/home/FinalCta";

export default function Home() {
  return (
    <>
      {/* The hero poster is the LCP image: fetch it first, at high priority (hoisted into <head>). */}
      <link rel="preload" as="image" href={HERO_POSTER} fetchPriority="high" />
      {/* Keeps the hero exactly where it sat under the old in-flow header, to the
          sub-pixel (66.375px above 1024px wide, 64.5625px at or below);
          the floating navbar now sits over this band. */}
      <div aria-hidden className="h-[64.5625px] min-[1025px]:h-[66.375px]" />
      <Hero />
      <Why />
      <Landscape />
      <CardStack />
      <PhoneSequence />
      <Counters />
      <TrustPrinciples />
      <FinalCta />
    </>
  );
}
