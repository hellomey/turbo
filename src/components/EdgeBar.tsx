import { useState } from 'react';
import { Link } from 'react-router-dom';
import { PanelDots } from './PanelDots';
import { MenuOverlay } from './MenuOverlay';
import { APP_CONFIG } from '../config/app.config';

interface EdgeBarProps {
  panelCount?: number;
  currentPanel?: number;
  onPanelChange?: (index: number) => void;
  isPaused?: boolean;
  onTogglePause?: () => void;
}

export const EdgeBar = ({
  panelCount = 0,
  currentPanel = 0,
  onPanelChange,
  isPaused = false,
  onTogglePause,
}: EdgeBarProps) => {
  const [allPagesOpen, setAllPagesOpen] = useState(false);

  const canGoPrev = currentPanel > 0;
  const canGoNext = currentPanel < panelCount - 1;

  return (
    <>
      <footer
        id="edge-bar"
        role="contentinfo"
        aria-label="Page controls and legal links"
        className="fixed bottom-0 inset-x-0 z-30 h-14 sm:h-16 px-4 sm:px-8 flex items-center justify-between bg-[#FAF7F2]/80 backdrop-blur-md border-t border-neutral-200/60 select-none text-xs font-sans text-neutral-600"
      >
        {/* Left: Copyright & Essential Legal Links */}
        <div className="flex items-center gap-2 sm:gap-3">
          <span className="font-medium text-neutral-900 hidden xs:inline">
            © {APP_CONFIG.BRAND_NAME}
          </span>
          <span className="text-neutral-300 hidden xs:inline">·</span>
          <Link to="/legal/privacy" className="hover:text-neutral-950 transition-colors">
            Privacy
          </Link>
          <span className="text-neutral-300">·</span>
          <Link to="/legal/terms" className="hover:text-neutral-950 transition-colors">
            Terms
          </Link>
          <span className="text-neutral-300 hidden sm:inline">·</span>
          <Link to="/legal/refunds" className="hover:text-neutral-950 transition-colors hidden sm:inline">
            Refunds
          </Link>
          <span className="text-neutral-300 hidden md:inline">·</span>
          <Link to="/legal/grievance" className="hover:text-neutral-950 transition-colors hidden md:inline">
            Grievance
          </Link>
        </div>

        {/* Centre: Panel Dots (on horizontal tracks) */}
        {panelCount > 1 && onPanelChange && (
          <div className="hidden sm:flex items-center">
            <PanelDots
              total={panelCount}
              current={currentPanel}
              onChange={onPanelChange}
            />
          </div>
        )}

        {/* Right: Step Buttons, Pause Toggle, All Pages Menu */}
        <div className="flex items-center gap-1.5 sm:gap-2">
          {panelCount > 1 && onPanelChange && (
            <div className="flex items-center gap-1 mr-1">
              <button
                type="button"
                aria-label="Previous panel"
                disabled={!canGoPrev}
                onClick={() => canGoPrev && onPanelChange(currentPanel - 1)}
                className={`w-7 h-7 rounded-full flex items-center justify-center border transition-all ${
                  canGoPrev
                    ? 'border-neutral-300 bg-white hover:bg-neutral-100 text-neutral-900 cursor-pointer'
                    : 'border-neutral-200 bg-neutral-100 text-neutral-300 cursor-not-allowed'
                }`}
              >
                ‹
              </button>
              <button
                type="button"
                aria-label="Next panel"
                disabled={!canGoNext}
                onClick={() => canGoNext && onPanelChange(currentPanel + 1)}
                className={`w-7 h-7 rounded-full flex items-center justify-center border transition-all ${
                  canGoNext
                    ? 'border-neutral-300 bg-white hover:bg-neutral-100 text-neutral-900 cursor-pointer'
                    : 'border-neutral-200 bg-neutral-100 text-neutral-300 cursor-not-allowed'
                }`}
              >
                ›
              </button>
            </div>
          )}

          {/* Pause Background Toggle */}
          {onTogglePause && (
            <button
              type="button"
              onClick={onTogglePause}
              aria-label={isPaused ? 'Resume background animation' : 'Pause background animation'}
              title={isPaused ? 'Resume background motion' : 'Pause background motion'}
              className="px-2 sm:px-2.5 py-1 rounded-full bg-white/80 hover:bg-white border border-neutral-300/80 text-[11px] font-sans font-medium text-neutral-800 transition-all cursor-pointer flex items-center gap-1"
            >
              <span className={`w-1.5 h-1.5 rounded-full ${isPaused ? 'bg-amber-600' : 'bg-emerald-600 animate-pulse'}`} />
              <span className="hidden md:inline">{isPaused ? 'Play bg' : 'Pause bg'}</span>
            </button>
          )}

          {/* All Pages Button */}
          <button
            type="button"
            onClick={() => setAllPagesOpen(true)}
            aria-label="Open all pages directory"
            className="px-2.5 sm:px-3 py-1 rounded-full bg-neutral-950 hover:bg-neutral-800 text-white text-[11px] font-sans font-medium transition-all cursor-pointer"
          >
            All pages
          </button>
        </div>
      </footer>

      <MenuOverlay isOpen={allPagesOpen} onClose={() => setAllPagesOpen(false)} />
    </>
  );
};
