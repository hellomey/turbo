"use client";
// GSAP registry. Import this ONLY from lazily loaded (next/dynamic, ssr:false)
// modules so GSAP and its plugins never land in the initial bundle.
// Licence: GSAP 3.13+ (incl. ScrollTrigger, SplitText) is free under the
// "Standard 'no charge' license" — https://gsap.com/standard-license (checked
// against the installed package's `license` field, gsap 3.15.0).
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { SplitText } from "gsap/SplitText";
import { useGSAP } from "@gsap/react";

gsap.registerPlugin(ScrollTrigger, SplitText, useGSAP);
// Mobile browser toolbars resize the viewport while scrolling; don't refresh for that.
ScrollTrigger.config({ ignoreMobileResize: true });

export const MQ = {
  motion: "(prefers-reduced-motion: no-preference)",
  reduce: "(prefers-reduced-motion: reduce)",
  desktop: "(min-width: 768px)",
  mobile: "(max-width: 767.98px)",
} as const;

export { gsap, ScrollTrigger, SplitText, useGSAP };
