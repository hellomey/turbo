"use client";
// Final call to action. WebGL scene (lazy, ssr:false) behind; CSS stars and a
// glow instead when reduced motion, Save-Data, ≤4 GB memory or no WebGL.
// Magnetic buttons use Motion springs (pointer devices only).
import dynamic from "next/dynamic";
import Link from "next/link";
import { useCallback, useEffect, useRef, useState } from "react";
import { useMotionValue, useSpring } from "motion/react";
import * as m from "motion/react-m";
import { GET_STARTED_URL } from "@/lib/site";
import { isCoarsePointer, prefersReducedMotion, shouldUseLightweightVisuals } from "@/lib/env";

const CtaScene = dynamic(() => import("@/components/three/CtaScene"), { ssr: false });

export function FinalCta() {
  const sectionRef = useRef<HTMLElement>(null);
  const [useWebGL, setUseWebGL] = useState(false);
  const [onScreen, setOnScreen] = useState(false);
  const [seen, setSeen] = useState(false);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect -- browser capability check after hydration
    setUseWebGL(!shouldUseLightweightVisuals());
  }, []);

  // Render (and even load) the scene only while the section is near the viewport.
  useEffect(() => {
    const el = sectionRef.current;
    if (!el) return;
    const io = new IntersectionObserver(
      ([e]) => {
        setOnScreen(e.isIntersecting);
        if (e.isIntersecting) setSeen(true);
      },
      { rootMargin: "25% 0px" }
    );
    io.observe(el);
    return () => io.disconnect();
  }, []);

  return (
    <section
      ref={sectionRef}
      id="begin"
      aria-labelledby="begin-title"
      className="relative isolate flex min-h-[100svh] items-center justify-center overflow-hidden px-5 py-24 text-center sm:px-8"
    >
      <div aria-hidden className="css-stars absolute inset-0 -z-20 opacity-70" />
      <div
        aria-hidden
        className="absolute left-1/2 top-1/2 -z-10 aspect-square w-[min(110vw,1100px)] -translate-x-1/2 -translate-y-1/2 rounded-full bg-[radial-gradient(circle,rgba(80,45,217,0.45),rgba(56,28,134,0.25)_40%,transparent_68%)]"
      />
      {useWebGL && seen && (
        <div aria-hidden className="absolute inset-0 -z-10">
          <CtaScene active={onScreen} sectionRef={sectionRef} />
        </div>
      )}

      <div className="relative max-w-4xl">
        <p className="t-eyebrow">Begin</p>
        <h2 id="begin-title" className="t-display mt-5 text-balance">
          Find out where you <em className="text-mint-300">truly</em> stand.
        </h2>
        <p className="t-lead mx-auto mt-6 max-w-xl">
          Start with today&apos;s Flash Challenge. Five minutes, and you will know more than you did this morning.
        </p>
        <div className="mt-10 flex flex-wrap items-center justify-center gap-4">
          <Magnetic>
            <a
              href={GET_STARTED_URL}
              className="grad-border flex min-h-14 items-center gap-2 rounded-full px-8 text-lg font-semibold text-black shadow-[0_0_40px_rgba(93,243,190,0.35)] [--grad-fill:#fff]"
            >
              Get Started <span aria-hidden>→</span>
            </a>
          </Magnetic>
          <Magnetic>
            <Link
              href="/pricing"
              className="flex min-h-14 items-center rounded-full border border-white/25 px-8 text-lg font-semibold text-white transition-colors hover:border-mint-400/60"
            >
              See pricing
            </Link>
          </Magnetic>
        </div>
      </div>
    </section>
  );
}

function Magnetic({ children }: { children: React.ReactNode }) {
  const x = useMotionValue(0);
  const y = useMotionValue(0);
  const sx = useSpring(x, { stiffness: 220, damping: 18, mass: 0.4 });
  const sy = useSpring(y, { stiffness: 220, damping: 18, mass: 0.4 });
  const enabled = useRef(false);
  useEffect(() => {
    enabled.current = !isCoarsePointer() && !prefersReducedMotion();
  }, []);
  const onMove = useCallback(
    (e: React.PointerEvent<HTMLDivElement>) => {
      if (!enabled.current) return;
      const r = e.currentTarget.getBoundingClientRect();
      x.set((e.clientX - (r.left + r.width / 2)) * 0.3);
      y.set((e.clientY - (r.top + r.height / 2)) * 0.3);
    },
    [x, y]
  );
  const reset = () => {
    x.set(0);
    y.set(0);
  };
  return (
    <m.div style={{ x: sx, y: sy }} onPointerMove={onMove} onPointerLeave={reset} whileTap={{ scale: 0.97 }}>
      {children}
    </m.div>
  );
}
