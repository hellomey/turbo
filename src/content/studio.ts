export interface StudioPanelContent {
  id: string;
  badge: string;
  headline: string;
  body: string;
  footnote?: string;
  visualType: 'phone' | 'readinessRing' | 'questionCard' | 'chatTyping' | 'sudiCycler' | 'examTimeline' | 'beginCta';
  subBars?: string[];
  ctaText?: string;
  secondaryCtaText?: string;
  secondaryCtaHref?: string;
  alsoExplore?: Array<{ label: string; href: string }>;
}

export const studioContent = {
  en: {
    metaTitle: 'Product Tour — Inside HeyMey',
    metaDescription:
      'Four quiet ideas, built for a phone and five spare minutes. Explore how HeyMey helps Tamil Nadu aspirants prepare honestly.',
    panels: [
      {
        id: 'intro',
        badge: '01 / Overview',
        headline: 'Inside HeyMey.',
        body: 'Four quiet ideas, built for a phone and five spare minutes.',
        visualType: 'phone',
      },
      {
        id: 'know',
        badge: '02 / Readiness Score',
        headline: 'A readiness score you can open up.',
        body: 'See where you stand today, how sure we are, and what moved it. No black box.',
        visualType: 'readinessRing',
        subBars: [
          'how well you know it',
          'how often you practice',
          'how much of syllabus covered',
          'which direction you are heading',
        ],
      },
      {
        id: 'practise',
        badge: '03 / Daily Practice',
        headline: 'Five minutes a day, aimed at you.',
        body: 'A daily challenge and a revision list built from what you got wrong, not random drills.',
        visualType: 'questionCard',
      },
      {
        id: 'understand',
        badge: '04 / Bilingual Doubts',
        headline: 'Ask in Tamil or English.',
        body: 'Stuck on a concept? Get a clear explanation in seconds, in the language you think in.',
        footnote: 'AI explanations can make mistakes. Report errors and we fix them promptly.',
        visualType: 'chatTyping',
      },
      {
        id: 'return',
        badge: '05 / Habit & Streak',
        headline: 'A habit that forgives.',
        body: 'Miss a day and your streak gets a shield, not a scolding. Sudi, our little flame, is on your side.',
        visualType: 'sudiCycler',
      },
      {
        id: 'calendar',
        badge: '06 / Exam Cycle',
        headline: 'It moves with your exam.',
        body: 'Notification out: a sprint plan. Exam week: calm mode. Results: your next-attempt plan.',
        visualType: 'examTimeline',
      },
      {
        id: 'begin',
        badge: '07 / Getting Started',
        headline: 'Ready when you are.',
        body: 'Your first diagnostic is completely free.',
        visualType: 'beginCta',
        ctaText: 'Begin Journey',
        secondaryCtaText: "See what's free",
        secondaryCtaHref: '/pricing',
        alsoExplore: [
          { label: 'Exams', href: '/exams' },
          { label: 'Result Day', href: '/result-day' },
          { label: 'Pricing', href: '/pricing' },
        ],
      },
    ] as StudioPanelContent[],
  },
};
