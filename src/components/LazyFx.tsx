"use client";
// Mounts a section's GSAP enhancer in its own lazy chunk, and only once the
// section comes within about one viewport of the screen. Sections stay
// server-rendered (all text in the DOM at load); only animation code waits.
import dynamic from "next/dynamic";
import { useEffect, useState } from "react";

const registry = {
  why: dynamic(() => import("./fx/WhyFx"), { ssr: false }),
  landscape: dynamic(() => import("./fx/LandscapeFx"), { ssr: false }),
  stack: dynamic(() => import("./fx/StackFx"), { ssr: false }),
  phone: dynamic(() => import("./fx/PhoneFx"), { ssr: false }),
  trust: dynamic(() => import("./fx/TrustFx"), { ssr: false }),
  kural: dynamic(() => import("./fx/KuralFx"), { ssr: false }),
} as const;

export function LazyFx({ name, target }: { name: keyof typeof registry; target: string }) {
  const [near, setNear] = useState(false);
  useEffect(() => {
    const el = document.querySelector(target);
    if (!el) return;
    const io = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setNear(true);
          io.disconnect();
        }
      },
      { rootMargin: "120% 0px 120% 0px" }
    );
    io.observe(el);
    return () => io.disconnect();
  }, [target]);
  const Fx = registry[name];
  return near ? <Fx target={target} /> : null;
}
