import { useEffect, useRef, useState } from 'react';

interface VideoBackgroundProps {
  isPaused?: boolean;
  route?: string;
}

export const VideoBackground = ({ isPaused = false, route = '/' }: VideoBackgroundProps) => {
  const videoRef = useRef<HTMLVideoElement | null>(null);
  const [isVideoLoaded, setIsVideoLoaded] = useState(false);

  // Check if reading route (no video on legal or article reader per spec §4.2)
  const isReaderRoute = route.startsWith('/legal') || (route.startsWith('/journal/') && route !== '/journal');

  useEffect(() => {
    if (isReaderRoute) return;

    const video = videoRef.current;
    if (!video) return;

    // Respect reduced motion preference
    const prefersReducedMotion = window.matchMedia(
      '(prefers-reduced-motion: reduce)'
    ).matches;

    // Check data saver or slow connection per spec §4.5
    const nav = navigator as unknown as {
      connection?: { saveData?: boolean; effectiveType?: string };
      deviceMemory?: number;
    };
    const isSaveData = nav.connection?.saveData === true;
    const isSlowConnection =
      nav.connection?.effectiveType === 'slow-2g' ||
      nav.connection?.effectiveType === '2g';
    const isLowMemory = (nav.deviceMemory ?? 4) <= 2;

    if (prefersReducedMotion || isSaveData || isSlowConnection || isLowMemory || isPaused) {
      video.pause();
      return;
    }

    // Attempt video playback
    video.play().catch((err) => {
      console.warn('Autoplay restricted by browser policy:', err);
    });

    const handleLoadedData = () => {
      setIsVideoLoaded(true);
    };

    const handlePlaying = () => {
      setIsVideoLoaded(true);
    };

    // Auto-resume playback when user switches back to this tab
    const handleVisibilityChange = () => {
      if (
        document.visibilityState === 'visible' &&
        !prefersReducedMotion &&
        !isPaused
      ) {
        if (video.paused) {
          video.play().catch(() => {});
        }
      }
    };

    // Seamless loop guarantee
    const handleEnded = () => {
      video.currentTime = 0;
      video.play().catch(() => {});
    };

    video.addEventListener('loadeddata', handleLoadedData);
    video.addEventListener('playing', handlePlaying);
    video.addEventListener('ended', handleEnded);
    document.addEventListener('visibilitychange', handleVisibilityChange);

    return () => {
      video.removeEventListener('loadeddata', handleLoadedData);
      video.removeEventListener('playing', handlePlaying);
      video.removeEventListener('ended', handleEnded);
      document.removeEventListener('visibilitychange', handleVisibilityChange);
    };
  }, [isPaused, isReaderRoute]);

  // Handle explicit pause toggle prop change
  useEffect(() => {
    const video = videoRef.current;
    if (!video) return;

    if (isPaused) {
      video.pause();
    } else {
      video.play().catch(() => {});
    }
  }, [isPaused]);

  if (isReaderRoute) {
    // Spec §4.2: Calm static gradient with fine grain. No video.
    return (
      <div
        id="reader-background"
        className="absolute inset-0 w-full h-full bg-[#FAF7F2] pointer-events-none select-none z-0"
        aria-hidden="true"
      />
    );
  }

  return (
    <div
      id="video-background-container"
      className="absolute inset-0 w-full h-full overflow-hidden z-0 select-none pointer-events-none"
      aria-hidden="true"
    >
      {/* 1. High-Performance Poster Layer with subtle ambient drift when paused */}
      <picture className="absolute inset-0 w-full h-full">
        <source srcSet="/poster.webp" type="image/webp" />
        <img
          src="/poster.jpg"
          alt="Panoramic Tamil Nadu Coastline Sunset"
          className={`w-full h-full object-cover object-[35%_55%] sm:object-[42%_55%] md:object-[48%_60%] lg:object-[50%_65%] xl:object-[50%_68%] ${
            isPaused ? 'animate-ambient-drift' : ''
          }`}
          style={{
            filter: 'contrast(1.02) saturate(1.03)',
          }}
          loading="eager"
          decoding="async"
        />
      </picture>

      {/* 2. Responsive Video Element with Multi-Format Support */}
      <video
        ref={videoRef}
        id="hero-background-video"
        poster="/poster.webp"
        muted
        playsInline
        autoPlay
        loop
        preload="auto"
        className={`w-full h-full object-cover object-[35%_55%] sm:object-[42%_55%] md:object-[48%_60%] lg:object-[50%_65%] xl:object-[50%_68%] transition-opacity duration-1000 ease-out ${
          isVideoLoaded && !isPaused ? 'opacity-100' : 'opacity-0'
        }`}
        style={{
          willChange: 'opacity, transform',
          filter: 'contrast(1.02) saturate(1.03)',
        }}
      >
        <source src="/video.webm" type="video/webm" />
        <source src="/video.mp4" type="video/mp4" />
      </video>

      {/* 3. Multi-Layer Atmospheric Scrims & Color Grading */}
      {/* Top Header Scrim: Keeps navbar and logo crisp across all device screens */}
      <div
        id="video-header-scrim"
        className="absolute top-0 inset-x-0 h-40 sm:h-52 bg-gradient-to-b from-[#FAF7F2]/95 via-[#FAF7F2]/65 to-transparent pointer-events-none"
      />

      {/* Center Atmospheric Halo: Softens vivid sunset behind hero typography */}
      <div
        id="video-center-glow"
        className="absolute inset-0 bg-gradient-to-b from-[#FAF7F2]/40 via-transparent to-[#FAF7F2]/20 sm:via-transparent pointer-events-none"
      />

      {/* Bottom Cinematic Depth Scrim */}
      <div
        id="video-bottom-vignette"
        className="absolute bottom-0 inset-x-0 h-36 sm:h-48 bg-gradient-to-t from-black/25 via-black/10 to-transparent pointer-events-none"
      />
    </div>
  );
};
