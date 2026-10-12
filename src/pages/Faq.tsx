import { useState } from 'react';
import { Scene } from '../components/Scene';
import { PanelTrack } from '../components/PanelTrack';
import { Panel } from '../components/Panel';
import { faqContent } from '../content/faq';

export const Faq = () => {
  const content = faqContent.en;
  const [currentPanel, setCurrentPanel] = useState(0);

  const panelIds = content.categories.map((c) => c.id);

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
        ariaLabel="Frequently Asked Questions"
      >
        {content.categories.map((cat, idx) => (
          <Panel
            key={cat.id}
            id={cat.id}
            index={idx}
            total={content.categories.length}
            badge={cat.badge}
            headline={cat.title}
            body="Direct, straightforward answers to the questions aspirants and educators ask most."
            visual={
              <div className="w-full max-w-xl p-6 rounded-2xl bg-white border border-neutral-200/90 shadow-sm flex flex-col space-y-4 text-left font-sans text-xs">
                {cat.items.map((item, i) => (
                  <div
                    key={i}
                    className="pb-3.5 border-b border-neutral-100 last:border-none last:pb-0"
                  >
                    <span className="font-medium text-neutral-950 block mb-1 text-sm">
                      {item.q}
                    </span>
                    <p className="text-neutral-600 leading-relaxed text-xs">
                      {item.a}
                    </p>
                  </div>
                ))}
              </div>
            }
          />
        ))}
      </PanelTrack>
    </Scene>
  );
};
