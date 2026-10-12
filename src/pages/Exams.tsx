import { Link } from 'react-router-dom';
import { Scene } from '../components/Scene';
import { examsContent } from '../content/exams';

export const Exams = () => {
  const content = examsContent.en;

  return (
    <Scene panelCount={1} currentPanel={0}>
      <section className="max-w-5xl mx-auto w-full px-6 sm:px-10 py-16 flex flex-col items-center text-center justify-center h-full select-none">
        <span className="text-[11px] font-sans font-medium uppercase tracking-widest text-neutral-400 mb-4">
          Target Examinations
        </span>

        <h1 className="font-serif text-4xl sm:text-6xl lg:text-7xl text-neutral-950 font-normal tracking-tight mb-4 leading-[1.08]">
          Choose your <span className="italic text-neutral-500 font-serif">exam.</span>
        </h1>

        <p className="font-sans text-base sm:text-lg text-[#4A4A4A] max-w-xl mb-10 leading-relaxed">
          {content.subhead}
        </p>

        {/* Minimalist Cards Grid */}
        <div className="w-full grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 max-w-4xl mb-10">
          {content.cards.map((card) => (
            <Link
              key={card.id}
              to={card.href}
              className="p-5 sm:p-6 rounded-3xl bg-white hover:bg-neutral-50 border border-neutral-200/80 shadow-xs hover:shadow-md transition-all duration-300 flex flex-col justify-between text-left group"
            >
              <div>
                <div className="flex items-center justify-between mb-3">
                  <span className="text-[10px] font-sans font-semibold uppercase tracking-wider text-neutral-500 px-2.5 py-0.5 rounded-full bg-neutral-100">
                    {card.status}
                  </span>
                  <span className="text-neutral-400 group-hover:text-neutral-950 group-hover:translate-x-0.5 transition-all text-sm">
                    →
                  </span>
                </div>
                <h3 className="font-serif text-xl sm:text-2xl text-neutral-950 font-normal mb-1.5 leading-snug">
                  {card.title}
                </h3>
                <p className="font-sans text-xs text-neutral-600 leading-relaxed">
                  {card.subtitle}
                </p>
              </div>

              <div className="mt-5 pt-3 border-t border-neutral-100 text-xs font-sans text-neutral-900 font-medium flex items-center justify-between">
                <span>{card.status === 'In beta' ? 'Explore Preparation' : 'Get Notified'}</span>
                <span>›</span>
              </div>
            </Link>
          ))}
        </div>

        {/* Disclaimer */}
        <p className="text-xs font-sans text-neutral-400 max-w-md italic">
          {content.disclaimer}
        </p>
      </section>
    </Scene>
  );
};
