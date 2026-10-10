import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Scene } from '../components/Scene';
import { journalArticles, type JournalArticle } from '../content/journal';

export const JournalIndex = () => {
  const [filter, setFilter] = useState<string>('All');
  const categories = ['All', 'Exam updates', 'Study craft', 'Stories'];

  const filteredArticles =
    filter === 'All'
      ? journalArticles
      : journalArticles.filter((a) => a.category === filter);

  return (
    <Scene panelCount={1} currentPanel={0}>
      <section className="max-w-6xl mx-auto w-full px-4 sm:px-8 py-16 flex flex-col items-center text-center justify-center h-full">
        <span className="text-[11px] font-sans font-semibold uppercase tracking-wider text-amber-900 bg-amber-100 px-3 py-1 rounded-full mb-3 border border-amber-200">
          The HeyMey Journal
        </span>

        <h1 className="font-serif text-4xl sm:text-6xl text-neutral-950 font-normal tracking-tight mb-2">
          Notes on preparation & truth.
        </h1>

        <p className="font-sans text-sm sm:text-base text-neutral-600 max-w-xl mb-6">
          Rigorous analysis of Tamil Nadu examinations, learning psychology, and honest study craft.
        </p>

        {/* Filter Chips */}
        <div className="flex flex-wrap items-center justify-center gap-2 mb-8">
          {categories.map((cat) => (
            <button
              key={cat}
              type="button"
              onClick={() => setFilter(cat)}
              className={`px-3.5 py-1.5 rounded-full text-xs font-sans font-medium transition-all cursor-pointer ${
                filter === cat
                  ? 'bg-neutral-950 text-white shadow-sm'
                  : 'bg-white/80 hover:bg-white text-neutral-700 border border-neutral-200'
              }`}
            >
              {cat}
            </button>
          ))}
        </div>

        {/* Horizontal Article Cards Grid */}
        <div className="w-full grid grid-cols-1 md:grid-cols-3 gap-6 max-w-5xl">
          {filteredArticles.map((art: JournalArticle) => (
            <Link
              key={art.slug}
              to={`/journal/${art.slug}`}
              className="p-6 rounded-3xl bg-white/85 hover:bg-white/95 backdrop-blur-md border border-neutral-200/80 shadow-md hover:shadow-2xl transition-all duration-300 flex flex-col justify-between text-left group hover:scale-[1.02]"
            >
              <div>
                <div className="flex items-center justify-between text-xs font-sans text-neutral-500 mb-3">
                  <span className="px-2.5 py-0.5 rounded-full bg-amber-100/80 text-amber-900 font-semibold text-[10px] uppercase tracking-wider">
                    {art.category}
                  </span>
                  <span>{art.readMinutes} min read</span>
                </div>

                <h3 className="font-serif text-2xl text-neutral-950 font-normal group-hover:text-amber-900 transition-colors mb-2 leading-tight">
                  {art.title}
                </h3>

                <p className="font-sans text-xs text-neutral-600 leading-relaxed line-clamp-3">
                  {art.summary}
                </p>
              </div>

              <div className="mt-6 pt-3 border-t border-neutral-100 flex items-center justify-between text-xs font-sans text-neutral-800 font-medium">
                <span>Read Article</span>
                <span className="group-hover:translate-x-1 transition-transform">→</span>
              </div>
            </Link>
          ))}
        </div>
      </section>
    </Scene>
  );
};
