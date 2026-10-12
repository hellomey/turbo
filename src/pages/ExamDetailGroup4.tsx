import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Scene } from '../components/Scene';
import { PanelTrack } from '../components/PanelTrack';
import { Panel } from '../components/Panel';
import { CtaButton } from '../components/CtaButton';

export const ExamDetailGroup4 = () => {
  const [currentPanel, setCurrentPanel] = useState(0);

  const panels = [
    {
      id: 'numbers',
      badge: '01 / The Arithmetic',
      headline: (
        <>
          One exam. A <span className="italic text-neutral-500 font-serif">very large room.</span>
        </>
      ),
      headlineText: 'One exam. A very large room.',
      body: 'Roughly one selection for every 300–350 candidates. That is why knowing where you truly stand matters.',
      stats: [
        { label: 'Candidates Applied', value: '~20 Lakh' },
        { label: 'Appeared on Exam Day', value: '13,89,738' },
        { label: 'Posts Notified', value: '3,935' },
      ],
      footnote:
        'Source: TNPSC Group 4, 12 July 2025, as reported by Dinamalar (Oct 2025) and News Today (Jul 2025). Later reports cite ~4,662 posts.',
    },
    {
      id: 'structure',
      badge: '02 / Pattern',
      headline: (
        <>
          What the exam <span className="italic text-neutral-500 font-serif">tests.</span>
        </>
      ),
      headlineText: 'What the exam tests.',
      body: 'A single objective paper of 200 questions carrying 300 marks over 3 hours.',
      items: [
        'Part A: General Tamil (100 Qs • 150 Marks)',
        'Part B: General Studies (75 Qs • 112.5 Marks)',
        'Part B: Aptitude & Mental Ability (25 Qs • 37.5 Marks)',
      ],
      footnote: 'All questions derived from Tamil Nadu SCERT Samacheer Kalvi syllabus.',
    },
    {
      id: 'cycle',
      badge: '03 / Timeline',
      headline: (
        <>
          One complete <span className="italic text-neutral-500 font-serif">cycle.</span>
        </>
      ),
      headlineText: 'One complete cycle.',
      body: 'Preparation looks different at each stage. So does your daily guidance in HeyMey.',
      items: [
        '25 Apr: Official Notification',
        '24 May: Applications Close',
        '12 Jul: Statewide Exam',
        '21 Jul: Tentative Keys',
        '22 Oct: Rank Results',
      ],
    },
    {
      id: 'approach',
      badge: '04 / Preparation',
      headline: (
        <>
          How HeyMey <span className="italic text-neutral-500 font-serif">prepares you.</span>
        </>
      ),
      headlineText: 'How HeyMey prepares you.',
      body: 'No mindless mock dumps. Targeted clarity every single day.',
      links: [
        { title: 'Readiness Score', link: '/studio#know' },
        { title: 'Targeted Daily Five', link: '/studio#practise' },
        { title: 'Bilingual Explanations', link: '/studio#understand' },
      ],
    },
    {
      id: 'begin',
      badge: '05 / Begin Today',
      headline: (
        <>
          Start with honest <span className="italic text-neutral-500 font-serif">clarity.</span>
        </>
      ),
      headlineText: 'Start with honest clarity.',
      body: 'Take your first comprehensive diagnostic for TNPSC Group 4 today completely free.',
      cta: true,
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
        ariaLabel="TNPSC Group 4 Examination Details"
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
                  <a
                    href="https://www.tnpsc.gov.in"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="rounded-full px-6 py-3.5 text-sm font-sans font-medium bg-white/70 hover:bg-white border border-neutral-300 text-neutral-900 transition-all shadow-xs"
                  >
                    Official Portal ↗
                  </a>
                </div>
              ) : undefined
            }
          >
            {panel.stats && (
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 w-full max-w-lg mb-6">
                {panel.stats.map((s) => (
                  <div key={s.label} className="p-4 rounded-2xl bg-white border border-neutral-200/80 text-center shadow-xs">
                    <span className="font-serif text-2xl sm:text-3xl font-bold text-neutral-950 block">
                      {s.value}
                    </span>
                    <span className="text-[11px] font-sans text-neutral-500 mt-1 block">
                      {s.label}
                    </span>
                  </div>
                ))}
              </div>
            )}

            {panel.items && (
              <div className="flex flex-wrap items-center justify-center gap-2.5 max-w-xl mb-6">
                {panel.items.map((it) => (
                  <span
                    key={it}
                    className="px-4 py-2 rounded-full text-xs sm:text-sm font-sans bg-white border border-neutral-200/80 text-neutral-800 shadow-xs"
                  >
                    {it}
                  </span>
                ))}
              </div>
            )}

            {panel.links && (
              <div className="flex flex-wrap items-center justify-center gap-3 max-w-lg mb-6">
                {panel.links.map((l) => (
                  <Link
                    key={l.title}
                    to={l.link}
                    className="px-5 py-2.5 rounded-full text-xs sm:text-sm font-sans font-medium bg-white hover:bg-neutral-50 border border-neutral-300 text-neutral-900 shadow-xs transition-all"
                  >
                    {l.title} →
                  </Link>
                ))}
              </div>
            )}
          </Panel>
        ))}
      </PanelTrack>
    </Scene>
  );
};
