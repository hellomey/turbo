import { useEffect, type ReactNode } from 'react';
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

  useEffect(() => {
    window.scrollTo(0, 0);
  }, [location.pathname]);

  return (
    <div className="relative w-screen h-[100dvh] overflow-hidden bg-[#FAF7F2] flex flex-col justify-between selection:bg-neutral-900 selection:text-white">
      {/* Background video ONLY for home screen root route alone per user requirement */}
      {isHome && <VideoBackground />}

      {/* Top Navigation Bar */}
      <Navbar />

      {/* Main viewport content */}
      <main className="relative z-10 w-full h-full flex-1 flex flex-col items-center justify-center overflow-hidden">
        {children}
      </main>

      {/* Bottom EdgeBar on every page except Home */}
      {!isHome && (
        <EdgeBar
          panelCount={panelCount}
          currentPanel={currentPanel}
          onPanelChange={onPanelChange}
        />
      )}
    </div>
  );
};
