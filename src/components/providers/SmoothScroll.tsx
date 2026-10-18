"use client";
// Loaded lazily (ssr:false) by <Providers>. Lenis drives smooth scrolling and is
// stepped by GSAP's ticker so ScrollTrigger and Lenis never disagree.
import { useEffect } from "react";
import { usePathname } from "next/navigation";
import Lenis from "lenis";
import { gsap, ScrollTrigger } from "@/lib/gsap";
import { isCoarsePointer, prefersReducedMotion } from "@/lib/env";

let lenis: Lenis | null = null;

export default function SmoothScroll() {
  const pathname = usePathname();

  useEffect(() => {
    const refresh = () => ScrollTrigger.refresh();
    document.fonts?.ready.then(refresh);
    window.addEventListener("load", refresh);

    // Touch devices keep native scrolling; reduced motion gets no smoothing.
    if (prefersReducedMotion() || isCoarsePointer()) {
      return () => window.removeEventListener("load", refresh);
    }

    lenis = new Lenis({ autoRaf: false, anchors: true });
    lenis.on("scroll", ScrollTrigger.update);
    const tick = (time: number) => lenis?.raf(time * 1000);
    gsap.ticker.add(tick);
    gsap.ticker.lagSmoothing(0);

    const lock = () => lenis?.stop();
    const unlock = () => lenis?.start();
    const scrollTo = (e: Event) => {
      const y = (e as CustomEvent<{ y: number }>).detail?.y;
      if (typeof y !== "number" || !lenis) return;
      e.preventDefault();
      lenis.scrollTo(y, { immediate: true, force: true });
    };
    window.addEventListener("heymey:scroll-lock", lock);
    window.addEventListener("heymey:scroll-unlock", unlock);
    window.addEventListener("heymey:scroll-to", scrollTo);

    return () => {
      window.removeEventListener("load", refresh);
      window.removeEventListener("heymey:scroll-lock", lock);
      window.removeEventListener("heymey:scroll-unlock", unlock);
      window.removeEventListener("heymey:scroll-to", scrollTo);
      gsap.ticker.remove(tick);
      lenis?.destroy();
      lenis = null;
    };
  }, []);

  // New page → start at the top and recompute every trigger for the new layout.
  useEffect(() => {
    if (!window.location.hash) lenis?.scrollTo(0, { immediate: true });
    const id = requestAnimationFrame(() => ScrollTrigger.refresh());
    return () => cancelAnimationFrame(id);
  }, [pathname]);

  return null;
}
