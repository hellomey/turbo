import { useState } from 'react';
import { Scene } from '../components/Scene';
import { PanelTrack } from '../components/PanelTrack';
import { Panel } from '../components/Panel';
import { LeadForm } from '../components/LeadForm';
import { institutionsContent } from '../content/institutions';

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
        {/* Panel 1: Overview */}
        <Panel
          id={content.panels[0].id}
          index={0}
          total={content.panels.length}
          badge="01 / 05 • OVERVIEW"
          headline="Objective syllabus benchmarking across student cohorts."
          body={content.panels[0].body}
          visual={
            <div className="w-full max-w-md p-6 rounded-2xl bg-white border border-neutral-200/90 shadow-sm text-left font-sans text-xs space-y-2.5">
              <span className="text-[11px] font-medium uppercase tracking-wider text-neutral-400 block mb-1">
                Academy Diagnostic Signals
              </span>
              <div className="flex items-center justify-between py-2 border-b border-neutral-100">
                <span className="text-neutral-600">Cohort Syllabus Coverage</span>
                <span className="font-medium text-neutral-950">92.4% calibrated</span>
              </div>
              <div className="flex items-center justify-between py-2">
                <span className="text-neutral-600">Active Daily Practice Adherence</span>
                <span className="font-medium text-neutral-950">84% weekly retention</span>
              </div>
            </div>
          }
        />

        {/* Panel 2: Weak-Spot Analytics */}
        <Panel
          id={content.panels[1].id}
          index={1}
          total={content.panels.length}
          badge="02 / 05 • DIAGNOSTICS"
          headline="Locate cohort blind spots before exam day."
          body={content.panels[1].body}
          visual={
            <div className="w-full max-w-md p-6 rounded-2xl bg-white border border-neutral-200/90 shadow-sm flex flex-col space-y-3 text-left font-sans text-xs">
              <span className="text-[11px] font-medium uppercase tracking-wider text-neutral-400 mb-1">
                Curriculum Topic Breakdown
              </span>
              <div className="p-3 rounded-xl bg-neutral-50 border border-neutral-200/70">
                <span className="font-medium text-neutral-950 block">Tamil Literature (பகுதி அ)</span>
                <span className="text-neutral-500 text-[11px]">42% of batch requires revision on Sangam poetry.</span>
              </div>
              <div className="p-3 rounded-xl bg-neutral-50 border border-neutral-200/70">
                <span className="font-medium text-neutral-950 block">Indian Polity & Economy</span>
                <span className="text-neutral-500 text-[11px]">88% mastery across constitutional articles.</span>
              </div>
            </div>
          }
        />

        {/* Panel 3: 4-Week Pilot */}
        <Panel
          id={content.panels[2].id}
          index={2}
          total={content.panels.length}
          badge="03 / 05 • METHODOLOGY"
          headline="A structured, four-week pilot program."
          body={content.panels[2].body}
          visual={
            <div className="w-full max-w-md p-6 rounded-2xl bg-white border border-neutral-200/90 shadow-sm flex flex-col space-y-2.5 text-left font-sans text-xs">
              <div className="p-2.5 rounded-xl bg-neutral-50 border border-neutral-200/60">
                <span className="font-medium text-neutral-950">Week 1:</span> Baseline diagnostic test per student batch.
              </div>
              <div className="p-2.5 rounded-xl bg-neutral-50 border border-neutral-200/60">
                <span className="font-medium text-neutral-950">Week 2–3:</span> Daily calibrated 10-minute micro-drills.
              </div>
              <div className="p-2.5 rounded-xl bg-neutral-50 border border-neutral-200/60">
                <span className="font-medium text-neutral-950">Week 4:</span> Faculty benchmark debrief & predictive cohort report.
              </div>
            </div>
          }
        />

        {/* Panel 4: Privacy */}
        <Panel
          id={content.panels[3].id}
          index={3}
          total={content.panels.length}
          badge="04 / 05 • PRIVACY"
          headline="Cohort intelligence without invasive surveillance."
          body={content.panels[3].body}
          visual={
            <div className="w-full max-w-md p-5 rounded-2xl bg-white border border-neutral-200/90 shadow-sm flex flex-col space-y-2 text-left font-sans text-xs">
              <div className="flex items-center gap-2.5 py-1.5 border-b border-neutral-100">
                <span className="text-neutral-400">—</span>
                <span className="text-neutral-800">No public leaderboard shaming.</span>
              </div>
              <div className="flex items-center gap-2.5 py-1.5 border-b border-neutral-100">
                <span className="text-neutral-400">—</span>
                <span className="text-neutral-800">Faculty view aggregate weak patterns, not private diaries.</span>
              </div>
              <div className="flex items-center gap-2.5 py-1.5">
                <span className="text-neutral-400">—</span>
                <span className="text-neutral-800">Zero data shared or sold to third-party test prep brokers.</span>
              </div>
            </div>
          }
        />

        {/* Panel 5: Request Form */}
        <Panel
          id={content.panels[4].id}
          index={4}
          total={content.panels.length}
          badge="05 / 05 • COMMENCE"
          headline="Request a pilot cohort for your academy."
          body={content.panels[4].body}
          visual={<LeadForm type="pilot" />}
        />
      </PanelTrack>
    </Scene>
  );
};
