import type { ReactNode } from 'react';

interface PanelProps {
  id: string;
  index: number;
  total: number;
  badge?: string;
  headline: string;
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
      aria-label={`${index + 1} of ${total}: ${headline}`}
      className="panel-viewport flex flex-col justify-center px-4 sm:px-8 md:px-14 lg:px-20 pt-16 sm:pt-20 pb-16 sm:pb-20"
    >
      <div className="panel-content-scroll-fallback max-w-6xl mx-auto w-full h-full flex flex-col md:flex-row items-center justify-center gap-6 sm:gap-10 lg:gap-16">
        {/* Visual on mobile (top ~38% of screen) */}
        {visual && (
          <div className="md:hidden w-full flex items-center justify-center py-2 max-h-[38dvh]">
            {visual}
          </div>
        )}

        {/* Text Content Column */}
        <div className="w-full md:w-1/2 flex flex-col items-center md:items-start text-center md:text-left z-10">
          {badge && (
            <span className="inline-block text-[11px] font-sans font-semibold uppercase tracking-wider text-amber-900 bg-amber-100/80 px-2.5 py-1 rounded-full mb-3 sm:mb-4 border border-amber-200/60">
              {badge}
            </span>
          )}

          <h2 className="font-serif text-3xl xs:text-4xl sm:text-5xl lg:text-6xl text-neutral-950 font-normal leading-[1.08] tracking-tight mb-3 sm:mb-4">
            {headline}
          </h2>

          <p className="font-sans text-base sm:text-lg text-neutral-700 leading-relaxed max-w-md sm:max-w-lg mb-6">
            {body}
          </p>

          {actions && <div className="mb-4 w-full flex flex-wrap justify-center md:justify-start gap-3">{actions}</div>}

          {footnote && (
            <p className="text-[11px] font-sans text-neutral-500 max-w-sm mt-2 italic">
              {footnote}
            </p>
          )}

          {children}
        </div>

        {/* Visual on Desktop (right column) */}
        {visual && (
          <div className="hidden md:flex md:w-1/2 items-center justify-center p-4">
            {visual}
          </div>
        )}
      </div>
    </article>
  );
};
