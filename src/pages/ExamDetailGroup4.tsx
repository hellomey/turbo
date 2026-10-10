import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Scene } from '../components/Scene';
import { PanelTrack } from '../components/PanelTrack';
import { Panel } from '../components/Panel';
import { CtaButton } from '../components/CtaButton';
import { group4DetailContent } from '../content/exams';
import { Sudi } from '../components/Sudi';

export const ExamDetailGroup4 = () => {
  const content = group4DetailContent.en;
  const [currentPanel, setCurrentPanel] = useState(0);

  const panelIds = content.panels.map((p) => p.id);

  return (
    <Scene
      panelCount={panelIds.length}
      currentPanel={currentPanel}
      onPanelChange={setCurrentPanel}
    >
      <PanelTrack
        panelIds={panelIds}
        currentPanel={currentPanel}
        onPanelChange={setCurrentPanel}
        ariaLabel="TNPSC Group 4 Examination Details"
      >
        {/* Panel 1: By the Numbers */}
        <Panel
          id={content.panels[0].id}
          index={0}
          total={content.panels.length}
          badge={content.panels[0].badge}
          headline={content.panels[0].headline}
          body={content.panels[0].body}
          footnote={content.panels[0].sourceNote}
          visual={
            <div className="w-full max-w-sm p-6 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col space-y-3.5">
              <span className="text-xs font-sans font-bold uppercase tracking-wider text-amber-900">
                July 2025 Examination Data
              </span>
              {content.panels[0].stats?.map((st) => (
                <div key={st.label} className="p-3 rounded-2xl bg-neutral-50/80 border border-neutral-200/60 flex items-center justify-between">
                  <span className="text-xs font-sans text-neutral-600">{st.label}</span>
                  <span className="font-serif text-xl font-bold text-neutral-900">{st.value}</span>
                </div>
              ))}
            </div>
          }
        />

        {/* Panel 2: What the exam tests */}
        <Panel
          id={content.panels[1].id}
          index={1}
          total={content.panels.length}
          badge={content.panels[1].badge}
          headline={content.panels[1].headline}
          body={content.panels[1].body}
          visual={
            <div className="w-full max-w-sm p-6 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col space-y-3">
              <span className="text-xs font-sans font-bold uppercase tracking-wider text-amber-900">
                Single Objective Paper (300 Marks)
              </span>
              {content.panels[1].papers?.map((p) => (
                <div key={p.name} className="p-3 rounded-2xl bg-neutral-50/80 border border-neutral-200/60 flex flex-col text-left">
                  <span className="text-xs font-sans font-medium text-neutral-900">{p.name}</span>
                  <span className="text-[11px] font-sans text-neutral-500 mt-1">{p.qs} • {p.marks}</span>
                </div>
              ))}
              <a
                href={content.panels[1].officialLink}
                target="_blank"
                rel="noopener noreferrer"
                className="text-xs font-sans font-medium text-amber-900 hover:underline pt-1 text-center"
              >
                Official TNPSC Notification Portal ↗
              </a>
            </div>
          }
        />

        {/* Panel 3: One exam cycle */}
        <Panel
          id={content.panels[2].id}
          index={2}
          total={content.panels.length}
          badge={content.panels[2].badge}
          headline={content.panels[2].headline}
          body={content.panels[2].body}
          visual={
            <div className="w-full max-w-sm p-6 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col text-left">
              <span className="text-xs font-sans font-bold uppercase tracking-wider text-amber-900 mb-3">
                Verified 2025 Calendar
              </span>
              <div className="relative pl-5 space-y-3.5 before:absolute before:left-2 before:top-2 before:bottom-2 before:w-0.5 before:bg-amber-300">
                {content.panels[2].timeline?.map((item) => (
                  <div key={item.stage} className="relative text-xs font-sans">
                    <span className="absolute -left-5 top-1 w-2 h-2 rounded-full bg-amber-600 ring-4 ring-white" />
                    <span className="font-mono text-[11px] text-amber-800 block">{item.date}</span>
                    <span className="text-neutral-800 font-medium">{item.stage}</span>
                  </div>
                ))}
              </div>
            </div>
          }
        />

        {/* Panel 4: How HeyMey prepares you */}
        <Panel
          id={content.panels[3].id}
          index={3}
          total={content.panels.length}
          badge={content.panels[3].badge}
          headline={content.panels[3].headline}
          body={content.panels[3].body}
          visual={
            <div className="w-full max-w-sm p-6 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col space-y-3 text-left">
              {content.panels[3].points?.map((pt) => (
                <Link
                  key={pt.title}
                  to={pt.link}
                  className="p-3.5 rounded-2xl bg-neutral-50/80 hover:bg-neutral-100/90 border border-neutral-200/60 transition-all flex flex-col group"
                >
                  <div className="flex items-center justify-between text-xs font-sans font-semibold text-neutral-900 group-hover:text-amber-900">
                    <span>{pt.title}</span>
                    <span>→</span>
                  </div>
                  <span className="text-[11px] font-sans text-neutral-600 mt-1 leading-snug">
                    {pt.desc}
                  </span>
                </Link>
              ))}
            </div>
          }
        />

        {/* Panel 5: Begin */}
        <Panel
          id={content.panels[4].id}
          index={4}
          total={content.panels.length}
          badge={content.panels[4].badge}
          headline={content.panels[4].headline}
          body={content.panels[4].body}
          visual={
            <div className="w-full max-w-sm p-8 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col items-center text-center space-y-4">
              <Sudi state="bright" size={72} />
              <h4 className="font-serif text-2xl text-neutral-950 font-normal">
                TNPSC Group 4 Closed Beta
              </h4>
              <p className="font-sans text-xs text-neutral-600">
                Join thousands of focused aspirants preparing with honesty.
              </p>
              <CtaButton label={content.panels[4].ctaText} />
            </div>
          }
          actions={
            <div className="flex flex-wrap items-center gap-3">
              <CtaButton label={content.panels[4].ctaText} />
              {content.panels[4].secondaryText && (
                <a
                  href={content.panels[4].secondaryHref}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="rounded-full px-6 py-3 text-sm font-sans font-medium bg-white/70 hover:bg-white border border-neutral-300 text-neutral-900"
                >
                  {content.panels[4].secondaryText} ↗
                </a>
              )}
            </div>
          }
        />
      </PanelTrack>
    </Scene>
  );
};
