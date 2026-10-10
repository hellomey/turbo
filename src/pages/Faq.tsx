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
            body="Straightforward answers to the questions aspirants and educators ask most."
            visual={
              <div className="w-full max-w-md p-6 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col space-y-3.5 text-left text-xs font-sans">
                {cat.items.map((item, i) => (
                  <div
                    key={i}
                    className="p-3.5 rounded-2xl bg-neutral-50/80 border border-neutral-200/60 flex flex-col"
                  >
                    <span className="font-semibold text-neutral-950 mb-1">
                      {item.q}
                    </span>
                    <p className="text-neutral-600 leading-relaxed text-[11.5px]">
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
