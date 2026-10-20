"use client";
// The Kural reveals word by word on scroll; மெய்ப்பொருள் lights up last-but-one
// with the hero badge's glow. Words are pre-rendered React spans to prevent
// DOM mutation and React 'removeChild' reconciliation errors.
import { gsap, MQ, useGSAP } from "@/lib/gsap";

export default function KuralFx({ target }: { target: string }) {
  useGSAP(() => {
    const section = document.querySelector<HTMLElement>(target);
    const text = section?.querySelector<HTMLElement>("[data-kural]");
    if (!section || !text) return;
    const words = gsap.utils.toArray<HTMLElement>(".kural-word", section);
    if (!words.length) return;

    const mm = gsap.matchMedia();
    mm.add(MQ.motion, () => {
      const mey = section.querySelector<HTMLElement>("[data-mey]");
      const tl = gsap.timeline({ scrollTrigger: { trigger: text, start: "top bottom", end: "bottom 40%", scrub: 0.6 } });
      tl.fromTo(words, { opacity: 0.1, y: 18 }, { opacity: 1, y: 0, stagger: 0.25, ease: "power1.out", immediateRender: false });
      if (mey) tl.fromTo(mey, { boxShadow: "0 0 0 rgba(0,0,0,0)" }, { boxShadow: "0 0 24px rgba(93,243,190,0.55), 0 0 60px rgba(168,85,247,0.4)", duration: 0.6 }, "-=0.6");
    });
    return () => mm.revert();
  });
  return null;
}

