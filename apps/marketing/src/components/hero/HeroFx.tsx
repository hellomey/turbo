"use client";
// Scroll-linked parallax for the hero. The planet and stars are baked into one
// video layer (with sky.png as its poster), so they move together; the headline
// moves at a different rate. Disabled for reduced motion.
import type { RefObject } from "react";
import { gsap, MQ, useGSAP } from "@/lib/gsap";

export default function HeroFx({ sectionRef }: { sectionRef: RefObject<HTMLElement | null> }) {
  useGSAP(
    () => {
      const section = sectionRef.current;
      if (!section) return;
      const mm = gsap.matchMedia();
      mm.add(`(prefers-reduced-motion: no-preference) and ${MQ.desktop}`, () => {
        const video = section.querySelector<HTMLVideoElement>(".hero-video");
        const title = section.querySelector<HTMLElement>(".hero-title");
        const scrub = { trigger: section, start: "top top", end: "bottom top", scrub: true };
        if (video) {
          // Take over the CSS translateX(-50%) explicitly so the two never stack.
          gsap.set(video, { x: 0, xPercent: -50 });
          gsap.to(video, { yPercent: 10, ease: "none", scrollTrigger: scrub });
        }
        if (title) gsap.to(title, { y: -70, ease: "none", scrollTrigger: scrub });
      });
      mm.add(`(prefers-reduced-motion: no-preference) and ${MQ.mobile}`, () => {
        const video = section.querySelector<HTMLVideoElement>(".hero-video");
        const title = section.querySelector<HTMLElement>(".hero-title");
        const scrub = { trigger: section, start: "top top", end: "bottom top", scrub: true };
        if (video) {
          gsap.set(video, { x: 0, xPercent: -50 });
          gsap.to(video, { yPercent: 6, ease: "none", scrollTrigger: scrub });
        }
        if (title) gsap.to(title, { y: -25, ease: "none", scrollTrigger: scrub });
      });
      return () => mm.revert();
    },
    { scope: sectionRef }
  );
  return null;
}
