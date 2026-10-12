import { useSearchParams } from 'react-router-dom';
import { Scene } from '../components/Scene';
import { LeadForm } from '../components/LeadForm';
import { beginContent } from '../content/begin';

export const Begin = () => {
  const content = beginContent.en;
  const [searchParams] = useSearchParams();
  const examParam = searchParams.get('exam') || undefined;
  const intentParam = searchParams.get('intent') || undefined;

  return (
    <Scene panelCount={1} currentPanel={0}>
      <section className="max-w-5xl mx-auto w-full px-6 sm:px-10 py-16 flex flex-col md:flex-row items-center justify-between gap-12 h-full">
        {/* Left column: Introduction */}
        <div className="w-full md:w-1/2 flex flex-col items-center md:items-start text-center md:text-left">
          <span className="text-[11px] font-sans font-medium uppercase tracking-widest text-neutral-400 mb-4">
            Closed Beta Cohort
          </span>

          <h1 className="font-serif text-4xl sm:text-6xl text-neutral-950 font-normal tracking-tight leading-[1.08] mb-4">
            {content.headline}
          </h1>

          <p className="font-sans text-base text-[#4A4A4A] max-w-md leading-relaxed mb-6">
            {content.subhead}
          </p>

          <div className="text-xs font-sans text-neutral-500 space-y-1.5 hidden md:block">
            <p>• Invitations rolled out weekly in small, focused batches.</p>
            <p>• Free access through the entirety of the closed beta window.</p>
          </div>
        </div>

        {/* Right column: Form */}
        <div className="w-full md:w-1/2 flex justify-center md:justify-end">
          <LeadForm
            type="waitlist"
            defaultExam={examParam}
            defaultIntent={intentParam}
          />
        </div>
      </section>
    </Scene>
  );
};
