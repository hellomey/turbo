import { Link } from 'react-router-dom';
import { Scene } from '../components/Scene';

export const NotFound = () => {
  return (
    <Scene panelCount={1} currentPanel={0}>
      <section className="max-w-md mx-auto w-full px-6 py-16 flex flex-col items-center text-center justify-center h-full">
        <span className="text-[11px] font-sans font-medium uppercase tracking-widest text-neutral-400 mb-4">
          Error 404
        </span>

        <h1 className="font-serif text-3xl sm:text-5xl text-neutral-950 font-normal tracking-tight leading-[1.08] mb-3">
          This page took a different route.
        </h1>

        <p className="font-sans text-base text-[#4A4A4A] leading-relaxed mb-8 max-w-sm">
          The link you followed may have moved or no longer exists. Let's guide you back to calm ground.
        </p>

        <div className="flex flex-wrap items-center justify-center gap-3">
          <Link
            to="/"
            className="px-6 py-3 rounded-full bg-neutral-950 hover:bg-neutral-800 text-white text-xs font-sans font-medium transition-all"
          >
            Return Home
          </Link>
          <Link
            to="/studio"
            className="px-6 py-3 rounded-full bg-white hover:bg-neutral-50 text-neutral-900 border border-neutral-300 text-xs font-sans font-medium transition-all"
          >
            Explore Studio
          </Link>
          <Link
            to="/exams"
            className="px-6 py-3 rounded-full bg-white hover:bg-neutral-50 text-neutral-900 border border-neutral-300 text-xs font-sans font-medium transition-all"
          >
            View Exams
          </Link>
        </div>
      </section>
    </Scene>
  );
};
