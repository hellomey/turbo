"use client";
// gsap.com-style horizontal scroll: pinned viewport, panels translated with
// xPercent and scrubbed to vertical scroll, a progress line, and per-panel
// inner parallax via containerAnimation.
//   ≥768px + motion allowed → pinned track
//   <768px + motion allowed → stacked cards, reveal on enter
//   reduced motion         → stacked cards, final state, nothing animates
import { gsap, MQ, ScrollTrigger, useGSAP } from "@/lib/gsap";

export default function LandscapeFx({ target }: { target: string }) {
  useGSAP(() => {
    const section = document.querySelector<HTMLElement>(target);
    if (!section) return;
    const viewport = section.querySelector<HTMLElement>(".ls-viewport")!;
    const panels = gsap.utils.toArray<HTMLElement>("[data-panel]", section);
    const bar = section.querySelector<HTMLElement>(".ls-progress > span");
    const mm = gsap.matchMedia();

    mm.add(`${MQ.desktop} and ${MQ.motion}`, () => {
      section.dataset.fx = "pinned";
      const distance = () => (panels.length - 1) * window.innerWidth;
      const track = gsap.to(panels, {
        xPercent: -100 * (panels.length - 1),
        ease: "none",
        scrollTrigger: {
          trigger: viewport,
          pin: true,
          scrub: 0.8,
          end: () => "+=" + distance(),
          invalidateOnRefresh: true,
          onUpdate: (st) => bar && gsap.set(bar, { scaleX: st.progress }),
        },
      });

      panels.forEach((panel) => {
        const art = panel.querySelector("[data-parallax]");
        if (!art) return;
        gsap.fromTo(
          art,
          { xPercent: 18 },
          {
            xPercent: -18,
            ease: "none",
            scrollTrigger: { trigger: panel, containerAnimation: track, start: "left right", end: "right left", scrub: true },
          }
        );
      });

      // Keyboard: focusing something inside a panel scrolls that panel into view.
      const st = track.scrollTrigger!;
      const onFocus = (e: FocusEvent) => {
        const i = panels.findIndex((p) => p.contains(e.target as Node));
        if (i < 0) return;
        const y = st.start + (st.end - st.start) * (i / (panels.length - 1));
        viewport.scrollLeft = 0;
        // Let Lenis move (and stay in sync) when it is active; otherwise scroll natively.
        const ev = new CustomEvent("heymey:scroll-to", { detail: { y }, cancelable: true });
        window.dispatchEvent(ev);
        if (!ev.defaultPrevented) window.scrollTo({ top: y, behavior: "auto" });
      };
      section.addEventListener("focusin", onFocus);
      ScrollTrigger.refresh();

      return () => {
        section.removeEventListener("focusin", onFocus);
        delete section.dataset.fx;
      };
    });

    mm.add(`${MQ.mobile} and ${MQ.motion}`, () => {
      panels.forEach((panel) => {
        gsap.from(panel, {
          opacity: 0,
          y: 48,
          duration: 0.9,
          ease: "power3.out",
          scrollTrigger: { trigger: panel, start: "top 88%", toggleActions: "play none none none" },
        });
      });
    });

    return () => mm.revert();
  });
  return null;
}
