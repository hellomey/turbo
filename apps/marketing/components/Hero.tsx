"use client";

import React, { useEffect, useRef } from "react";

const HERO_VIDEO =
  "https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20261021_093331_5998f443-1b9c-4b62-820c-8219c73c72c4.mp4";
const HERO_POSTER =
  "https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20261021_093215_b7826239-e451-4e15-b42b-d6bcf9497a32.png";
const CLOUD_A =
  "https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20261021_093216_44218665-b15e-4566-a2d4-2676ab03609d.png";
const CLOUD_B =
  "https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20261021_093215_0f37c0c3-f82c-485b-87dd-5a35b75a8782.png";

export default function Hero() {
  const videoRef = useRef<HTMLVideoElement>(null);

  useEffect(() => {
    const video = videoRef.current;
    if (!video) return;

    // Ensure video properties satisfy browser autoplay policies
    video.muted = true;
    video.defaultMuted = true;
    video.setAttribute("playsinline", "true");
    video.setAttribute("webkit-playsinline", "true");

    const playVideo = () => {
      if (video.paused) {
        video.play().catch(() => { });
      }
    };

    playVideo();

    // Fallback listeners to trigger play on first interaction if blocked
    const handleInteraction = () => {
      playVideo();
      window.removeEventListener("scroll", handleInteraction);
      window.removeEventListener("touchstart", handleInteraction);
      window.removeEventListener("click", handleInteraction);
    };

    window.addEventListener("scroll", handleInteraction, { passive: true, once: true });
    window.addEventListener("touchstart", handleInteraction, { passive: true, once: true });
    window.addEventListener("click", handleInteraction, { once: true });

    return () => {
      window.removeEventListener("scroll", handleInteraction);
      window.removeEventListener("touchstart", handleInteraction);
      window.removeEventListener("click", handleInteraction);
    };
  }, []);

  return (
    <section className="hero" id="hero">

      {/* Cloud Left - Drifting cumulus cloud over top-left corner */}
      <div className="cloud cloud-l" data-par="-60">
        <img
          className="drift-a"
          src={CLOUD_A}
          alt="Drifting pink sunset cloud"
          loading="eager"
          decoding="async"
        />
      </div>

      {/* Cloud Right - Drifting cumulus cloud over top-right corner */}
      <div className="cloud cloud-r" data-par="-90">
        <img
          className="drift-b"
          src={CLOUD_B}
          alt="Drifting pink sunset cloud"
          loading="eager"
          decoding="async"
        />
      </div>

      {/* Hero Headline - Centered in open sky with GSAP word blur reveal */}
      <h1 id="heroTitle" className="split">
        You don’t have to<br />
        start from <em>scratch.</em>
      </h1>

      {/* Hero Media Video with sky gradient mask - river, petals & birds moving */}
      <div className="hero-media">
        <video
          ref={videoRef}
          id="heroVideo"
          autoPlay
          muted
          loop
          playsInline
          preload="auto"
          poster={HERO_POSTER}
          src={HERO_VIDEO}
        />
      </div>

      {/* Frosted Glass Floating Squares */}
      <div className="hero-glass" id="heroGlass" />
    </section>
  );
}
