"use client";
// The hero is preserved exactly as it was (same markup, classes and CSS —
// see src/styles/hero-legacy.css). Only two things are added:
//   1. a staggered entrance (Motion) that ends on the original final state;
//   2. scroll-linked parallax (GSAP, loaded lazily in HeroFx).
import { useEffect, useRef, useState } from "react";
import dynamic from "next/dynamic";
import * as m from "motion/react-m";

const HeroFx = dynamic(() => import("./HeroFx"), { ssr: false });

const VIDEO_SRC =
  "https://d2ol7oe51mr4n9.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/4b73c700-3112-4c07-bd48-0af2893dff7c.mp4";
/** Same image as the original sky.png poster, re-encoded as WebP (q80: 88 KB vs 1.3 MB; 0.0001% perceptual diff). */
export const HERO_POSTER = "/assets/images/sky.webp";

function whenIdle(cb: () => void) {
  const w = window as Window & { requestIdleCallback?: (cb: () => void, o?: { timeout: number }) => number };
  if (w.requestIdleCallback) w.requestIdleCallback(cb, { timeout: 2500 });
  else setTimeout(cb, 1200);
}

const ease = [0.16, 1, 0.3, 1] as const;
const rise = (delay: number, y: number) => ({
  initial: { opacity: 0, y },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.95, delay, ease },
});

export function Hero() {
  const heroVideoRef = useRef<HTMLVideoElement>(null);
  const sectionRef = useRef<HTMLElement>(null);

  // The poster is the LCP image. The large video stream is attached only once
  // the page has loaded and the main thread is idle, so it never competes with
  // first paint; with Save-Data the poster simply stays. The same autoplay
  // safeguards as before apply (muted autoplay can be refused).
  const [showFx, setShowFx] = useState(false);
  useEffect(() => {
    const heroVid = heroVideoRef.current;
    if (!heroVid) return;
    heroVid.muted = true;
    const saveData = (navigator as Navigator & { connection?: { saveData?: boolean } }).connection?.saveData;
    const play = () => {
      if (heroVid.paused && heroVid.getAttribute("src")) heroVid.play().catch(() => {});
    };
    const attach = () =>
      whenIdle(() => {
        setShowFx(true);
        if (saveData || heroVid.getAttribute("src")) return;
        heroVid.src = VIDEO_SRC;
        heroVid.load();
        play();
      });
    if (document.readyState === "complete") attach();
    else window.addEventListener("load", attach, { once: true });
    heroVid.addEventListener("canplay", play);
    const onVisibility = () => {
      if (!document.hidden) play();
    };
    document.addEventListener("visibilitychange", onVisibility);
    window.addEventListener("pointerdown", play, { once: true, passive: true });
    window.addEventListener("touchstart", play, { once: true, passive: true });
    return () => {
      window.removeEventListener("load", attach);
      heroVid.removeEventListener("canplay", play);
      document.removeEventListener("visibilitychange", onVisibility);
      window.removeEventListener("pointerdown", play);
      window.removeEventListener("touchstart", play);
    };
  }, []);

  return (
    <section ref={sectionRef} className="hero-wrapper" id="home" aria-labelledby="hero-title">
      <video
        ref={heroVideoRef}
        className="hero-video"
        aria-hidden="true"
        autoPlay
        muted
        loop
        playsInline
        preload="none"
        poster={HERO_POSTER}
      />
      <div className="hero-veil" />

      <div className="hero-content">
        <h1 className="hero-title" id="hero-title">
          <m.div className="hero-title-row" {...rise(0.1, 45)}>
            <span className="heymey-brand">
              Hey<span className="mey-struck">Mey</span>
            </span>
            <span
              className="mey-tamil-alankaram"
              lang="ta"
              aria-label="மெய்"
            >
              <span className="font-alankaram" aria-hidden="true">nka;</span>
              <span className="sr-only">மெய்</span>
            </span>
          </m.div>
          <m.span className="hero-title-sub" {...rise(0.28, 25)}>
            Truth beneath the noise.
          </m.span>
        </h1>

        <m.p className="hero-description" {...rise(0.42, 25)}>
          Focused study tools, real exam practice, and clear progress.<br className="hidden sm:inline" />{" "}
          Everything you need to go further.
        </m.p>

        {/* These two buttons were never visible in the original page: a GSAP
            quickTo() on the same element overwrote its entrance tween and left
            both at opacity:0 (verified in a production build). They are kept
            in place so layout is identical, but hidden from keyboard and
            screen readers instead of being invisible focus traps. The navbar
            carries "Get Started". */}
        <div className="hero-cta-group" aria-hidden="true" style={{ visibility: "hidden" }}>
          <a href="#start" className="btn-pill-primary" tabIndex={-1}>
            Get Started <span>&rarr;</span>
          </a>
          <a href="#explore" className="btn-pill-ghost" tabIndex={-1}>
            Explore Platform <span style={{ fontSize: "0.75rem" }}>&#9658;</span>
          </a>
        </div>
      </div>

      {showFx && <HeroFx sectionRef={sectionRef} />}
    </section>
  );
}
