"use client";
// Stacking cards: each card is pinned (pinSpacing:false) as it reaches the top
// zone, so the next card slides over it; covered cards shrink and dim.
// (CSS position:sticky is unavailable here — see globals.css.) Without JS or
// with reduced motion the cards are a normal, readable list.
import { gsap, MQ, ScrollTrigger, useGSAP } from "@/lib/gsap";

export default function StackFx({ target }: { target: string }) {
  useGSAP(() => {
    const section = document.querySelector<HTMLElement>(target);
    if (!section) return;
    const cards = gsap.utils.toArray<HTMLElement>("[data-stack-card]", section);
    const last = cards[cards.length - 1];
    const top = (i: number) => Math.round(window.innerHeight * 0.14 + i * 22);
    const mm = gsap.matchMedia();
    mm.add(MQ.motion, () => {
      cards.forEach((card, i) => {
        if (card === last) return;
        ScrollTrigger.create({
          trigger: card,
          start: () => `top ${top(i)}px`,
          endTrigger: last,
          end: () => `top ${top(cards.length - 1)}px`,
          pin: true,
          pinSpacing: false,
          invalidateOnRefresh: true,
        });
        gsap.to(card, {
          scale: 0.92,
          filter: "brightness(0.55)",
          ease: "none",
          scrollTrigger: {
            trigger: cards[i + 1],
            start: "top bottom",
            end: () => `top ${top(i + 1)}px`,
            scrub: true,
            invalidateOnRefresh: true,
          },
        });
      });
    });
    return () => mm.revert();
  });
  return null;
}
