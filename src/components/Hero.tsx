export const Hero = () => {
  return (
    <section
      id="hero-section"
      className="relative z-10 flex flex-col items-center justify-start text-center px-4 sm:px-6 pt-2 sm:pt-6 md:pt-10 pb-28 sm:pb-36 md:pb-40 max-w-5xl mx-auto w-full select-none"
    >
      {/* Main Headline */}
      <h1
        id="hero-headline"
        className="hero-headline font-serif font-normal text-4xl xs:text-5xl sm:text-6xl md:text-7xl lg:text-[5.25rem] xl:text-[5.75rem] max-w-5xl text-neutral-950 tracking-tight leading-[1.05] sm:leading-[1.0] animate-fade-rise"
        style={{
          textShadow: '0 2px 20px rgba(250, 247, 242, 0.4)',
        }}
      >
        Where you{' '}
        <span className="italic text-neutral-600 font-serif">
          truly stand.
        </span>{' '}
        What to do{' '}
        <span className="italic text-neutral-600 font-serif">
          today.
        </span>
      </h1>

      {/* Subtitle / Description */}
      <p
        id="hero-description"
        className="font-sans text-sm sm:text-base md:text-lg max-w-2xl mt-5 sm:mt-7 leading-relaxed text-neutral-700 sm:text-neutral-800 font-normal animate-fade-rise-delay px-2"
        style={{
          textShadow: '0 1px 12px rgba(255, 255, 255, 0.8)',
        }}
      >
        An honest, AI-assisted daily companion for Tamil Nadu's government-exam
        aspirants. It tells them where they truly stand, and what to do today.
      </p>

      {/* CTA Button Group */}
      <div className="flex flex-col sm:flex-row items-center gap-3.5 sm:gap-4 mt-8 sm:mt-10 md:mt-12 animate-fade-rise-delay-2 w-full sm:w-auto">
        <button
          type="button"
          id="hero-cta-button"
          className="group w-full sm:w-auto inline-flex items-center justify-center gap-3 rounded-full px-9 sm:px-12 py-3.5 sm:py-4 text-sm sm:text-base bg-neutral-950 hover:bg-neutral-800 text-white font-sans font-medium hover:scale-[1.02] active:scale-[0.98] transition-all duration-300 ease-out cursor-pointer shadow-xl hover:shadow-2xl"
        >
          <span>Begin Journey</span>
          <svg
            className="w-4 h-4 transition-transform duration-300 group-hover:translate-x-1"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
            strokeWidth="2"
          >
            <path strokeLinecap="round" strokeLinejoin="round" d="M14 5l7 7m0 0l-7 7m7-7H3" />
          </svg>
        </button>

        <a
          href="#studio"
          id="hero-secondary-cta"
          className="w-full sm:w-auto inline-flex items-center justify-center gap-2 rounded-full px-6 sm:px-8 py-3.5 sm:py-4 text-sm sm:text-base bg-white/60 hover:bg-white/80 backdrop-blur-md border border-neutral-300/70 text-neutral-900 font-sans font-medium transition-all duration-300 cursor-pointer shadow-sm hover:shadow"
        >
          <span>Explore Syllabus</span>
        </a>
      </div>
    </section>
  );
};
