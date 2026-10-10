import { Scene } from '../components/Scene';
import { Reader } from '../components/Reader';
import { legalContent } from '../content/legal';

export const LegalPrivacy = () => {
  const { privacy } = legalContent;
  return (
    <Scene panelCount={1} currentPanel={0}>
      <Reader
        title={privacy.title}
        subtitle={privacy.summary}
        dateOrVersion={privacy.version}
        categoryOrBadge="Legal Policy"
        backHref="/"
        backLabel="← Return Home"
      >
        <div className="space-y-6">
          {privacy.sections.map((sec) => (
            <div key={sec.heading} className="break-inside-avoid">
              <h3 className="font-serif text-xl font-normal text-neutral-900 mb-2">
                {sec.heading}
              </h3>
              <p className="text-sm text-neutral-700 leading-relaxed">
                {sec.content}
              </p>
            </div>
          ))}
        </div>
      </Reader>
    </Scene>
  );
};

export const LegalTerms = () => {
  const { terms } = legalContent;
  return (
    <Scene panelCount={1} currentPanel={0}>
      <Reader
        title={terms.title}
        subtitle={terms.summary}
        dateOrVersion={terms.version}
        categoryOrBadge="Terms"
        backHref="/"
        backLabel="← Return Home"
      >
        <div className="space-y-6">
          {terms.sections.map((sec) => (
            <div key={sec.heading} className="break-inside-avoid">
              <h3 className="font-serif text-xl font-normal text-neutral-900 mb-2">
                {sec.heading}
              </h3>
              <p className="text-sm text-neutral-700 leading-relaxed">
                {sec.content}
              </p>
            </div>
          ))}
        </div>
      </Reader>
    </Scene>
  );
};

export const LegalRefunds = () => {
  const { refunds } = legalContent;
  return (
    <Scene panelCount={1} currentPanel={0}>
      <Reader
        title={refunds.title}
        subtitle={refunds.summary}
        dateOrVersion={refunds.version}
        categoryOrBadge="Refunds"
        backHref="/"
        backLabel="← Return Home"
      >
        <div className="space-y-6">
          {refunds.sections.map((sec) => (
            <div key={sec.heading} className="break-inside-avoid">
              <h3 className="font-serif text-xl font-normal text-neutral-900 mb-2">
                {sec.heading}
              </h3>
              <p className="text-sm text-neutral-700 leading-relaxed">
                {sec.content}
              </p>
            </div>
          ))}
        </div>
      </Reader>
    </Scene>
  );
};

export const LegalGrievance = () => {
  const { grievance } = legalContent;
  return (
    <Scene panelCount={1} currentPanel={0}>
      <section className="max-w-2xl mx-auto w-full px-4 sm:px-8 py-16 flex flex-col items-center text-center justify-center h-full">
        <span className="text-[11px] font-sans font-semibold uppercase tracking-wider text-amber-900 bg-amber-100 px-3 py-1 rounded-full mb-4 border border-amber-200">
          Statutory Compliance
        </span>

        <h1 className="font-serif text-3xl sm:text-5xl text-neutral-950 font-normal tracking-tight mb-4">
          {grievance.title}
        </h1>

        <div className="w-full p-6 sm:p-8 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl text-left space-y-4 font-sans text-xs text-neutral-700">
          <div>
            <span className="text-neutral-500 block uppercase tracking-wider text-[10px] mb-1">
              Designated Officer
            </span>
            <span className="font-semibold text-neutral-900 text-sm">
              {grievance.officerName}
            </span>
          </div>

          <div>
            <span className="text-neutral-500 block uppercase tracking-wider text-[10px] mb-1">
              Grievance Inquiries Email
            </span>
            <a
              href={`mailto:${grievance.email}`}
              className="font-mono text-sm font-semibold text-amber-900 hover:underline"
            >
              {grievance.email}
            </a>
          </div>

          <div>
            <span className="text-neutral-500 block uppercase tracking-wider text-[10px] mb-1">
              Redressal Timeline
            </span>
            <p className="leading-relaxed text-neutral-600">
              {grievance.responseTimeline}
            </p>
          </div>

          <div>
            <span className="text-neutral-500 block uppercase tracking-wider text-[10px] mb-1">
              Jurisdiction & Address
            </span>
            <span className="text-neutral-800 font-medium">
              {grievance.address}
            </span>
          </div>
        </div>
      </section>
    </Scene>
  );
};
