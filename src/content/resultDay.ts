export const resultDayContent = {
  en: {
    metaTitle: 'Result Day Toolkit — HeyMey',
    metaDescription:
      'Answer key out? Calculate expected marks, compare with historical cutoffs honestly, and plan your next move with clarity.',
    panels: [
      {
        id: 'calculate',
        badge: '01 / Score Check',
        headline: 'Answer key out? Know your score in a minute.',
        body: 'Enter your answers. See your expected marks, with negative marking accurately calculated.',
        visual: 'keyCalculator',
      },
      {
        id: 'cutoffs',
        badge: '02 / Historical Context',
        headline: 'Honest cutoff context.',
        body: 'See how your expected score compares with past published cutoffs for your category. It is context, never an empty promise.',
        visual: 'cutoffChart',
      },
      {
        id: 'next-plan',
        badge: '03 / Forward Momentum',
        headline: 'A plan for what is next.',
        body: 'Selected or not, start the next step the very next day, with your complete preparation history intact.',
        visual: 'pathway',
      },
      {
        id: 'notify',
        badge: '04 / Stay Informed',
        headline: 'Be first to know.',
        body: 'Get notified the moment official keys or toolkit updates go live.',
        ctaText: 'Notify me when it opens',
        ctaHref: '/begin?intent=result-day',
        footnote: 'Expected marks are an estimate until official government results are published.',
      },
    ],
  },
};
