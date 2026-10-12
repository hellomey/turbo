import { useState } from 'react';
import { Scene } from '../components/Scene';
import { PanelTrack } from '../components/PanelTrack';
import { Panel } from '../components/Panel';
import { CtaButton } from '../components/CtaButton';
import { AlsoExplore } from '../components/AlsoExplore';
import { aboutContent } from '../content/about';

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
          badge="01 / 06 • PHILOSOPHY"
          headline="Exam prep built on honesty, not anxiety."
          body={content.panels[0].body}
          actions={
            <CtaButton
              label="Join the Waitlist"
              href="/begin"
            />
          }
        />

        {/* Panel 2: The Harsh Arithmetic */}
        <Panel
          id={content.panels[1].id}
          index={1}
          total={content.panels.length}
          badge="02 / 06 • CONTEXT"
          headline="The arithmetic that coaching centres rarely say out loud."
          body={content.panels[1].body}
          visual={
            <div className="w-full max-w-md p-6 rounded-2xl bg-white border border-neutral-200/90 shadow-sm flex flex-col space-y-3 font-sans text-xs">
              <span className="text-[11px] font-medium uppercase tracking-wider text-neutral-400 mb-1">
                The Selection Funnel
              </span>
              {content.panels[1].stats?.map((s) => (
                <div key={s.label} className="flex items-center justify-between py-2 border-b border-neutral-100 last:border-none">
                  <span className="text-neutral-600">{s.label}</span>
                  <span className="font-serif text-2xl text-neutral-950 font-normal">{s.val}</span>
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
          badge="03 / 06 • FOUNDATION"
          headline="Rooted in the timeless virtue of மெய் (Truth)."
          body={content.panels[2].body}
          visual={
            <div className="w-full max-w-lg p-6 sm:p-8 rounded-2xl bg-white border border-neutral-200/90 shadow-sm text-center space-y-3">
              <span className="text-[11px] font-sans font-medium uppercase tracking-wider text-neutral-400 block">
                திருக்குறள் • Thirukkural 423
              </span>
              <p className="font-tamil text-base sm:text-lg text-neutral-900 leading-relaxed font-normal">
                "{content.panels[2].kuralTamil}"
              </p>
              <p className="font-serif italic text-base sm:text-lg text-neutral-600 leading-relaxed">
                "{content.panels[2].kuralEnglish}"
              </p>
              <span className="font-sans text-[11px] text-neutral-400 block pt-1">
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
          badge="04 / 06 • NON-NEGOTIABLES"
          headline="Things HeyMey will never do."
          body={content.panels[3].body}
          visual={
            <div className="w-full max-w-md p-5 rounded-2xl bg-white border border-neutral-200/90 shadow-sm flex flex-col space-y-2.5 text-left text-xs font-sans">
              {content.panels[3].items?.map((it) => (
                <div key={it} className="flex items-center gap-3 py-1.5 border-b border-neutral-100 last:border-none">
                  <span className="text-neutral-400">—</span>
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
          badge="05 / 06 • PROGRESSION"
          headline="A deliberate, staged release."
          body={content.panels[4].body}
          visual={
            <div className="w-full max-w-md p-5 rounded-2xl bg-white border border-neutral-200/90 shadow-sm flex flex-col space-y-3 text-left text-xs font-sans">
              <div className="p-3 rounded-xl bg-neutral-50 border border-neutral-200/70">
                <span className="font-medium text-neutral-950 block mb-0.5">Phase 1 (Active Beta)</span>
                <span className="text-neutral-600">TNPSC Group 4 & VAO — Closed cohort invitation.</span>
              </div>
              <div className="p-3 rounded-xl bg-neutral-50 border border-neutral-200/70">
                <span className="font-medium text-neutral-950 block mb-0.5">Phase 2</span>
                <span className="text-neutral-600">Key evaluator & TNPSC Group 2 / 2A combined preliminary.</span>
              </div>
              <div className="p-3 rounded-xl bg-neutral-50 border border-neutral-200/70">
                <span className="font-medium text-neutral-950 block mb-0.5">Phase 3</span>
                <span className="text-neutral-600">State Police (TNUSRB SI & Constable) and Teacher Eligibility (TRB).</span>
              </div>
            </div>
          }
        />

        {/* Panel 6: Team & Contact */}
        <Panel
          id={content.panels[5].id}
          index={5}
          total={content.panels.length}
          badge="06 / 06 • CONVERSATION"
          headline="Built with patience. Open to your questions."
          body={content.panels[5].body}
          actions={
            <CtaButton
              label={content.panels[5].ctaText || 'Get in Touch'}
              href={content.panels[5].ctaHref || '/contact'}
            />
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
