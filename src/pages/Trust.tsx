import { useState } from 'react';
import { Scene } from '../components/Scene';
import { PanelTrack } from '../components/PanelTrack';
import { Panel } from '../components/Panel';
import { CtaButton } from '../components/CtaButton';
import { trustContent } from '../content/trust';

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
