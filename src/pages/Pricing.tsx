import { useState } from 'react';
import { Scene } from '../components/Scene';
import { PanelTrack } from '../components/PanelTrack';
import { Panel } from '../components/Panel';
import { CtaButton } from '../components/CtaButton';
import { pricingContent } from '../content/pricing';
import { PRICING_CONFIG } from '../config/pricing.config';

export const Pricing = () => {
  const content = pricingContent.en;
  const [currentPanel, setCurrentPanel] = useState(0);

  const panelIds = content.panels.map((p) => p.id);

  const priceDisplay =
    PRICING_CONFIG.cyclePassPrice !== null
      ? `${PRICING_CONFIG.currency}${PRICING_CONFIG.cyclePassPrice}`
      : 'Beta pricing announced soon';

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
        ariaLabel="Pricing Plans"
      >
        {/* Panel 1: Free Tier */}
        <Panel
          id={content.panels[0].id}
          index={0}
          total={content.panels.length}
          badge="01 / 04 • FOUNDATION"
          headline="Start freely. No card required."
          body={content.panels[0].body}
          visual={
            <div className="w-full max-w-md p-6 rounded-2xl bg-white border border-neutral-200/90 shadow-sm text-left font-sans text-xs">
              <span className="text-[11px] font-medium uppercase tracking-wider text-neutral-400 block mb-3">
                Included at No Cost
              </span>
              <ul className="space-y-2.5 text-neutral-700">
                {content.panels[0].features?.map((f) => (
                  <li key={f} className="flex items-center gap-2.5">
                    <span className="text-neutral-400 text-sm">—</span>
                    <span>{f}</span>
                  </li>
                ))}
              </ul>
            </div>
          }
          actions={<CtaButton label="Start For Free" href="/begin?plan=free" />}
        />

        {/* Panel 2: Cycle Pass */}
        <Panel
          id={content.panels[1].id}
          index={1}
          total={content.panels.length}
          badge="02 / 04 • CYCLE PASS"
          headline="One honest price for your whole exam season."
          body={content.panels[1].body}
          visual={
            <div className="w-full max-w-md p-6 rounded-2xl bg-white border border-neutral-200/90 shadow-sm text-left font-sans text-xs">
              <div className="flex items-baseline justify-between pb-4 mb-4 border-b border-neutral-100">
                <span className="font-serif text-3xl font-normal text-neutral-950">
                  {priceDisplay}
                </span>
                <span className="text-[11px] text-neutral-500 font-medium">
                  {PRICING_CONFIG.cyclePassDuration}
                </span>
              </div>
              <ul className="space-y-2.5 text-neutral-700">
                {content.panels[1].features?.map((f) => (
                  <li key={f} className="flex items-center gap-2.5">
                    <span className="text-neutral-400 text-sm">—</span>
                    <span>{f}</span>
                  </li>
                ))}
              </ul>
            </div>
          }
          actions={<CtaButton label="Join Pass Waitlist" href="/begin?plan=pass" />}
          footnote={content.panels[1].badgeNote}
        />

        {/* Panel 3: For Institutions */}
        <Panel
          id={content.panels[2].id}
          index={2}
          total={content.panels.length}
          badge="03 / 04 • INSTITUTIONS"
          headline="Support your whole academy cohort."
          body={content.panels[2].body}
          visual={
            <div className="w-full max-w-md p-6 rounded-2xl bg-white border border-neutral-200/90 shadow-sm text-left font-sans text-xs space-y-3">
              <div className="p-3 rounded-xl bg-neutral-50 border border-neutral-200/60">
                <span className="font-medium text-neutral-950 block mb-0.5">Custom Batch Pricing</span>
                <span className="text-neutral-600">Tiered licensing based on student volume and exam targets.</span>
              </div>
              <div className="p-3 rounded-xl bg-neutral-50 border border-neutral-200/60">
                <span className="font-medium text-neutral-950 block mb-0.5">Faculty Diagnostic Dashboard</span>
                <span className="text-neutral-600">Cohort-level analytics with zero infringement on individual student privacy.</span>
              </div>
            </div>
          }
          actions={
            <CtaButton
              label={content.panels[2].ctaText || 'For Institutions'}
              variant="secondary"
              href={content.panels[2].ctaHref || '/institutions'}
            />
          }
        />

        {/* Panel 4: Promises */}
        <Panel
          id={content.panels[3].id}
          index={3}
          total={content.panels.length}
          badge="04 / 04 • OUR COMMITMENT"
          headline="Zero hidden traps. Clean principles."
          body={content.panels[3].body}
          visual={
            <div className="w-full max-w-md p-5 rounded-2xl bg-white border border-neutral-200/90 shadow-sm text-left font-sans text-xs space-y-2.5">
              {content.panels[3].points?.map((p) => (
                <div key={p} className="flex items-center gap-3 py-1.5 border-b border-neutral-100 last:border-none">
                  <span className="text-neutral-400">—</span>
                  <span className="text-neutral-800">{p}</span>
                </div>
              ))}
            </div>
          }
          actions={
            <CtaButton
              label="Read Refund Policy"
              variant="secondary"
              href={content.panels[3].refundLink || '/legal/refunds'}
            />
          }
        />
      </PanelTrack>
    </Scene>
  );
};
