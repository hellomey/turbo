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
      <section className="max-w-5xl mx-auto w-full px-6 sm:px-10 py-16 flex flex-col md:flex-row items-center justify-between gap-12 h-full">
        {/* Left Column: Direct Channels & Information */}
        <div className="w-full md:w-1/2 flex flex-col items-center md:items-start text-center md:text-left">
          <span className="text-[11px] font-sans font-medium uppercase tracking-widest text-neutral-400 mb-4">
            Direct Communication
          </span>

          <h1 className="font-serif text-4xl sm:text-6xl text-neutral-950 font-normal tracking-tight leading-[1.08] mb-4">
            {content.headline}
          </h1>

          <p className="font-sans text-base text-[#4A4A4A] leading-relaxed max-w-md mb-8">
            {content.body}
          </p>

          <div className="p-5 rounded-2xl bg-white border border-neutral-200/90 shadow-sm mb-8 max-w-sm w-full text-left font-sans text-xs">
            <span className="text-[11px] font-medium text-neutral-400 uppercase tracking-wider block mb-1">
              Direct Mail
            </span>
            <a
              href={`mailto:${content.emailChannel}`}
              className="text-sm font-medium text-neutral-950 hover:text-neutral-600 transition-colors block"
            >
              {content.emailChannel}
            </a>
            <span className="text-[11px] text-neutral-500 block mt-2">
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
