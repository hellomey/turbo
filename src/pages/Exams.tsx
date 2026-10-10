import { Link } from 'react-router-dom';
import { Scene } from '../components/Scene';
import { examsContent } from '../content/exams';

export const Exams = () => {
  const content = examsContent.en;

  return (
    <Scene panelCount={1} currentPanel={0}>
      <section className="max-w-6xl mx-auto w-full px-4 sm:px-8 py-16 flex flex-col items-center text-center justify-center h-full">
        <span className="text-[11px] font-sans font-semibold uppercase tracking-wider text-amber-900 bg-amber-100 px-3 py-1 rounded-full mb-3 border border-amber-200">
          Target Coverage
        </span>

        <h1 className="font-serif text-4xl sm:text-6xl text-neutral-950 font-normal tracking-tight mb-2">
          {content.headline}
        </h1>

        <p className="font-sans text-sm sm:text-base text-neutral-600 max-w-xl mb-8">
          {content.subhead}
        </p>

        {/* Horizontal Cards Row */}
        <div className="w-full grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 max-w-5xl mb-8">
          {content.cards.map((card) => (
            <Link
              key={card.id}
              to={card.href}
              className="p-5 rounded-3xl bg-white/80 hover:bg-white/95 backdrop-blur-md border border-neutral-200/80 shadow-md hover:shadow-xl transition-all duration-300 flex flex-col justify-between text-left group hover:scale-[1.02]"
            >
              <div>
                <div className="flex items-center justify-between mb-3">
                  <span className={`text-[10px] font-sans font-bold uppercase tracking-wider px-2 py-0.5 rounded-full border ${card.badgeColor}`}>
                    {card.status}
                  </span>
                  <span className="text-neutral-400 group-hover:text-neutral-900 transition-colors">
                    →
                  </span>
                </div>
                <h3 className="font-serif text-xl sm:text-2xl text-neutral-950 font-normal mb-1">
                  {card.title}
                </h3>
                <p className="font-sans text-xs text-neutral-600 leading-relaxed">
                  {card.subtitle}
                </p>
              </div>

              <div className="mt-4 pt-3 border-t border-neutral-100 flex items-center justify-between text-xs font-sans text-amber-900 font-medium">
                <span>{card.status === 'In beta' ? 'Explore Preparation' : 'Get notified'}</span>
                <span>›</span>
              </div>
            </Link>
          ))}
        </div>

        {/* Independence Disclaimer */}
        <p className="text-xs font-sans text-neutral-500 max-w-lg italic">
          {content.disclaimer}
        </p>
      </section>
    </Scene>
  );
};
