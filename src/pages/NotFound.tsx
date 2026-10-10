import { Link } from 'react-router-dom';
import { Scene } from '../components/Scene';
import { Sudi } from '../components/Sudi';

export const NotFound = () => {
  return (
    <Scene panelCount={1} currentPanel={0}>
      <section className="max-w-md mx-auto w-full px-6 py-16 flex flex-col items-center text-center justify-center h-full">
        <Sudi state="sleepy" size={88} />

        <span className="text-[11px] font-sans font-semibold uppercase tracking-wider text-neutral-500 bg-neutral-200/60 px-3 py-1 rounded-full mt-6 mb-3">
          Error 404
        </span>

        <h1 className="font-serif text-3xl sm:text-4xl text-neutral-950 font-normal tracking-tight mb-2">
          This page took a different route.
        </h1>

        <p className="font-sans text-xs sm:text-sm text-neutral-600 leading-relaxed mb-8">
          The link you followed may have moved or no longer exists. Let's get you back on track.
        </p>

        <div className="flex flex-wrap items-center justify-center gap-3">
          <Link
            to="/"
            className="px-6 py-2.5 rounded-full bg-neutral-950 hover:bg-neutral-800 text-white text-xs font-sans font-medium transition-all shadow-md"
          >
            Home
          </Link>
          <Link
            to="/studio"
            className="px-6 py-2.5 rounded-full bg-white/80 hover:bg-white text-neutral-900 border border-neutral-300 text-xs font-sans font-medium transition-all shadow-xs"
          >
            Studio
          </Link>
          <Link
            to="/exams"
            className="px-6 py-2.5 rounded-full bg-white/80 hover:bg-white text-neutral-900 border border-neutral-300 text-xs font-sans font-medium transition-all shadow-xs"
          >
            Exams
          </Link>
        </div>
      </section>
    </Scene>
  );
};
