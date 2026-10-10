import { useState } from 'react';
import { Scene } from '../components/Scene';
import { PanelTrack } from '../components/PanelTrack';
import { Panel } from '../components/Panel';
import { CtaButton } from '../components/CtaButton';
import { resultDayContent } from '../content/resultDay';
import { Sudi } from '../components/Sudi';

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
        {/* Panel 1 */}
        <Panel
          id={content.panels[0].id}
          index={0}
          total={content.panels.length}
          badge={content.panels[0].badge}
          headline={content.panels[0].headline}
          body={content.panels[0].body}
          visual={
            <div className="w-full max-w-sm p-6 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col space-y-3 text-left">
              <span className="text-xs font-sans font-bold uppercase tracking-wider text-amber-900">
                Tentative Key Evaluator
              </span>
              <div className="p-4 rounded-2xl bg-neutral-50/90 border border-neutral-200 flex flex-col items-center text-center">
                <span className="text-[11px] font-sans text-neutral-500 uppercase tracking-wider">
                  Raw Expected Score
                </span>
                <span className="font-serif text-4xl font-bold text-neutral-900 my-1">
                  254.5 / 300
                </span>
                <span className="text-xs font-sans text-emerald-700 font-medium">
                  171 Correct • 29 Incorrect
                </span>
              </div>
              <p className="text-[11px] font-sans text-neutral-500 text-center">
                Negative marking rules applied automatically.
              </p>
            </div>
          }
        />

        {/* Panel 2 */}
        <Panel
          id={content.panels[1].id}
          index={1}
          total={content.panels.length}
          badge={content.panels[1].badge}
          headline={content.panels[1].headline}
          body={content.panels[1].body}
          visual={
            <div className="w-full max-w-sm p-6 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col space-y-2.5 text-left text-xs font-sans">
              <span className="font-bold uppercase tracking-wider text-amber-900 mb-1">
                Historical Benchmark Context
              </span>
              <div className="p-3 rounded-2xl bg-neutral-50 flex items-center justify-between border border-neutral-200/60">
                <span className="text-neutral-700">BC (General) Cutoff Range</span>
                <span className="font-semibold text-neutral-900">162–166 Qs</span>
              </div>
              <div className="p-3 rounded-2xl bg-neutral-50 flex items-center justify-between border border-neutral-200/60">
                <span className="text-neutral-700">MBC / DNC Cutoff Range</span>
                <span className="font-semibold text-neutral-900">158–163 Qs</span>
              </div>
              <div className="p-3 rounded-2xl bg-neutral-50 flex items-center justify-between border border-neutral-200/60">
                <span className="text-neutral-700">SC / ST Cutoff Range</span>
                <span className="font-semibold text-neutral-900">148–154 Qs</span>
              </div>
              <p className="text-[10px] text-neutral-400 text-center pt-1 italic">
                Contextual historical data only; never a guarantee of selection.
              </p>
            </div>
          }
        />

        {/* Panel 3 */}
        <Panel
          id={content.panels[2].id}
          index={2}
          total={content.panels.length}
          badge={content.panels[2].badge}
          headline={content.panels[2].headline}
          body={content.panels[2].body}
          visual={
            <div className="w-full max-w-sm p-6 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col items-center text-center space-y-3">
              <Sudi state="thinking" size={60} />
              <h4 className="font-serif text-xl font-normal text-neutral-950">
                Next-Attempt Roadmap
              </h4>
              <p className="font-sans text-xs text-neutral-600 leading-relaxed">
                Seamless transition into TNPSC Group 2 or next cycle revision without starting from scratch.
              </p>
            </div>
          }
        />

        {/* Panel 4 */}
        <Panel
          id={content.panels[3].id}
          index={3}
          total={content.panels.length}
          badge={content.panels[3].badge}
          headline={content.panels[3].headline}
          body={content.panels[3].body}
          footnote={content.panels[3].footnote}
          visual={
            <div className="w-full max-w-sm p-8 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col items-center text-center space-y-4">
              <Sudi state="bright" size={72} />
              <h4 className="font-serif text-2xl text-neutral-950 font-normal">
                Be First On Key Day
              </h4>
              <p className="font-sans text-xs text-neutral-600">
                Get immediate notification as official key uploads open.
              </p>
              <CtaButton
                label={content.panels[3].ctaText || 'Notify me'}
                href={content.panels[3].ctaHref}
              />
            </div>
          }
          actions={
            <CtaButton
              label={content.panels[3].ctaText || 'Notify me'}
              href={content.panels[3].ctaHref}
            />
          }
        />
      </PanelTrack>
    </Scene>
  );
};
