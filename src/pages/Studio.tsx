import { useState } from 'react';
import { Scene } from '../components/Scene';
import { PanelTrack } from '../components/PanelTrack';
import { Panel } from '../components/Panel';
import { CtaButton } from '../components/CtaButton';
import { AlsoExplore } from '../components/AlsoExplore';

export const Studio = () => {
  const [currentPanel, setCurrentPanel] = useState(0);

  const panels = [
    {
      id: 'intro',
      badge: '01 / Product Tour',
      headline: (
        <>
          Inside <span className="italic text-neutral-500 font-serif">HeyMey.</span>
        </>
      ),
      headlineText: 'Inside HeyMey.',
      body: 'Four quiet ideas, built for a phone and five spare minutes of focused daily preparation.',
      highlights: [
        'Readiness Score',
        'Daily Five Minutes',
        'Bilingual Explanations',
        'Forgiving Habits',
      ],
    },
    {
      id: 'know',
      badge: '02 / Transparency',
      headline: (
        <>
          A readiness score you can <span className="italic text-neutral-500 font-serif">open up.</span>
        </>
      ),
      headlineText: 'A readiness score you can open up.',
      body: 'See where you stand today, how sure we are, and what moved it. Never an opaque black box.',
      highlights: [
        'Accuracy & retention depth',
        'Consistency over time',
        'Syllabus breadth covered',
        'Directional progress velocity',
      ],
    },
    {
      id: 'practise',
      badge: '03 / Daily Practice',
      headline: (
        <>
          Five minutes a day, <span className="italic text-neutral-500 font-serif">aimed at you.</span>
        </>
      ),
      headlineText: 'Five minutes a day, aimed at you.',
      body: 'A daily challenge and a personalized revision list built from what you missed earlier, never random drill dumps.',
    },
    {
      id: 'understand',
      badge: '04 / Bilingual Doubts',
      headline: (
        <>
          Ask in <span className="italic text-neutral-500 font-serif">Tamil or English.</span>
        </>
      ),
      headlineText: 'Ask in Tamil or English.',
      body: 'Stuck on a concept? Get a clear, textbook-verified explanation in seconds, in the language you naturally think in.',
      footnote: 'AI explanations can make mistakes. Report errors and our academic team corrects them.',
    },
    {
      id: 'return',
      badge: '05 / Habit & Streak',
      headline: (
        <>
          A habit that <span className="italic text-neutral-500 font-serif">forgives.</span>
        </>
      ),
      headlineText: 'A habit that forgives.',
      body: 'Miss a day and your streak receives a quiet shield, never an anxious scolding. Steady discipline beats artificial pressure.',
    },
    {
      id: 'calendar',
      badge: '06 / Exam Cycle',
      headline: (
        <>
          It moves with <span className="italic text-neutral-500 font-serif">your exam.</span>
        </>
      ),
      headlineText: 'It moves with your exam.',
      body: 'Notification out: a sprint plan. Exam week: calm revision mode. Results: your next-attempt roadmap.',
    },
    {
      id: 'begin',
      badge: '07 / Getting Started',
      headline: (
        <>
          Ready when <span className="italic text-neutral-500 font-serif">you are.</span>
        </>
      ),
      headlineText: 'Ready when you are.',
      body: 'Your first diagnostic test is completely free. Understand where you truly stand today.',
      cta: true,
      alsoExplore: [
        { label: 'Exams', href: '/exams' },
        { label: 'Result Day', href: '/result-day' },
        { label: 'Pricing', href: '/pricing' },
      ],
    },
  ];

  const panelIds = panels.map((p) => p.id);

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
        {panels.map((panel, idx) => (
          <Panel
            key={panel.id}
            id={panel.id}
            index={idx}
            total={panels.length}
            badge={panel.badge}
            headline={panel.headline}
            body={panel.body}
            footnote={panel.footnote}
            actions={
              panel.cta ? (
                <div className="flex flex-wrap items-center justify-center gap-3">
                  <CtaButton label="Begin Journey" />
                  <CtaButton
                    label="See what's free"
                    variant="secondary"
                    href="/pricing"
                  />
                </div>
              ) : undefined
            }
          >
            {panel.highlights && (
              <div className="flex flex-wrap items-center justify-center gap-2.5 sm:gap-3 max-w-lg mt-2 mb-4">
                {panel.highlights.map((h) => (
                  <span
                    key={h}
                    className="px-4 py-2 rounded-full text-xs sm:text-sm font-sans bg-white border border-neutral-200/80 text-neutral-800 shadow-xs"
                  >
                    {h}
                  </span>
                ))}
              </div>
            )}

            {panel.alsoExplore && <AlsoExplore links={panel.alsoExplore} />}
          </Panel>
        ))}
      </PanelTrack>
    </Scene>
  );
};
