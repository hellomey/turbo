import { useState } from 'react';
import { Scene } from '../components/Scene';
import { PanelTrack } from '../components/PanelTrack';
import { Panel } from '../components/Panel';
import { CtaButton } from '../components/CtaButton';
import { resultDayContent } from '../content/resultDay';

export const ResultDay = () => {
  const content = resultDayContent.en;
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
        ariaLabel="Result Day Toolkit"
      >
        {/* Panel 1: Key Evaluator */}
        <Panel
          id={content.panels[0].id}
          index={0}
          total={content.panels.length}
          badge="01 / 04 • EVALUATION"
          headline="Evaluate tentative marks with clarity."
          body={content.panels[0].body}
          visual={
            <div className="w-full max-w-md p-6 rounded-2xl bg-white border border-neutral-200/90 shadow-sm text-center">
              <span className="text-[11px] font-sans font-medium uppercase tracking-wider text-neutral-400 block mb-2">
                Estimated Mark
              </span>
              <div className="font-serif text-5xl text-neutral-950 font-normal tracking-tight mb-2">
                254.5 <span className="text-2xl text-neutral-400 font-light">/ 300</span>
              </div>
              <p className="font-sans text-xs text-neutral-500">
                171 correct • 29 incorrect • Official scheme applied
              </p>
            </div>
          }
          actions={
            <CtaButton
              label={content.panels[0].ctaText || 'Check Your Score'}
              href={content.panels[0].ctaHref || '/begin?intent=result-day'}
            />
          }
        />

        {/* Panel 2: Cutoff Context */}
        <Panel
          id={content.panels[1].id}
          index={1}
          total={content.panels.length}
          badge="02 / 04 • BENCHMARK"
          headline="Historical cutoffs, placed in perspective."
          body={content.panels[1].body}
          visual={
            <div className="w-full max-w-md p-5 rounded-2xl bg-white border border-neutral-200/90 shadow-sm flex flex-col space-y-2.5 text-left text-xs font-sans">
              <div className="flex items-center justify-between py-2 border-b border-neutral-100">
                <span className="text-neutral-600">BC (General) Historical Range</span>
                <span className="font-medium text-neutral-950">162–166 Qs</span>
              </div>
              <div className="flex items-center justify-between py-2 border-b border-neutral-100">
                <span className="text-neutral-600">MBC / DNC Historical Range</span>
                <span className="font-medium text-neutral-950">158–163 Qs</span>
              </div>
              <div className="flex items-center justify-between py-2">
                <span className="text-neutral-600">SC / ST Historical Range</span>
                <span className="font-medium text-neutral-950">148–154 Qs</span>
              </div>
            </div>
          }
          footnote="Historical benchmarks provide objective perspective; official results depend on session normalisation."
        />

        {/* Panel 3: Next Attempt Roadmap */}
        <Panel
          id={content.panels[2].id}
          index={2}
          total={content.panels.length}
          badge="03 / 04 • CONTINUITY"
          headline="Carry your hard work into the next notification."
          body={content.panels[2].body}
          visual={
            <div className="w-full max-w-md p-5 rounded-2xl bg-white border border-neutral-200/90 shadow-sm flex flex-col space-y-3 text-left text-xs font-sans">
              <div className="p-3 rounded-xl bg-neutral-50 border border-neutral-200/60">
                <span className="font-medium text-neutral-950 block mb-0.5">Syllabus Retention</span>
                <span className="text-neutral-600">Tamil eligibility and mental aptitude carry over 100% to Group 2.</span>
              </div>
              <div className="p-3 rounded-xl bg-neutral-50 border border-neutral-200/60">
                <span className="font-medium text-neutral-950 block mb-0.5">Weak-Spot Audit</span>
                <span className="text-neutral-600">Identify exactly where questions were dropped before starting fresh.</span>
              </div>
            </div>
          }
          actions={
            <CtaButton
              label={content.panels[2].ctaText || 'Plan Next Attempt'}
              variant="secondary"
              href={content.panels[2].ctaHref || '/begin?intent=continuity'}
            />
          }
        />

        {/* Panel 4: Notification */}
        <Panel
          id={content.panels[3].id}
          index={3}
          total={content.panels.length}
          badge="04 / 04 • ALERTS"
          headline="Be notified the moment official keys release."
          body={content.panels[3].body}
          actions={
            <CtaButton
              label={content.panels[3].ctaText || 'Get Key Notification'}
              href={content.panels[3].ctaHref || '/begin?intent=key-alert'}
            />
          }
          footnote={content.panels[3].footnote || 'No advertisements. Only official release notices.'}
        />
      </PanelTrack>
    </Scene>
  );
};
