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
      <section className="max-w-5xl mx-auto w-full px-6 sm:px-10 py-16 flex flex-col items-center text-center justify-center h-full">
        <span className="text-[11px] font-sans font-medium uppercase tracking-widest text-neutral-400 mb-3">
          The HeyMey Journal
        </span>

        <h1 className="font-serif text-4xl sm:text-6xl text-neutral-950 font-normal tracking-tight leading-[1.08] mb-3">
          Notes on preparation <span className="italic text-neutral-500 font-serif">&amp; truth.</span>
        </h1>

        <p className="font-sans text-base text-[#4A4A4A] max-w-xl mb-8 leading-relaxed">
          Rigorous analysis of Tamil Nadu examinations, learning psychology, and honest study craft.
        </p>

        {/* Filter Chips */}
        <div className="flex flex-wrap items-center justify-center gap-2 mb-8">
          {categories.map((cat) => (
            <button
              key={cat}
              type="button"
              onClick={() => setFilter(cat)}
              className={`px-4 py-1.5 rounded-full text-xs font-sans font-medium transition-all cursor-pointer ${
                filter === cat
                  ? 'bg-neutral-950 text-white'
                  : 'bg-white hover:bg-neutral-100 text-neutral-700 border border-neutral-200'
              }`}
            >
              {cat}
            </button>
          ))}
        </div>

        {/* Article Cards Grid */}
        <div className="w-full grid grid-cols-1 md:grid-cols-3 gap-6 max-w-4xl">
          {filteredArticles.map((art: JournalArticle) => (
            <Link
              key={art.slug}
              to={`/journal/${art.slug}`}
              className="p-6 rounded-2xl bg-white border border-neutral-200/90 shadow-sm hover:shadow-md transition-all duration-200 flex flex-col justify-between text-left group"
            >
              <div>
                <div className="flex items-center justify-between text-xs font-sans text-neutral-400 mb-3">
                  <span className="text-[10px] uppercase tracking-wider font-medium">
                    {art.category}
                  </span>
                  <span>{art.readMinutes} min read</span>
                </div>

                <h3 className="font-serif text-2xl text-neutral-950 font-normal group-hover:text-neutral-600 transition-colors mb-2 leading-snug">
                  {art.title}
                </h3>

                <p className="font-sans text-xs text-neutral-600 leading-relaxed line-clamp-3">
                  {art.summary}
                </p>
              </div>

              <div className="mt-6 pt-3 border-t border-neutral-100 flex items-center justify-between text-xs font-sans text-neutral-950 font-medium">
                <span>Read article</span>
                <span className="group-hover:translate-x-0.5 transition-transform">→</span>
              </div>
            </Link>
          ))}
        </div>
      </section>
    </Scene>
  );
};
