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
              <p className="text-sm text-neutral-700 leading-relaxed font-sans">
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
        categoryOrBadge="Terms of Service"
        backHref="/"
        backLabel="← Return Home"
      >
        <div className="space-y-6">
          {terms.sections.map((sec) => (
            <div key={sec.heading} className="break-inside-avoid">
              <h3 className="font-serif text-xl font-normal text-neutral-900 mb-2">
                {sec.heading}
              </h3>
              <p className="text-sm text-neutral-700 leading-relaxed font-sans">
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
        categoryOrBadge="Refund Policy"
        backHref="/"
        backLabel="← Return Home"
      >
        <div className="space-y-6">
          {refunds.sections.map((sec) => (
            <div key={sec.heading} className="break-inside-avoid">
              <h3 className="font-serif text-xl font-normal text-neutral-900 mb-2">
                {sec.heading}
              </h3>
              <p className="text-sm text-neutral-700 leading-relaxed font-sans">
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
      <section className="max-w-xl mx-auto w-full px-6 py-16 flex flex-col items-center text-center justify-center h-full">
        <span className="text-[11px] font-sans font-medium uppercase tracking-widest text-neutral-400 mb-4">
          Statutory Compliance
        </span>

        <h1 className="font-serif text-3xl sm:text-5xl text-neutral-950 font-normal tracking-tight leading-[1.08] mb-6">
          {grievance.title}
        </h1>

        <div className="w-full p-6 sm:p-8 rounded-2xl bg-white border border-neutral-200/90 shadow-sm text-left space-y-4 font-sans text-xs text-neutral-700">
          <div>
            <span className="text-neutral-400 block uppercase tracking-wider text-[10px] mb-1">
              Designated Officer
            </span>
            <span className="font-medium text-neutral-950 text-sm">
              {grievance.officerName}
            </span>
          </div>

          <div>
            <span className="text-neutral-400 block uppercase tracking-wider text-[10px] mb-1">
              Grievance Inquiries Email
            </span>
            <a
              href={`mailto:${grievance.email}`}
              className="text-sm font-medium text-neutral-950 hover:text-neutral-600 underline"
            >
              {grievance.email}
            </a>
          </div>

          <div>
            <span className="text-neutral-400 block uppercase tracking-wider text-[10px] mb-1">
              Redressal Timeline
            </span>
            <p className="leading-relaxed text-neutral-600">
              {grievance.responseTimeline}
            </p>
          </div>

          <div>
            <span className="text-neutral-400 block uppercase tracking-wider text-[10px] mb-1">
              Jurisdiction & Address
            </span>
            <span className="text-neutral-800">
              {grievance.address}
            </span>
          </div>
        </div>
      </section>
    </Scene>
  );
};
