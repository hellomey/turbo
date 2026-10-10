import { Link } from 'react-router-dom';
import { CtaButton } from './CtaButton';
import { homeContent } from '../content/home';

export const Hero = () => {
  const content = homeContent.en;

  return (
    <section
      id="hero-section"
      className="relative z-10 flex flex-col items-center justify-start text-center px-4 sm:px-6 pt-2 sm:pt-6 md:pt-10 pb-28 sm:pb-36 md:pb-40 max-w-5xl mx-auto w-full select-none"
    >
      {/* Main Headline (frozen visual layout per spec §0.1) */}
      <h1
        id="hero-headline"
        className="hero-headline font-serif font-normal text-4xl xs:text-5xl sm:text-6xl md:text-7xl lg:text-[5.25rem] xl:text-[5.75rem] max-w-5xl text-neutral-950 tracking-tight leading-[1.05] sm:leading-[1.0] animate-fade-rise"
        style={{
          textShadow: '0 2px 20px rgba(250, 247, 242, 0.4)',
        }}
      >
        {content.headlinePart1}{' '}
        <span className="italic text-neutral-600 font-serif">
          {content.headlineHighlight1}
        </span>{' '}
        {content.headlinePart2}{' '}
        <span className="italic text-neutral-600 font-serif">
          {content.headlineHighlight2}
        </span>
      </h1>

      {/* Subtitle / Description per spec §6.1 */}
      <p
        id="hero-description"
        className="font-sans text-sm sm:text-base md:text-lg max-w-2xl mt-5 sm:mt-7 leading-relaxed text-neutral-700 sm:text-neutral-800 font-normal animate-fade-rise-delay px-2"
        style={{
          textShadow: '0 1px 12px rgba(255, 255, 255, 0.8)',
        }}
      >
        {content.description}
      </p>

      {/* CTA Button Group */}
      <div className="flex flex-col sm:flex-row items-center gap-3.5 sm:gap-4 mt-8 sm:mt-10 md:mt-12 animate-fade-rise-delay-2 w-full sm:w-auto">
        <CtaButton label={content.primaryCta} />

        <Link
          to={content.secondaryCtaHref}
          id="hero-secondary-cta"
          className="w-full sm:w-auto inline-flex items-center justify-center gap-2 rounded-full px-6 sm:px-8 py-3.5 sm:py-4 text-sm sm:text-base bg-white/60 hover:bg-white/80 backdrop-blur-md border border-neutral-300/70 text-neutral-900 font-sans font-medium transition-all duration-300 cursor-pointer shadow-sm hover:shadow"
        >
          <span>{content.secondaryCta}</span>
        </Link>
      </div>
    </section>
  );
};
