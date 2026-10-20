"use client";
// Word-by-word scroll reveal without DOM-mutating SplitText.
// Words are pre-rendered as React elements with .why-word to avoid React reconciliation conflicts.
import { gsap, MQ, useGSAP } from "@/lib/gsap";

export default function WhyFx({ target }: { target: string }) {
  useGSAP(() => {
    const section = document.querySelector<HTMLElement>(target);
    const text = section?.querySelector<HTMLElement>("[data-why-text]");
    if (!section || !text) return;
    const words = gsap.utils.toArray<HTMLElement>(".why-word", section);
    if (!words.length) return;
    const accentWords = words.filter((w) => w.hasAttribute("data-accent"));

    const mm = gsap.matchMedia();
    mm.add(MQ.motion, () => {
      const tl = gsap.timeline({
        scrollTrigger: { trigger: text, start: "top bottom", end: "bottom 45%", scrub: 0.6 },
      });
      tl.fromTo(words, { opacity: 0.14 }, { opacity: 1, stagger: 0.1, ease: "none", immediateRender: false }, 0);
      accentWords.forEach((w) => {
        const at = (words.indexOf(w) * 0.1) as number;
        tl.fromTo(
          w,
          { color: "#ffffff" },
          { color: "#b1f0cf", textShadow: "0 0 28px rgba(93,243,190,0.45)", duration: 0.3, ease: "none", immediateRender: false },
          at
        );
      });
    });
    return () => mm.revert();
  });
  return null;
}

