import { useState } from 'react';
import { Scene } from '../components/Scene';
import { PanelTrack } from '../components/PanelTrack';
import { Panel } from '../components/Panel';
import { CtaButton } from '../components/CtaButton';
import { AlsoExplore } from '../components/AlsoExplore';
import {
  ReadinessRing,
  QuestionCard,
  ChatTyping,
  SudiCycler,
  ExamTimeline,
} from '../components/PanelVisuals';
import { studioContent } from '../content/studio';
import { Sudi } from '../components/Sudi';

export const Studio = () => {
  const content = studioContent.en;
  const [currentPanel, setCurrentPanel] = useState(0);

  const panelIds = content.panels.map((p) => p.id);

  const renderVisual = (type: string) => {
    switch (type) {
      case 'phone':
        return (
          <div className="w-full max-w-xs p-6 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col items-center text-center">
            <div className="w-full py-2 px-3 rounded-full bg-neutral-100 flex items-center justify-between text-xs text-neutral-600 mb-6">
              <span className="font-medium">Daily Diagnostic</span>
              <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
            </div>
            <Sudi state="bright" size={72} />
            <h4 className="font-serif text-2xl text-neutral-950 font-normal mt-4 mb-1">
              5 Minutes a Day
            </h4>
            <p className="font-sans text-xs text-neutral-600">
              Calibrated specifically for your exam syllabus.
            </p>
          </div>
        );
      case 'readinessRing':
        return <ReadinessRing />;
      case 'questionCard':
        return <QuestionCard />;
      case 'chatTyping':
        return <ChatTyping />;
      case 'sudiCycler':
        return <SudiCycler />;
      case 'examTimeline':
        return <ExamTimeline />;
      case 'beginCta':
        return (
          <div className="w-full max-w-sm p-8 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-2xl flex flex-col items-center text-center space-y-4">
            <Sudi state="bright" size={72} />
            <h4 className="font-serif text-2xl text-neutral-950 font-normal">
              Zero Guesswork.
            </h4>
            <p className="font-sans text-xs text-neutral-600 leading-relaxed">
              Start with your comprehensive diagnostic test completely free.
            </p>
            <CtaButton label="Begin Journey" />
          </div>
        );
      default:
        return null;
    }
  };

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
        ariaLabel="Product Tour Panels"
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
            footnote={panel.footnote}
            visual={renderVisual(panel.visualType)}
            actions={
              panel.ctaText ? (
                <div className="flex flex-wrap items-center gap-3">
                  <CtaButton label={panel.ctaText} />
                  {panel.secondaryCtaText && panel.secondaryCtaHref && (
                    <CtaButton
                      label={panel.secondaryCtaText}
                      variant="secondary"
                      href={panel.secondaryCtaHref}
                    />
                  )}
                </div>
              ) : undefined
            }
          >
            {panel.alsoExplore && <AlsoExplore links={panel.alsoExplore} />}
          </Panel>
        ))}
      </PanelTrack>
    </Scene>
  );
};
