"use client";
import dynamic from "next/dynamic";
import { LazyMotion, MotionConfig } from "motion/react";

// Components use the lightweight `m` API; the full feature set loads right after hydration.
const loadFeatures = () => import("@/lib/motion-features").then((mod) => mod.default);

// GSAP + Lenis load after hydration, outside the initial bundle.
const SmoothScroll = dynamic(() => import("./SmoothScroll"), { ssr: false });

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    // "user": Motion honours prefers-reduced-motion (no transform/layout motion).
    <LazyMotion features={loadFeatures} strict>
      <MotionConfig reducedMotion="user">
        <SmoothScroll />
        {children}
      </MotionConfig>
    </LazyMotion>
  );
}
