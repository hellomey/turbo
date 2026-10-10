import { useState } from 'react';
import { Scene } from '../components/Scene';
import { PanelTrack } from '../components/PanelTrack';
import { Panel } from '../components/Panel';
import { CtaButton } from '../components/CtaButton';
import { trustContent } from '../content/trust';
import { Sudi } from '../components/Sudi';

export const Trust = () => {
  const content = trustContent.en;
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
        ariaLabel="Trust and Principles"
      >
        {content.panels.map((panel, idx) => (
          <Panel
            key={panel.id}
            id={panel.id}
            index={idx}
            total={content.panels.length}
            badge={panel.badge}
            headline={panel.headline}
            body={panel.body}
            visual={
              <div className="w-full max-w-sm p-8 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col items-center text-center space-y-3">
                <Sudi
                  state={idx % 2 === 0 ? 'bright' : 'thinking'}
                  size={64}
                />
                <h4 className="font-serif text-xl font-normal text-neutral-950">
                  {panel.headline}
                </h4>
                <p className="font-sans text-xs text-neutral-600 leading-relaxed">
                  {panel.body}
                </p>
                {panel.linkText && panel.linkHref && (
                  <CtaButton
                    label={panel.linkText}
                    variant="secondary"
                    href={panel.linkHref}
                    className="mt-2 text-xs py-2 px-4"
                  />
                )}
              </div>
            }
            actions={
              panel.linkText && panel.linkHref ? (
                <CtaButton
                  label={panel.linkText}
                  variant="secondary"
                  href={panel.linkHref}
                />
              ) : undefined
            }
          />
        ))}
      </PanelTrack>
    </Scene>
  );
};
