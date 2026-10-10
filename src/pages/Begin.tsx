import { useSearchParams } from 'react-router-dom';
import { Scene } from '../components/Scene';
import { LeadForm } from '../components/LeadForm';
import { KolamDraw } from '../components/PanelVisuals';
import { beginContent } from '../content/begin';

export const Begin = () => {
  const content = beginContent.en;
  const [searchParams] = useSearchParams();
  const examParam = searchParams.get('exam') || undefined;
  const intentParam = searchParams.get('intent') || undefined;

  return (
    <Scene panelCount={1} currentPanel={0}>
      <section className="max-w-5xl mx-auto w-full px-4 sm:px-8 py-16 flex flex-col md:flex-row items-center justify-between gap-10 h-full">
        {/* Left column: Kolam & Introduction */}
        <div className="w-full md:w-1/2 flex flex-col items-center md:items-start text-center md:text-left">
          <div className="mb-6">
            <KolamDraw />
          </div>

          <span className="text-[11px] font-sans font-semibold uppercase tracking-wider text-amber-900 bg-amber-100 px-3 py-1 rounded-full mb-3 border border-amber-200">
            Closed Beta Invitation
          </span>

          <h1 className="font-serif text-4xl sm:text-6xl text-neutral-950 font-normal tracking-tight mb-3">
            {content.headline}
          </h1>

          <p className="font-sans text-sm sm:text-base text-neutral-600 max-w-md leading-relaxed">
            {content.subhead}
          </p>
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
