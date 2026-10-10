import { useState } from 'react';
import { Scene } from '../components/Scene';
import { PanelTrack } from '../components/PanelTrack';
import { Panel } from '../components/Panel';
import { CtaButton } from '../components/CtaButton';
import { AlsoExplore } from '../components/AlsoExplore';
import { aboutContent } from '../content/about';
import { Sudi } from '../components/Sudi';

export const About = () => {
  const content = aboutContent.en;
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
        ariaLabel="About HeyMey"
      >
        {/* Panel 1: Why HeyMey */}
        <Panel
          id={content.panels[0].id}
          index={0}
          total={content.panels.length}
          badge={content.panels[0].badge}
          headline={content.panels[0].headline}
          body={content.panels[0].body}
          visual={
            <div className="w-full max-w-sm p-8 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col items-center text-center">
              <Sudi state="bright" size={80} />
              <h4 className="font-serif text-2xl text-neutral-950 font-normal mt-4 mb-2">
                Honesty Over Hype
              </h4>
              <p className="font-sans text-xs text-neutral-600 leading-relaxed">
                Exam preparation designed for human dignity, not anxious addiction.
              </p>
            </div>
          }
        />

        {/* Panel 2: The Problem */}
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
                The Harsh Arithmetic
              </span>
              {content.panels[1].stats?.map((s) => (
                <div key={s.label} className="p-3 rounded-2xl bg-neutral-50 flex items-center justify-between border border-neutral-200/60">
                  <span className="text-xs font-sans text-neutral-600">{s.label}</span>
                  <span className="font-serif text-xl font-bold text-neutral-900">{s.val}</span>
                </div>
              ))}
            </div>
          }
        />

        {/* Panel 3: Why மெய் & Thirukkural 423 */}
        <Panel
          id={content.panels[2].id}
          index={2}
          total={content.panels.length}
          badge={content.panels[2].badge}
          headline={content.panels[2].headline}
          body={content.panels[2].body}
          visual={
            <div className="w-full max-w-md p-6 rounded-3xl bg-amber-50/90 backdrop-blur-md border border-amber-200/80 shadow-2xl flex flex-col text-left space-y-3 font-tamil">
              <span className="text-[11px] font-sans font-bold uppercase tracking-wider text-amber-900">
                திருக்குறள் (Thirukkural 423)
              </span>
              <p className="text-sm font-medium text-neutral-900 leading-relaxed italic">
                "{content.panels[2].kuralTamil}"
              </p>
              <p className="font-sans text-xs text-neutral-700 leading-relaxed italic">
                "{content.panels[2].kuralEnglish}"
              </p>
              <span className="font-sans text-[11px] text-neutral-500 pt-1">
                {content.panels[2].kuralCitation}
              </span>
            </div>
          }
        />

        {/* Panel 4: What We Won't Do */}
        <Panel
          id={content.panels[3].id}
          index={3}
          total={content.panels.length}
          badge={content.panels[3].badge}
          headline={content.panels[3].headline}
          body={content.panels[3].body}
          visual={
            <div className="w-full max-w-sm p-6 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col space-y-2.5 text-left text-xs font-sans">
              <span className="font-bold uppercase tracking-wider text-amber-900 mb-1">
                Our Non-Negotiables
              </span>
              {content.panels[3].items?.map((it) => (
                <div key={it} className="p-2.5 rounded-xl bg-neutral-50 flex items-center gap-2 border border-neutral-200/60">
                  <span className="text-amber-700 font-bold">✕</span>
                  <span className="text-neutral-800">{it}</span>
                </div>
              ))}
            </div>
          }
        />

        {/* Panel 5: Roadmap */}
        <Panel
          id={content.panels[4].id}
          index={4}
          total={content.panels.length}
          badge={content.panels[4].badge}
          headline={content.panels[4].headline}
          body={content.panels[4].body}
          visual={
            <div className="w-full max-w-sm p-6 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col space-y-3 text-left text-xs font-sans">
              <div className="p-3 rounded-2xl bg-amber-100/70 border border-amber-300">
                <span className="font-bold text-amber-900 block mb-0.5">Phase 1 (Active)</span>
                <span className="text-neutral-700">TNPSC Group 4 & VAO Closed Beta</span>
              </div>
              <div className="p-3 rounded-2xl bg-neutral-50 border border-neutral-200">
                <span className="font-bold text-neutral-900 block mb-0.5">Phase 2</span>
                <span className="text-neutral-600">Result Day Score Evaluator & TNPSC Group 2</span>
              </div>
              <div className="p-3 rounded-2xl bg-neutral-50 border border-neutral-200">
                <span className="font-bold text-neutral-900 block mb-0.5">Phase 3</span>
                <span className="text-neutral-600">State Police (TNUSRB) & Teacher Eligibility (TRB)</span>
              </div>
            </div>
          }
        />

        {/* Panel 6: People & Links */}
        <Panel
          id={content.panels[5].id}
          index={5}
          total={content.panels.length}
          badge={content.panels[5].badge}
          headline={content.panels[5].headline}
          body={content.panels[5].body}
          visual={
            <div className="w-full max-w-sm p-8 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col items-center text-center space-y-3">
              <Sudi state="resting" size={72} />
              <h4 className="font-serif text-2xl text-neutral-950 font-normal">
                Always Listening.
              </h4>
              <p className="font-sans text-xs text-neutral-600 leading-relaxed">
                Have questions or ideas? We respond personally to every aspirant.
              </p>
              <CtaButton label={content.panels[5].ctaText} href={content.panels[5].ctaHref} />
            </div>
          }
          actions={
            <CtaButton label={content.panels[5].ctaText} href={content.panels[5].ctaHref} />
          }
        >
          {content.panels[5].alsoExplore && (
            <AlsoExplore links={content.panels[5].alsoExplore} />
          )}
        </Panel>
      </PanelTrack>
    </Scene>
  );
};
