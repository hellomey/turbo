"use client";
import { useEffect, useState } from "react";

type NetworkInformation = { saveData?: boolean };

export function prefersReducedMotion(): boolean {
  return typeof window !== "undefined" && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
}

export function isCoarsePointer(): boolean {
  return typeof window !== "undefined" && window.matchMedia("(pointer: coarse)").matches;
}

/** Heavy effects (WebGL) are skipped for reduced motion, Save-Data, ≤4 GB devices, or no WebGL. */
export function shouldUseLightweightVisuals(): boolean {
  if (typeof window === "undefined") return true;
  if (prefersReducedMotion()) return true;
  const nav = navigator as Navigator & { connection?: NetworkInformation; deviceMemory?: number };
  if (nav.connection?.saveData) return true;
  if (typeof nav.deviceMemory === "number" && nav.deviceMemory <= 4) return true;
  try {
    const c = document.createElement("canvas");
    if (!(c.getContext("webgl2") || c.getContext("webgl"))) return true;
  } catch {
    return true;
  }
  return false;
}

/** Client-only boolean that is `false` during SSR and the first render. */
export function useClientFlag(read: () => boolean): boolean {
  const [value, setValue] = useState(false);
  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect -- syncing with browser-only APIs after hydration
    setValue(read());
  }, [read]);
  return value;
}
