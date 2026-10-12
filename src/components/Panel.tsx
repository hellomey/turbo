import type { ReactNode } from 'react';

interface PanelProps {
  id: string;
  index: number;
  total: number;
  badge?: string;
  headline: ReactNode;
  body: string;
  visual?: ReactNode;
  actions?: ReactNode;
  footnote?: string;
  children?: ReactNode;
}

export const Panel = ({
  id,
  index,
  total,
  badge,
  headline,
  body,
  visual,
  actions,
  footnote,
  children,
}: PanelProps) => {
  return (
    <article
      id={id}
      role="group"
      aria-roledescription="slide"
      aria-label={`Panel ${index + 1} of ${total}`}
      className="panel-viewport flex flex-col justify-center items-center px-6 sm:px-12 md:px-16 lg:px-24 pt-20 pb-20 select-none"
    >
      <div className="panel-content-scroll-fallback max-w-4xl mx-auto w-full h-full flex flex-col items-center justify-center text-center">
        {/* Subtle step badge */}
        <span className="text-[11px] font-sans font-medium uppercase tracking-widest text-neutral-400 mb-4">
          {badge || `${String(index + 1).padStart(2, '0')} / ${String(total).padStart(2, '0')}`}
        </span>

        {/* Headline with the exact same Instrument Serif font and italic rhythm */}
        <h2 className="font-serif text-4xl sm:text-5xl md:text-6xl lg:text-7xl text-neutral-950 font-normal leading-[1.08] tracking-tight mb-5 max-w-3xl">
          {headline}
        </h2>

        {/* Clear, readable body text in Inter */}
        <p className="font-sans text-base sm:text-lg text-[#4A4A4A] leading-relaxed max-w-2xl mb-8">
          {body}
        </p>

        {/* Clean content or visual container if provided */}
        {visual && (
          <div className="w-full max-w-xl my-4 flex items-center justify-center">
            {visual}
          </div>
        )}

        {/* Clean action buttons */}
        {actions && (
          <div className="mt-2 flex flex-wrap items-center justify-center gap-3.5">
            {actions}
          </div>
        )}

        {/* Subtle footnote */}
        {footnote && (
          <p className="text-xs font-sans text-neutral-400 max-w-lg mt-6 italic">
            {footnote}
          </p>
        )}

        {children}
      </div>
    </article>
  );
};
