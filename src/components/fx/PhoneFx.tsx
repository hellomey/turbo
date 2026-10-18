"use client";
// Pinned phone whose screens cross-fade as you scroll (scrubbed to progress).
// Without this enhancer (or with reduced motion) each step shows its own
// screenshot inline, so nothing is lost.
import { gsap, MQ, ScrollTrigger, useGSAP } from "@/lib/gsap";

export default function PhoneFx({ target }: { target: string }) {
  useGSAP(() => {
    const section = document.querySelector<HTMLElement>(target);
    if (!section) return;
    const mm = gsap.matchMedia();
    mm.add(MQ.motion, () => {
      section.dataset.fx = "on";
      const stage = section.querySelector<HTMLElement>(".ph-stage")!;
      const steps = gsap.utils.toArray<HTMLElement>("[data-ph-step]", section);
      const screens = gsap.utils.toArray<HTMLElement>("[data-ph-screen]", section);
      gsap.set(steps, { opacity: 0, y: 24 });
      gsap.set(steps[0], { opacity: 1, y: 0 });
      gsap.set(screens, { opacity: 0, scale: 1.04 });
      gsap.set(screens[0], { opacity: 1, scale: 1 });

      const tl = gsap.timeline({
        defaults: { ease: "power1.inOut", duration: 0.28 },
        scrollTrigger: {
          trigger: stage,
          pin: true,
          scrub: 0.6,
          start: "top top",
          end: () => "+=" + window.innerHeight * steps.length * 0.9,
          invalidateOnRefresh: true,
        },
      });
      for (let i = 1; i < steps.length; i++) {
        const at = i - 0.14; // quick hand-over at each step boundary, holds in between
        tl.to(steps[i - 1], { opacity: 0, y: -24 }, at)
          .to(screens[i - 1], { opacity: 0, scale: 0.98 }, at)
          .to(steps[i], { opacity: 1, y: 0 }, at)
          .to(screens[i], { opacity: 1, scale: 1 }, at);
      }
      tl.to({}, { duration: 0.6 });
      ScrollTrigger.refresh();
      return () => {
        delete section.dataset.fx;
      };
    });
    return () => mm.revert();
  });
  return null;
}
