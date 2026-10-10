import { useState } from 'react';
import { Scene } from '../components/Scene';
import { PanelTrack } from '../components/PanelTrack';
import { Panel } from '../components/Panel';
import { CtaButton } from '../components/CtaButton';
import { pricingContent } from '../content/pricing';
import { PRICING_CONFIG } from '../config/pricing.config';
import { Sudi } from '../components/Sudi';

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
          badge={content.panels[0].badge}
          headline={content.panels[0].headline}
          body={content.panels[0].body}
          visual={
            <div className="w-full max-w-sm p-6 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col space-y-3 text-left">
              <span className="text-xs font-sans font-bold uppercase tracking-wider text-emerald-800 bg-emerald-100 px-2.5 py-1 rounded-full self-start">
                Free Forever
              </span>
              <ul className="space-y-2 text-xs font-sans text-neutral-700">
                {content.panels[0].features?.map((f) => (
                  <li key={f} className="flex items-center gap-2">
                    <span className="text-emerald-600 font-bold">✓</span>
                    <span>{f}</span>
                  </li>
                ))}
              </ul>
              <CtaButton label="Start For Free" className="w-full mt-2" />
            </div>
          }
          actions={<CtaButton label="Start For Free" />}
        />

        {/* Panel 2: Cycle Pass */}
        <Panel
          id={content.panels[1].id}
          index={1}
          total={content.panels.length}
          badge={content.panels[1].badge}
          headline={content.panels[1].headline}
          body={content.panels[1].body}
          footnote={content.panels[1].badgeNote}
          visual={
            <div className="w-full max-w-sm p-6 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col space-y-3.5 text-left">
              <span className="text-xs font-sans font-bold uppercase tracking-wider text-amber-900 bg-amber-100 px-2.5 py-1 rounded-full self-start">
                Cycle Pass
              </span>
              <div className="p-3.5 rounded-2xl bg-neutral-50/90 border border-neutral-200/80 flex items-baseline justify-between">
                <span className="font-serif text-2xl font-bold text-neutral-900">
                  {priceDisplay}
                </span>
                <span className="text-[11px] font-sans text-neutral-500 font-medium">
                  {PRICING_CONFIG.cyclePassDuration}
                </span>
              </div>
              <ul className="space-y-2 text-xs font-sans text-neutral-700">
                {content.panels[1].features?.map((f) => (
                  <li key={f} className="flex items-center gap-2">
                    <span className="text-amber-600 font-bold">✦</span>
                    <span>{f}</span>
                  </li>
                ))}
              </ul>
            </div>
          }
          actions={<CtaButton label="Join Waitlist" />}
        />

        {/* Panel 3: For Institutions */}
        <Panel
          id={content.panels[2].id}
          index={2}
          total={content.panels.length}
          badge={content.panels[2].badge}
          headline={content.panels[2].headline}
          body={content.panels[2].body}
          visual={
            <div className="w-full max-w-sm p-6 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col items-center text-center space-y-3">
              <Sudi state="thinking" size={64} />
              <h4 className="font-serif text-xl font-normal text-neutral-950">
                Cohort Intelligence
              </h4>
              <p className="font-sans text-xs text-neutral-600">
                Custom batch pricing and campus diagnostics.
              </p>
            </div>
          }
          actions={
            <CtaButton
              label={content.panels[2].ctaText || 'For Institutions'}
              variant="secondary"
              href={content.panels[2].ctaHref}
            />
          }
        />

        {/* Panel 4: Pricing Promises */}
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
                Zero Hidden Surprises
              </span>
              {content.panels[3].points?.map((p) => (
                <div key={p} className="p-2.5 rounded-xl bg-neutral-50 flex items-center gap-2 border border-neutral-200/60">
                  <span className="text-emerald-600">✓</span>
                  <span className="text-neutral-800">{p}</span>
                </div>
              ))}
            </div>
          }
          actions={
            <CtaButton
              label="Read Refund Policy"
              variant="secondary"
              href={content.panels[3].refundLink}
            />
          }
        />
      </PanelTrack>
    </Scene>
  );
};
