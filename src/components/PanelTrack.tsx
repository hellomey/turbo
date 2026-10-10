import {
  useRef,
  useState,
  useEffect,
  type ReactNode,
  useCallback,
} from 'react';
import { useLocation } from 'react-router-dom';

interface PanelTrackProps {
  panelIds: string[];
  currentPanel: number;
  onPanelChange: (index: number) => void;
  ariaLabel?: string;
  children: ReactNode;
}

export const PanelTrack = ({
  panelIds,
  currentPanel,
  onPanelChange,
  ariaLabel = 'Interactive panels track',
  children,
}: PanelTrackProps) => {
  const containerRef = useRef<HTMLDivElement | null>(null);
  const location = useLocation();
  const [liveAnnouncement, setLiveAnnouncement] = useState('');
  const wheelAccumulator = useRef(0);
  const lastWheelTime = useRef(0);

  // Scroll container to active panel index
  const scrollToIndex = useCallback(
    (index: number, smooth = true) => {
      const container = containerRef.current;
      if (!container) return;
      const targetLeft = index * container.clientWidth;
      container.scrollTo({
        left: targetLeft,
        behavior: smooth ? 'smooth' : 'auto',
      });
      // Update hash without polluting browser history
      if (panelIds[index]) {
        window.history.replaceState(null, '', `#${panelIds[index]}`);
      }
      setLiveAnnouncement(`Panel ${index + 1} of ${panelIds.length}`);
    },
    [panelIds]
  );

  // Sync scroll on prop change
  useEffect(() => {
    scrollToIndex(currentPanel);
  }, [currentPanel, scrollToIndex]);

  // Deep-link hash handling on route enter
  useEffect(() => {
    if (location.hash) {
      const targetHash = location.hash.replace('#', '');
      const matchedIndex = panelIds.indexOf(targetHash);
      if (matchedIndex !== -1 && matchedIndex !== currentPanel) {
        onPanelChange(matchedIndex);
      }
    }
  }, [location.hash, panelIds, currentPanel, onPanelChange]);

  // Keyboard navigation: ArrowLeft, ArrowRight, PageUp, PageDown, Home, End
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Don't intercept if focus is inside an input, textarea, or select
      const activeEl = document.activeElement;
      if (
        activeEl &&
        (activeEl.tagName === 'INPUT' ||
          activeEl.tagName === 'TEXTAREA' ||
          activeEl.tagName === 'SELECT')
      ) {
        return;
      }

      if (e.key === 'ArrowRight' || e.key === 'PageDown') {
        if (currentPanel < panelIds.length - 1) {
          e.preventDefault();
          onPanelChange(currentPanel + 1);
        }
      } else if (e.key === 'ArrowLeft' || e.key === 'PageUp') {
        if (currentPanel > 0) {
          e.preventDefault();
          onPanelChange(currentPanel - 1);
        }
      } else if (e.key === 'Home') {
        e.preventDefault();
        onPanelChange(0);
      } else if (e.key === 'End') {
        e.preventDefault();
        onPanelChange(panelIds.length - 1);
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [currentPanel, panelIds.length, onPanelChange]);

  // Wheel conversion: convert deltaY to horizontal steps with debouncing
  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const handleWheel = (e: WheelEvent) => {
      // Never hijack if ctrlKey is pressed (browser zoom), or if pointer is over no-wheel element
      if (e.ctrlKey) return;
      const target = e.target as HTMLElement | null;
      if (
        target?.closest('input') ||
        target?.closest('textarea') ||
        target?.closest('select') ||
        target?.closest('[data-no-wheel]')
      ) {
        return;
      }

      // If predominantly horizontal delta, let native behavior proceed
      if (Math.abs(e.deltaX) > Math.abs(e.deltaY)) return;

      const now = Date.now();
      if (now - lastWheelTime.current < 600) return; // Debounce 600ms per spec §3.3

      wheelAccumulator.current += e.deltaY;
      const threshold = 40;

      if (wheelAccumulator.current > threshold) {
        if (currentPanel < panelIds.length - 1) {
          e.preventDefault();
          lastWheelTime.current = now;
          wheelAccumulator.current = 0;
          onPanelChange(currentPanel + 1);
        }
      } else if (wheelAccumulator.current < -threshold) {
        if (currentPanel > 0) {
          e.preventDefault();
          lastWheelTime.current = now;
          wheelAccumulator.current = 0;
          onPanelChange(currentPanel - 1);
        }
      }
    };

    container.addEventListener('wheel', handleWheel, { passive: false });
    return () => container.removeEventListener('wheel', handleWheel);
  }, [currentPanel, panelIds.length, onPanelChange]);

  // Handle native swipe / touch snap end
  const handleScroll = () => {
    const container = containerRef.current;
    if (!container) return;
    const width = container.clientWidth;
    if (width <= 0) return;
    const newIndex = Math.round(container.scrollLeft / width);
    if (newIndex !== currentPanel && newIndex >= 0 && newIndex < panelIds.length) {
      onPanelChange(newIndex);
      if (panelIds[newIndex]) {
        window.history.replaceState(null, '', `#${panelIds[newIndex]}`);
      }
    }
  };

  return (
    <>
      <div
        ref={containerRef}
        role="region"
        aria-roledescription="carousel"
        aria-label={ariaLabel}
        onScroll={handleScroll}
        className="panel-track-container"
      >
        {children}
      </div>

      {/* Screen Reader Live Announcement */}
      <div className="sr-only" aria-live="polite" aria-atomic="true">
        {liveAnnouncement}
      </div>
    </>
  );
};
