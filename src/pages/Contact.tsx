import { Scene } from '../components/Scene';
import { LeadForm } from '../components/LeadForm';
import { AlsoExplore } from '../components/AlsoExplore';
import { contactContent } from '../content/contact';

export const Contact = () => {
  const content = contactContent.en;

  const exploreLinks = [
    { label: 'Institutions', href: '/institutions' },
    { label: 'Join Waitlist', href: '/begin' },
    { label: 'Read FAQ', href: '/faq' },
  ];

  return (
    <Scene panelCount={1} currentPanel={0}>
      <section className="max-w-6xl mx-auto w-full px-4 sm:px-8 py-16 flex flex-col md:flex-row items-center justify-between gap-10 h-full">
        {/* Left Column: Direct Channels & Information */}
        <div className="w-full md:w-1/2 flex flex-col items-center md:items-start text-center md:text-left">
          <span className="text-[11px] font-sans font-semibold uppercase tracking-wider text-amber-900 bg-amber-100 px-3 py-1 rounded-full mb-4 border border-amber-200">
            Reach Us
          </span>

          <h1 className="font-serif text-4xl sm:text-6xl text-neutral-950 font-normal tracking-tight mb-3">
            {content.headline}
          </h1>

          <p className="font-sans text-base text-neutral-700 leading-relaxed max-w-md mb-8">
            {content.body}
          </p>

          <div className="p-4 rounded-2xl bg-white/70 backdrop-blur-md border border-neutral-200/80 mb-8 max-w-sm w-full text-left">
            <span className="text-[11px] font-sans font-medium text-neutral-500 uppercase tracking-wider block mb-1">
              Direct Inquiries
            </span>
            <a
              href={`mailto:${content.emailChannel}`}
              className="font-mono text-sm font-semibold text-neutral-900 hover:text-amber-900 transition-colors"
            >
              {content.emailChannel}
            </a>
            <span className="text-[11px] font-sans text-neutral-500 block mt-2">
              {content.responsePromise}
            </span>
          </div>

          <AlsoExplore links={exploreLinks} />
        </div>

        {/* Right Column: Contact LeadForm */}
        <div className="w-full md:w-1/2 flex justify-center md:justify-end">
          <LeadForm type="contact" />
        </div>
      </section>
    </Scene>
  );
};
