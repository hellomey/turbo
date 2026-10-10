import { useState } from 'react';
import { Scene } from '../components/Scene';
import { PanelTrack } from '../components/PanelTrack';
import { Panel } from '../components/Panel';
import { LeadForm } from '../components/LeadForm';
import { institutionsContent } from '../content/institutions';
import { Sudi } from '../components/Sudi';

export const Institutions = () => {
  const content = institutionsContent.en;
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
        ariaLabel="Institutions and Coaching Academies"
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
            <div className="w-full max-w-sm p-8 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col items-center text-center space-y-3">
              <Sudi state="bright" size={72} />
              <h4 className="font-serif text-2xl text-neutral-950 font-normal">
                Batch Diagnostics
              </h4>
              <p className="font-sans text-xs text-neutral-600 leading-relaxed">
                Objective syllabus benchmarking across every student batch.
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
            <div className="w-full max-w-sm p-6 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col space-y-3 text-left text-xs font-sans">
              <span className="font-bold uppercase tracking-wider text-amber-900 mb-1">
                Batch Weak-Spot Analysis
              </span>
              <div className="p-3 rounded-2xl bg-neutral-50 border border-neutral-200/60">
                <span className="font-medium text-neutral-900 block">Tamil Literature (பகுதி அ)</span>
                <span className="text-amber-800 text-[11px]">42% students need reinforcement</span>
              </div>
              <div className="p-3 rounded-2xl bg-neutral-50 border border-neutral-200/60">
                <span className="font-medium text-neutral-900 block">Indian Polity & Economy</span>
                <span className="text-emerald-700 text-[11px]">88% mastery on current batch</span>
              </div>
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
            <div className="w-full max-w-sm p-6 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col text-left space-y-3 text-xs font-sans">
              <span className="font-bold uppercase tracking-wider text-amber-900 mb-1">
                Four-Week Pilot Workflow
              </span>
              <div className="space-y-2">
                <div className="p-2.5 rounded-xl bg-neutral-50 border border-neutral-200">
                  Week 1: Baseline Student Diagnostic
                </div>
                <div className="p-2.5 rounded-xl bg-neutral-50 border border-neutral-200">
                  Week 2–3: Daily Calibrated Practice
                </div>
                <div className="p-2.5 rounded-xl bg-neutral-50 border border-neutral-200">
                  Week 4: Comprehensive Benchmark Report
                </div>
              </div>
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
          visual={
            <div className="w-full max-w-sm p-8 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col items-center text-center space-y-3">
              <Sudi state="thinking" size={68} />
              <h4 className="font-serif text-2xl text-neutral-950 font-normal">
                Strict Student Privacy
              </h4>
              <p className="font-sans text-xs text-neutral-600 leading-relaxed">
                Aggregated cohort intelligence without compromising individual student boundaries.
              </p>
            </div>
          }
        />

        {/* Panel 5: Request Form */}
        <Panel
          id={content.panels[4].id}
          index={4}
          total={content.panels.length}
          badge={content.panels[4].badge}
          headline={content.panels[4].headline}
          body={content.panels[4].body}
          visual={<LeadForm type="pilot" />}
        />
      </PanelTrack>
    </Scene>
  );
};
