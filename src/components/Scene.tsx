import { useState, useEffect, type ReactNode } from 'react';
import { useLocation } from 'react-router-dom';
import { Navbar } from './Navbar';
import { VideoBackground } from './VideoBackground';
import { EdgeBar } from './EdgeBar';

interface SceneProps {
  panelCount?: number;
  currentPanel?: number;
  onPanelChange?: (index: number) => void;
  children: ReactNode;
}

export const Scene = ({
  panelCount = 1,
  currentPanel = 0,
  onPanelChange,
  children,
}: SceneProps) => {
  const location = useLocation();
  const isHome = location.pathname === '/';

  // Persist pause choice in localStorage per spec §3.4 and §4.5
  const [isPaused, setIsPaused] = useState<boolean>(() => {
    return localStorage.getItem('heymey_bg_paused') === 'true';
  });

  const togglePause = () => {
    setIsPaused((prev) => {
      const next = !prev;
      localStorage.setItem('heymey_bg_paused', String(next));
      return next;
    });
  };

  // Sync title and meta per route if needed
  useEffect(() => {
    window.scrollTo(0, 0);
  }, [location.pathname]);

  return (
    <div className="relative w-screen h-[100dvh] overflow-hidden bg-[#FAF7F2] flex flex-col justify-between selection:bg-neutral-900 selection:text-white">
      {/* Background layer */}
      <VideoBackground isPaused={isPaused} route={location.pathname} />

      {/* Top Navbar */}
      <Navbar />

      {/* Main viewport content */}
      <main className="relative z-10 w-full h-full flex-1 flex flex-col items-center justify-center overflow-hidden">
        {children}
      </main>

      {/* Bottom EdgeBar on every page except Home per spec §2.4 */}
      {!isHome && (
        <EdgeBar
          panelCount={panelCount}
          currentPanel={currentPanel}
          onPanelChange={onPanelChange}
          isPaused={isPaused}
          onTogglePause={togglePause}
        />
      )}
    </div>
  );
};
