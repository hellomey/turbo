import { useRef, useState, useEffect, type ReactNode } from 'react';
import { Link } from 'react-router-dom';

interface ReaderProps {
  title: string;
  subtitle?: string;
  dateOrVersion?: string;
  categoryOrBadge?: string;
  backHref?: string;
  backLabel?: string;
  sources?: string[];
  children: ReactNode;
}

export const Reader = ({
  title,
  subtitle,
  dateOrVersion,
  categoryOrBadge,
  backHref = '/journal',
  backLabel = '← Back to Journal',
  sources,
  children,
}: ReaderProps) => {
  const scrollRef = useRef<HTMLDivElement | null>(null);
  const [scrollProgress, setScrollProgress] = useState(0);

  const handleScroll = () => {
    const el = scrollRef.current;
    if (!el) return;
    const maxScroll = el.scrollWidth - el.clientWidth;
    if (maxScroll > 0) {
      setScrollProgress(Math.min(100, Math.round((el.scrollLeft / maxScroll) * 100)));
    }
  };

  const scrollByAmount = (forward: boolean) => {
    const el = scrollRef.current;
    if (!el) return;
    const amount = el.clientWidth * 0.75;
    el.scrollBy({ left: forward ? amount : -amount, behavior: 'smooth' });
  };

  // Keyboard navigation for reader
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'ArrowRight' || e.key === 'PageDown') {
        scrollByAmount(true);
      } else if (e.key === 'ArrowLeft' || e.key === 'PageUp') {
        scrollByAmount(false);
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  return (
    <main className="w-full h-[100dvh] flex flex-col justify-between pt-16 sm:pt-20 pb-16 px-4 sm:px-10 lg:px-16 overflow-hidden select-text bg-[#FAF7F2]">
      {/* Header Info */}
      <header className="max-w-4xl mx-auto w-full flex items-center justify-between pb-4 border-b border-neutral-200/80">
        <div className="flex items-center gap-3">
          {backHref && (
            <Link
              to={backHref}
              className="text-xs font-sans font-medium text-amber-900 hover:text-neutral-950 transition-colors"
            >
              {backLabel}
            </Link>
          )}
          {categoryOrBadge && (
            <span className="px-2.5 py-0.5 rounded-full bg-amber-100/90 text-amber-900 text-[11px] font-sans font-semibold uppercase tracking-wider">
              {categoryOrBadge}
            </span>
          )}
        </div>

        <div className="flex items-center gap-2">
          {dateOrVersion && (
            <span className="text-xs font-sans text-neutral-500 font-mono">
              {dateOrVersion}
            </span>
          )}
          {/* Reader step buttons */}
          <div className="flex items-center gap-1 ml-2">
            <button
              type="button"
              onClick={() => scrollByAmount(false)}
              aria-label="Scroll left in article"
              className="w-7 h-7 rounded-full bg-white border border-neutral-300 flex items-center justify-center text-neutral-800 hover:bg-neutral-100 cursor-pointer shadow-xs"
            >
              ‹
            </button>
            <button
              type="button"
              onClick={() => scrollByAmount(true)}
              aria-label="Scroll right in article"
              className="w-7 h-7 rounded-full bg-white border border-neutral-300 flex items-center justify-center text-neutral-800 hover:bg-neutral-100 cursor-pointer shadow-xs"
            >
              ›
            </button>
          </div>
        </div>
      </header>

      {/* Progress Bar */}
      <div className="w-full max-w-4xl mx-auto h-0.5 bg-neutral-200 mt-2">
        <div
          className="h-full bg-amber-600 transition-all duration-150"
          style={{ width: `${scrollProgress}%` }}
        />
      </div>

      {/* Multi-Column Reader Body */}
      <div
        ref={scrollRef}
        onScroll={handleScroll}
        className="reader-columns flex-1 my-4 text-neutral-800 leading-relaxed text-sm sm:text-base font-sans"
      >
        <div className="mb-6 break-inside-avoid">
          <h1 className="font-serif text-3xl sm:text-4xl text-neutral-950 font-normal leading-tight mb-2">
            {title}
          </h1>
          {subtitle && (
            <p className="font-sans text-base text-neutral-600 italic">
              {subtitle}
            </p>
          )}
        </div>

        {children}

        {sources && sources.length > 0 && (
          <div className="mt-8 pt-4 border-t border-neutral-300 break-inside-avoid text-xs text-neutral-500 space-y-1">
            <span className="font-semibold text-neutral-700 block uppercase tracking-wider text-[10px]">
              Verified Citations & Sources:
            </span>
            <ul className="list-disc pl-4 space-y-1">
              {sources.map((src, i) => (
                <li key={i}>{src}</li>
              ))}
            </ul>
          </div>
        )}
      </div>

      {/* Reader Footer Hint */}
      <footer className="text-center text-[11px] font-sans text-neutral-400">
        Use ← → arrow keys, trackpad, or the step controls to advance columns horizontally.
      </footer>
    </main>
  );
};
