"use client";
// Clip-path wipe for each principle and a gradient line drawn beneath it.
import { gsap, MQ, useGSAP } from "@/lib/gsap";

export default function TrustFx({ target }: { target: string }) {
  useGSAP(() => {
    const section = document.querySelector<HTMLElement>(target);
    if (!section) return;
    const mm = gsap.matchMedia();
    mm.add(MQ.motion, () => {
      gsap.utils.toArray<HTMLElement>("[data-trust-row]", section).forEach((row) => {
        const reveal = row.querySelector("[data-trust-reveal]");
        const line = row.querySelector("[data-trust-line]");
        const tl = gsap.timeline({ scrollTrigger: { trigger: row, start: "top 85%", end: "top 45%", scrub: 0.5 } });
        if (line) tl.fromTo(line, { strokeDasharray: 1, strokeDashoffset: 1 }, { strokeDashoffset: 0, ease: "none" }, 0);
        if (reveal)
          tl.fromTo(
            reveal,
            { clipPath: "inset(0% 100% 0% 0%)", opacity: 0.3 },
            { clipPath: "inset(0% 0% 0% 0%)", opacity: 1, ease: "power2.out" },
            0
          );
      });
    });
    return () => mm.revert();
  });
  return null;
}
